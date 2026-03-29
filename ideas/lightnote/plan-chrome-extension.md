# LightNote Chrome Extension Plan

## Overview

Build a Chrome Extension (`lightnote-extension`) to collect content from social media posts (starting with Facebook) and send them to the LightNote NestJS backend. Users see a "Send to LightNote" button on each post, click it, and the post data is automatically extracted and saved as a LightNote item.

**Repo**: `lightnote-extension` (separate repo)
**Framework**: **WXT** (https://wxt.dev) — next-gen web extension framework built on Vite
**UI**: React (consistent with LightNote web app)
**Target**: Chrome (Manifest V3), extensible to Firefox later

---

## Why WXT?

- **Vite-based**: HMR for popup/options pages, fast reload for content scripts
- **TypeScript first**: strict TS out of the box
- **File-based entrypoints**: convention over configuration — `entrypoints/` folder auto-generates manifest
- **Built-in content script UI**: `createShadowRootUi()` isolates injected button styles from Facebook's CSS
- **SPA handling**: built-in `wxt:locationchange` event for detecting Facebook's client-side navigation
- **Auto-imports**: utilities, composables, and hooks auto-imported
- **MV3 native**: designed for Manifest V3
- **191K weekly downloads**, production-tested by extensions with 2M+ users

**Key libraries:**
| Library | Purpose | Why |
|---------|---------|-----|
| `wxt` | Extension framework | Best DX, Vite-based, MV3 native |
| `@webext-core/messaging` | Content ↔ Background messaging | Type-safe, lightweight wrapper over chrome.runtime messaging |
| `wxt/storage` | Token & settings storage | Built-in WXT storage API with `chrome.storage.local` |
| `react` + `react-dom` | UI components | Consistent with LightNote web app |
| `oidc-client-ts` | OIDC auth flow | Same lib as web app, proven PKCE flow |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Chrome Extension                      │
│                                                          │
│  ┌──────────────┐   messages   ┌──────────────────────┐ │
│  │Content Script │◄───────────►│  Background Service   │ │
│  │(facebook.com) │             │  Worker               │ │
│  │               │             │                       │ │
│  │ - DOM scraper │             │ - API calls to NestJS │ │
│  │ - Inject btn  │             │ - Token management    │ │
│  │ - Extract data│             │ - Auth flow           │ │
│  └──────────────┘             └───────────┬───────────┘ │
│                                           │              │
│  ┌──────────────┐                         │              │
│  │  Popup Page   │                        ▼              │
│  │ - Login/Status│              ┌─────────────────────┐ │
│  │ - Settings    │              │ NestJS Backend       │ │
│  │ - Quick link  │              │ POST /api/collect    │ │
│  └──────────────┘              └─────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Phase 1: Project Scaffolding

### Step 1.1 — Initialize WXT project

```bash
pnpm dlx wxt@latest init lightnote-extension
cd lightnote-extension
pnpm install
```

Choose React as frontend framework during init.

### Step 1.2 — Dependencies

```bash
# Core
pnpm add react react-dom oidc-client-ts @webext-core/messaging

# Dev
pnpm add -D @types/react @types/react-dom tailwindcss postcss autoprefixer
```

### Step 1.3 — WXT config

```typescript
// wxt.config.ts
import { defineConfig } from 'wxt';

export default defineConfig({
  srcDir: 'src',
  modules: ['@wxt-dev/module-react'],
  manifest: {
    name: 'LightNote Collector',
    description: 'Collect posts from social media to LightNote',
    version: '1.0.0',
    permissions: ['storage', 'activeTab'],
    host_permissions: [
      '*://*.facebook.com/*',
      // Future: '*://*.instagram.com/*', '*://*.threads.net/*'
    ],
  },
});
```

### Step 1.4 — Project structure

```
lightnote-extension/
├── src/
│   ├── entrypoints/
│   │   ├── background.ts                # Service worker
│   │   ├── popup/                        # Extension popup
│   │   │   ├── index.html
│   │   │   ├── App.tsx
│   │   │   ├── main.tsx
│   │   │   └── style.css
│   │   └── facebook.content/            # Facebook content script
│   │       ├── index.ts                  # Entry, registers adapter
│   │       ├── style.css                 # Button styles (shadow root)
│   │       └── components/
│   │           └── CollectButton.tsx      # React button component
│   ├── lib/
│   │   ├── api.ts                        # API client for NestJS backend
│   │   ├── auth.ts                       # OIDC auth helpers
│   │   ├── messaging.ts                  # Type-safe message definitions
│   │   └── storage.ts                    # Token & settings storage
│   ├── platforms/
│   │   ├── base.ts                       # PlatformAdapter interface
│   │   ├── facebook.ts                   # Facebook scraper implementation
│   │   ├── instagram.ts                  # (future) Instagram adapter
│   │   └── registry.ts                   # Platform adapter registry
│   └── assets/
│       ├── icon-16.png
│       ├── icon-32.png
│       ├── icon-48.png
│       └── icon-128.png
├── public/
│   └── icon/
│       └── ...
├── wxt.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## Phase 2: Authentication

### Step 2.1 — OIDC configuration

Use `oidc-client-ts` (same library as the web app) adapted for Chrome extension context.

**Auth flow for Chrome Extension:**
1. User clicks "Sign In" in popup
2. Extension opens Authentik auth URL using `chrome.identity.launchWebAuthFlow()` (preferred) or fallback to `chrome.tabs.create()`
3. Redirect URI: `https://<extension-id>.chromiumapp.org/callback`
4. On callback, exchange authorization code for tokens (PKCE flow)
5. Store access token + refresh token in `chrome.storage.local` via WXT storage
6. Background service worker handles token refresh

**Authentik setup required:**
- Register new OAuth2 application in Authentik for the extension
- Add redirect URI: `https://<extension-id>.chromiumapp.org/callback`
- Same scopes: `openid profile email`
- Public client (no client_secret for extension)

### Step 2.2 — Token storage (using WXT storage API)

```typescript
// lib/storage.ts
import { storage } from 'wxt/storage';

export const accessToken = storage.defineItem<string>('local:accessToken');
export const refreshToken = storage.defineItem<string>('local:refreshToken');
export const tokenExpiry = storage.defineItem<number>('local:tokenExpiry');
export const userProfile = storage.defineItem<{
  sub: string;
  name: string;
  email: string;
}>('local:userProfile');

// Settings
export const apiBaseUrl = storage.defineItem<string>('local:apiBaseUrl', {
  fallback: 'https://api.lightnote.baole.space',
});
```

### Step 2.3 — Auto token refresh

Background service worker monitors token expiry:
- Set alarm for 5 minutes before expiry
- On alarm, use refresh token to get new access token
- If refresh fails, clear tokens and show "re-login needed" badge on extension icon

---

## Phase 3: Platform Adapter System (extensible)

### Step 3.1 — Base adapter interface

```typescript
// platforms/base.ts
export interface CollectedPost {
  source: 'facebook' | 'instagram' | 'threads' | '500px';
  sourceUrl: string;
  author: {
    name: string;
    profileUrl?: string;
  };
  content: string;
  images: string[];
  videos: string[];
  timestamp?: string;
}

export interface PlatformAdapter {
  /** Platform identifier */
  platform: CollectedPost['source'];

  /** Check if this adapter handles the current URL */
  matches(url: string): boolean;

  /** Find all post elements on the current page */
  findPosts(): HTMLElement[];

  /** Extract structured data from a post element */
  extractPost(element: HTMLElement): CollectedPost | null;

  /** Get a stable anchor selector within a post for button injection */
  getButtonAnchor(postElement: HTMLElement): HTMLElement | null;
}
```

### Step 3.2 — Platform registry

```typescript
// platforms/registry.ts
import { FacebookAdapter } from './facebook';

const adapters: PlatformAdapter[] = [
  new FacebookAdapter(),
  // Future: new InstagramAdapter(), new ThreadsAdapter(), etc.
];

export function getAdapterForUrl(url: string): PlatformAdapter | null {
  return adapters.find(a => a.matches(url)) ?? null;
}
```

### Step 3.3 — Facebook adapter

This is the most critical and fragile part. Facebook's DOM changes frequently, so the strategy uses multiple fallback approaches:

**Matching:**
```typescript
matches(url: string): boolean {
  return new URL(url).hostname.match(/facebook\.com$/) !== null;
}
```

**Post detection strategies (in priority order):**

1. **`[role="article"]` elements** — Facebook uses `role="article"` on post containers. This is an ARIA attribute and more stable than class names.

2. **Data attribute patterns** — Look for `data-ad-preview`, `data-testid` attributes that Facebook uses for testing.

3. **Structural patterns** — Posts typically follow a structure:
   - Post container with `role="article"`
   - Header: profile picture + author name + timestamp
   - Body: text content
   - Media: images/videos in a grid
   - Footer: Like/Comment/Share action bar

**Content extraction:**

```typescript
extractPost(element: HTMLElement): CollectedPost | null {
  // Author: Find the first <a> with href containing profile/user link
  // within the post header area (typically first <h2>, <h3>, or strong tag)
  const authorLink = element.querySelector('h2 a, h3 a, [data-hovercard] a');
  const authorName = authorLink?.textContent?.trim();
  const authorUrl = authorLink?.getAttribute('href');

  // Content: Find the div containing post text
  // Facebook often uses [data-ad-preview="message"] or [dir="auto"] for post text
  const contentEl = element.querySelector(
    '[data-ad-preview="message"], [data-ad-comet-above-more-options-dialog]'
  );
  // Fallback: find largest text block within the article
  const content = contentEl?.textContent?.trim() || findLargestTextBlock(element);

  // Images: All <img> within the post's media section
  // Filter out profile pics, emoji, and reaction images by size
  const images = Array.from(element.querySelectorAll('img'))
    .filter(img => {
      const rect = img.getBoundingClientRect();
      return rect.width > 100 && rect.height > 100; // Skip small images
    })
    .map(img => img.src)
    .filter(src => !src.includes('emoji') && !src.includes('rsrc'));

  // Videos: Look for <video> elements or video player containers
  const videos = Array.from(element.querySelectorAll('video'))
    .map(v => v.src)
    .filter(Boolean);

  // Timestamp: <abbr> element with datetime, or aria-label on time links
  const timeEl = element.querySelector('abbr[data-utime], a[role="link"] > span');
  const timestamp = timeEl?.getAttribute('data-utime')
    ? new Date(parseInt(timeEl.getAttribute('data-utime')!) * 1000).toISOString()
    : undefined;

  // Post URL: permalink from timestamp link or "•" menu
  const permalink = element.querySelector('a[href*="/posts/"], a[href*="/permalink/"], a[href*="story_fbid"]');
  const sourceUrl = permalink?.getAttribute('href') || window.location.href;

  return {
    source: 'facebook',
    sourceUrl: new URL(sourceUrl, window.location.origin).href,
    author: {
      name: authorName || 'Unknown',
      profileUrl: authorUrl ? new URL(authorUrl, window.location.origin).href : undefined,
    },
    content: content || '',
    images,
    videos,
    timestamp,
  };
}
```

**Button anchor:**
```typescript
getButtonAnchor(postElement: HTMLElement): HTMLElement | null {
  // Find the action bar (Like/Comment/Share) — typically a row of buttons
  // at the bottom of the post
  const actionBar = postElement.querySelector(
    '[role="button"][aria-label*="Like"], [aria-label*="Thích"]'
  )?.closest('div:has(> [role="button"])');

  return actionBar as HTMLElement | null;
}
```

**Resilience strategies:**
- Use `MutationObserver` to handle dynamically loaded posts (infinite scroll)
- Debounce observer callbacks to avoid performance issues
- Cache already-processed posts using a WeakSet
- If primary selectors fail, fall back to structural heuristics (largest img, longest text block)
- Add version timestamp to adapter — when Facebook changes break scraping, update selectors

---

## Phase 4: Content Script

### Step 4.1 — Facebook content script entrypoint

```typescript
// entrypoints/facebook.content/index.ts
import './style.css';

export default defineContentScript({
  matches: ['*://*.facebook.com/*'],
  cssInjectionMode: 'ui',

  async main(ctx) {
    const adapter = new FacebookAdapter();

    // Handle SPA navigation (Facebook is a SPA)
    ctx.addEventListener(window, 'wxt:locationchange', () => {
      scanAndInjectButtons(ctx, adapter);
    });

    // Initial scan
    scanAndInjectButtons(ctx, adapter);

    // Watch for new posts (infinite scroll, AJAX loads)
    const observer = new MutationObserver(
      debounce(() => scanAndInjectButtons(ctx, adapter), 500)
    );

    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });

    // Cleanup on context invalidation
    ctx.onInvalidated(() => observer.disconnect());
  },
});
```

### Step 4.2 — Button injection with Shadow Root

Use WXT's `createShadowRootUi()` to inject the "Send to LightNote" button isolated from Facebook's styles.

For each detected post:
1. Check if button already injected (WeakSet tracking)
2. Find button anchor (action bar)
3. Create shadow root UI with React-rendered button
4. Mount adjacent to anchor

**CollectButton component states:**
- 🔵 **Idle**: LightNote icon + "Save" text
- 🔄 **Loading**: Spinner animation
- ✅ **Success**: Checkmark + "Saved!" (auto-dismiss after 2s)
- ❌ **Error**: Red icon + "Failed" + retry option
- 🔒 **Not authenticated**: "Sign in to save" (opens popup on click)

### Step 4.3 — Optional type selection

Before sending, show a small dropdown anchored to the button:
- Default: auto-detect type based on platform ("Facebook Post")
- User can select from their existing types
- Types are fetched once and cached in storage
- "Remember this choice" checkbox to skip selector next time

---

## Phase 5: Background Service Worker

### Step 5.1 — Message definitions

Using `@webext-core/messaging`:

```typescript
// lib/messaging.ts
import { defineExtensionMessaging } from '@webext-core/messaging';

interface ProtocolMap {
  // Content → Background: collect a post
  collectPost(data: CollectedPost & { typeId?: string }): { itemId: string };

  // Content → Background: get user types (for type selector)
  getUserTypes(): Array<{ id: string; name: string }>;

  // Content → Background: check auth status
  getAuthStatus(): { authenticated: boolean; user?: { name: string } };

  // Popup → Background: initiate login
  login(): { success: boolean };

  // Popup → Background: logout
  logout(): void;
}

export const { sendMessage, onMessage } = defineExtensionMessaging<ProtocolMap>();
```

### Step 5.2 — Background handlers

```typescript
// entrypoints/background.ts
export default defineBackground(() => {
  // Handle collect post request from content script
  onMessage('collectPost', async ({ data }) => {
    const token = await accessToken.getValue();
    if (!token) throw new Error('Not authenticated');

    const response = await fetch(`${API_BASE}/api/collect`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Failed to collect post');
    }

    return response.json();
  });

  // Handle auth status check
  onMessage('getAuthStatus', async () => {
    const token = await accessToken.getValue();
    const user = await userProfile.getValue();
    return {
      authenticated: !!token,
      user: user ?? undefined,
    };
  });

  // Handle type fetching
  onMessage('getUserTypes', async () => {
    const token = await accessToken.getValue();
    if (!token) return [];

    const response = await fetch(`${API_BASE}/api/types`, {
      headers: { 'Authorization': `Bearer ${token}` },
    });

    return response.ok ? (await response.json()) : [];
  });

  // Token refresh alarm
  chrome.alarms.onAlarm.addListener(async (alarm) => {
    if (alarm.name === 'token-refresh') {
      await refreshAccessToken();
    }
  });
});
```

---

## Phase 6: Popup UI

### Step 6.1 — Popup states

**Not authenticated:**
- LightNote logo
- "Sign in with LightNote" button
- Brief description: "Collect posts from social media"

**Authenticated:**
- User avatar + name
- "Open LightNote" button (opens web app)
- Stats: "X items collected today"
- Settings link
- "Sign Out" button

### Step 6.2 — Settings (in popup or separate options page)

- API server URL (advanced, hidden by default)
- Default type for collection
- Enable/disable auto-type-detection
- Toggle notification sound on successful collection

---

## Phase 7: Data Flow (End-to-End)

Complete flow when user clicks "Save" on a Facebook post:

```
1. [Content Script] User clicks "Send to LightNote" button
2. [Content Script] FacebookAdapter.extractPost() scrapes DOM
3. [Content Script] Sends message: collectPost(postData) → Background
4. [Background]     Reads access token from storage
5. [Background]     POST /api/collect to NestJS with Bearer token
6. [NestJS]         Validates JWT via Authentik JWKS
7. [NestJS]         Resolves/creates item type ("Facebook Post")
8. [NestJS]         Creates item in Supabase
9. [NestJS]         Returns { itemId, name, ... }
10. [Background]    Returns result to content script
11. [Content Script] Shows success toast/checkmark
12. [Web App]       User opens LightNote → item visible in grid
```

---

## Phase 8: Future Platform Support

Adding a new platform (e.g., Instagram):

1. Create `platforms/instagram.ts` implementing `PlatformAdapter`
2. Register in `platforms/registry.ts`
3. Create entrypoint `entrypoints/instagram.content/index.ts`
4. Add host permission to `wxt.config.ts`: `'*://*.instagram.com/*'`
5. Add platform type definition in NestJS backend
6. Done — same message flow, same background handler

---

## Verification

### Automated tests
1. **Unit tests**: Platform adapter tests with snapshot HTML fixtures
   - Parse sample Facebook post HTML → verify extracted data
   - Test with various post layouts: text-only, single image, gallery, video, shared post
2. **Unit tests**: API client tests with mocked fetch
3. **Unit tests**: Auth flow tests with mocked chrome.identity

### Manual testing checklist
1. Install extension in Chrome → verify icon appears in toolbar
2. Click extension icon → see "Sign In" button
3. Sign in → verify tokens stored, popup shows user info
4. Navigate to Facebook → verify "Save" buttons appear on posts
5. Scroll down (infinite scroll) → new posts also get buttons
6. Click "Save" on post with:
   - [ ] Text only
   - [ ] Single image
   - [ ] Multiple images (gallery)
   - [ ] Video
   - [ ] Shared post
   - [ ] Post with long text
   - [ ] Post in Vietnamese (Unicode)
7. Verify loading → success state transition
8. Open LightNote web app → verify item appears with correct data
9. Test error handling: disconnect internet → click Save → verify error toast
10. Test token expiry: wait for token to expire → verify auto-refresh
11. Navigate between Facebook pages (SPA) → buttons should persist/re-inject

### Known risks
- **Facebook DOM instability**: Facebook changes their DOM frequently. The scraper will need periodic updates. Mitigation: use ARIA roles and data attributes (more stable), fallback heuristics, and clear error reporting when extraction fails.
- **CSP restrictions**: Facebook's Content Security Policy may block certain operations. WXT's shadow root approach avoids most CSP issues for UI injection.
- **Rate limiting**: Facebook may rate-limit image URL access. Background worker should handle 429 responses gracefully.

---

## Key Decisions

- **WXT framework**: Chosen over raw Manifest V3 for DX, HMR, SPA handling, and shadow root UI support
- **@webext-core/messaging**: Type-safe messaging between content ↔ background
- **Shadow Root UI**: Isolates button styles from Facebook's CSS
- **MutationObserver + wxt:locationchange**: Handles Facebook's SPA navigation and infinite scroll
- **OIDC via chrome.identity.launchWebAuthFlow**: Chrome-native auth flow, no popup windows needed
- **Platform adapter pattern**: Clean extensibility for future platforms without changing core code
- **Content script per platform**: Each platform gets its own content script entrypoint for isolated matching and styles
