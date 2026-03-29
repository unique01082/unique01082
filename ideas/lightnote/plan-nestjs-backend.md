# LightNote API — NestJS Backend Plan

## Overview

Build a NestJS backend (`lightnote-api`) as the central API layer between all clients (Chrome extension, web app) and Supabase. The backend handles authentication validation, data processing, image proxying, and business logic — replacing direct Supabase access from the frontend over time.

**Repo**: `lightnote-api` (separate repo)
**Runtime**: Node.js 20+
**Framework**: NestJS 10+ with TypeScript strict mode

---

## Architecture

```
┌──────────────────┐     ┌──────────────────────┐     ┌─────────────┐
│ Chrome Extension │────▶│   NestJS Backend      │────▶│  Supabase   │
│ (lightnote-ext)  │     │   (lightnote-api)     │     │  (Database) │
└──────────────────┘     │                       │     └─────────────┘
                         │  - Auth (JWT/OIDC)    │
┌──────────────────┐     │  - Items CRUD         │     ┌─────────────┐
│ Web App          │────▶│  - Types CRUD         │────▶│ File Server │
│ (lightnote.space)│     │  - Albums CRUD        │     │   (TBD)     │
└──────────────────┘     │  - Collect endpoint   │     └─────────────┘
                         │  - Marketplace        │
                         └──────────────────────┘
                                   ▲
                                   │
                          ┌────────────────┐
                          │   Authentik     │
                          │   (OIDC/JWKS)  │
                          └────────────────┘
```

---

## Phase 1: Project Scaffolding

### Step 1.1 — Initialize NestJS project

```
nest new lightnote-api --strict --package-manager pnpm
```

### Step 1.2 — Dependencies

**Core:**
- `@nestjs/config` — environment variables
- `@nestjs/passport`, `passport`, `passport-jwt` — JWT auth strategy
- `jwks-rsa` — fetch Authentik's signing keys dynamically
- `@supabase/supabase-js` — Supabase client (service role)
- `class-validator`, `class-transformer` — DTO validation
- `@nestjs/throttler` — rate limiting

**Dev:**
- `@nestjs/testing`, `jest`, `supertest` — testing
- `eslint`, `prettier` — code quality

### Step 1.3 — Environment variables

```env
# Server
PORT=3000
NODE_ENV=development

# Supabase (service role key — full access)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_KEY=eyJ...

# Authentik OIDC
AUTHENTIK_ISSUER=https://authentik.example.com/application/o/lightnote/
# JWKS endpoint is derived: {AUTHENTIK_ISSUER}/.well-known/openid-configuration

# File server (TBD — placeholder)
FILE_SERVER_URL=
FILE_SERVER_API_KEY=

# CORS
CORS_ORIGINS=http://localhost:5173,chrome-extension://EXTENSION_ID
```

### Step 1.4 — Project structure

```
lightnote-api/
├── src/
│   ├── main.ts                      # Bootstrap, CORS, global pipes
│   ├── app.module.ts                # Root module
│   ├── config/
│   │   └── configuration.ts         # Typed config
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── jwt.strategy.ts          # Passport JWT strategy using JWKS
│   │   ├── jwt-auth.guard.ts        # Global auth guard
│   │   └── current-user.decorator.ts # @CurrentUser() param decorator
│   ├── supabase/
│   │   ├── supabase.module.ts       # Global Supabase provider
│   │   └── supabase.service.ts      # Supabase client wrapper
│   ├── items/
│   │   ├── items.module.ts
│   │   ├── items.controller.ts      # REST endpoints
│   │   ├── items.service.ts         # Business logic
│   │   └── dto/
│   │       ├── create-item.dto.ts
│   │       └── update-item.dto.ts
│   ├── types/
│   │   ├── types.module.ts
│   │   ├── types.controller.ts
│   │   ├── types.service.ts
│   │   └── dto/
│   │       ├── create-type.dto.ts
│   │       └── update-type.dto.ts
│   ├── albums/
│   │   ├── albums.module.ts
│   │   ├── albums.controller.ts
│   │   ├── albums.service.ts
│   │   └── dto/
│   │       ├── create-album.dto.ts
│   │       └── update-album.dto.ts
│   ├── collect/
│   │   ├── collect.module.ts
│   │   ├── collect.controller.ts    # POST /api/collect
│   │   ├── collect.service.ts       # Main processing pipeline
│   │   └── dto/
│   │       └── collect-post.dto.ts  # Input validation
│   ├── marketplace/
│   │   ├── marketplace.module.ts
│   │   ├── marketplace.controller.ts
│   │   └── marketplace.service.ts
│   └── shared/
│       ├── interfaces/
│       │   ├── user-payload.interface.ts
│       │   └── supabase-tables.interface.ts
│       └── filters/
│           └── http-exception.filter.ts
├── test/
│   ├── auth.e2e-spec.ts
│   ├── items.e2e-spec.ts
│   └── collect.e2e-spec.ts
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── package.json
```

---

## Phase 2: Auth Module

### Step 2.1 — JWT Strategy with JWKS

The strategy uses `jwks-rsa` to dynamically fetch Authentik's public keys and validate JWT tokens.

**jwt.strategy.ts** implementation approach:
- Use `passportJwtSecret` from `jwks-rsa` to auto-fetch signing keys from Authentik's JWKS endpoint
- Validate: `issuer` must match `AUTHENTIK_ISSUER`, `algorithms: ['RS256']`
- Extract from token: `sub`, `email`, `name`, `preferred_username`
- Return a `UserPayload` object attached to request

**UserPayload interface:**
```typescript
interface UserPayload {
  sub: string;        // Unique user ID from Authentik
  email: string;
  name: string;
  username?: string;
}
```

### Step 2.2 — JwtAuthGuard

- Global guard applied via `APP_GUARD` provider
- Excludes health check endpoint (`GET /health`)
- All other routes require valid Bearer token

### Step 2.3 — @CurrentUser() decorator

- Custom param decorator that extracts user from `request.user`
- Usage: `@CurrentUser() user: UserPayload`

### Step 2.4 — User profile auto-sync

- Middleware or interceptor: on each authenticated request, upsert `user_profiles` in Supabase
- Fields: `sub`, `email`, `name`, `avatar_url`
- Use "last_seen_at" timestamp to avoid updating on every request (only update if >1 hour since last sync)
- Match the existing web app behavior in `AuthContext.tsx` → `syncProfile()` function

---

## Phase 3: Supabase Module

### Step 3.1 — Supabase service

- Singleton service providing Supabase client initialized with `SUPABASE_SERVICE_KEY`
- Service role key bypasses RLS — the backend enforces access control via `user_sub` filtering
- Expose `getClient()` method for other services

### Step 3.2 — Database tables (existing)

Current Supabase schema (reference from existing web app):

```
items
├── id: uuid (PK)
├── user_sub: text (FK → user_profiles)
├── name: text
├── type: text (FK → item_types.id)
├── tone: text
├── vibe: text
├── description: text
├── effect: text
├── images: text[]
├── links: text[]
├── palette: text[]
├── custom_data: jsonb
├── created_at: timestamptz
└── is_public: boolean

item_types
├── id: uuid (PK)
├── user_sub: text
├── name: text
├── icon: text
└── (has many custom_properties)

custom_properties
├── id: uuid (PK)
├── item_type_id: uuid (FK → item_types)
├── name: text
├── type: text (text|textarea|number|select)
├── options: text[]
├── required: boolean
└── sort_order: integer

albums
├── id: uuid (PK)
├── user_sub: text
├── name: text
├── description: text
├── author: text
├── link: text
├── cover_image: text
├── photos: text[]
├── created_at: timestamptz
└── updated_at: timestamptz

album_items (junction)
├── album_id: uuid (FK)
└── item_id: uuid (FK)

user_profiles
├── sub: text (PK)
├── email: text
├── name: text
├── avatar_url: text
└── role: text (user|admin)

ratings
├── id: uuid (PK)
├── item_id: uuid (FK)
├── user_sub: text
├── rating: integer (1-5)
├── review: text
└── created_at: timestamptz
```

---

## Phase 4: Core API Modules

### Step 4.1 — Items Module

**Endpoints:**
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/items | List user's items (paginated, filterable) |
| GET | /api/items/:id | Get single item |
| POST | /api/items | Create item |
| PUT | /api/items/:id | Update item |
| DELETE | /api/items/:id | Delete item |

**CreateItemDto:**
- `name`: string, required, maxLength 255
- `type`: string, required (item_type ID)
- `tone`: string, optional
- `vibe`: string, optional
- `description`: string, required
- `effect`: string, optional
- `images`: string[], required (URLs)
- `links`: string[], optional
- `palette`: string[], optional (hex codes)
- `customData`: Record<string, string | number>, optional

**Business logic:**
- All queries filter by `user_sub` from JWT
- Auto-set `created_at` and `user_sub` on create
- `is_public` defaults to false
- Map between camelCase (API) ↔ snake_case (Supabase)

Reference: `ApiService.createItem()` in existing `src/app/services/api.ts`

### Step 4.2 — Types Module

**Endpoints:**
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/types | List user's types with custom properties |
| POST | /api/types | Create type + custom properties |
| PUT | /api/types/:id | Update type + properties |
| DELETE | /api/types/:id | Delete type (cascade properties) |

**Business logic:**
- When creating type: insert into `item_types`, then batch insert `custom_properties`
- When updating: update type metadata, diff custom properties (add/update/remove)
- When deleting: delete type and all associated custom_properties (cascade)
- Default types provisioning: on first GET, if user has 0 types, auto-create the 3 defaults (Color Profile, Preset, Color Style) from `src/app/constants/defaults.ts`

### Step 4.3 — Albums Module

**Endpoints:**
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/albums | List user's albums with linked item IDs |
| GET | /api/albums/:id | Get single album (with full linked items) |
| POST | /api/albums | Create album |
| PUT | /api/albums/:id | Update album |
| DELETE | /api/albums/:id | Delete album |

**Business logic:**
- Junction table `album_items` managed automatically
- On update: delete old links, insert new ones
- On delete: delete album + all junction entries

### Step 4.4 — Marketplace Module

**Endpoints:**
| Method | Path | Description |
|--------|------|-------------|
| GET | /api/marketplace | List public items with ratings |
| POST | /api/marketplace/:id/rate | Rate a public item |
| PUT | /api/items/:id/publish | Toggle item is_public |

---

## Phase 5: Collect Module (Extension-focused)

This is the core endpoint that the Chrome extension calls.

### Step 5.1 — Collect DTO

```typescript
// collect-post.dto.ts
class CollectPostDto {
  source: 'facebook' | 'instagram' | 'threads' | '500px';  // platform
  sourceUrl: string;           // permalink to original post
  author: {
    name: string;
    profileUrl?: string;
  };
  content: string;             // post text content
  images: string[];            // original image URLs from platform
  videos?: string[];           // video URLs (if any)
  timestamp?: string;          // original post creation time (ISO)
  typeId?: string;             // optional: user-chosen type ID
}
```

### Step 5.2 — Processing pipeline

`POST /api/collect` flow:

1. **Validate & sanitize** — class-validator validates DTO, sanitize HTML from content
2. **Resolve type** — If `typeId` provided, verify it exists for user. If not provided, find or create platform-specific type:
   - Look for existing type with name matching platform (e.g., "Facebook Post")
   - If not found, auto-create it with platform-specific custom properties
3. **Process images** — (Phase 2 - when file server is configured)
   - Download images from source URLs
   - Upload to file server
   - Store permanent URLs
   - For now: store original source URLs directly
4. **Create item** — Map collected data to item structure:
   ```
   name: truncated content (first 80 chars) or "Facebook Post — {date}"
   description: full content text
   images: processed image URLs
   links: [sourceUrl, author.profileUrl]
   customData: { Author: author.name, "Source URL": sourceUrl, Platform: source }
   ```
5. **Return response** — Created item with ID

### Step 5.3 — Platform type definitions

Auto-created types for each platform:

**Facebook Post:**
- Icon: `FileText`
- Custom properties:
  - `Author` (text, required)
  - `Source URL` (text)
  - `Platform` (select: Facebook, Instagram, Threads, 500px)
  - `Original Date` (text)

**Instagram Post** (future):
- Similar structure, potentially with `Hashtags` (textarea) property

### Step 5.4 — Rate limiting

- Use `@nestjs/throttler` on collect endpoint
- Limit: 30 requests per minute per user
- Return 429 Too Many Requests with clear error message

---

## Phase 6: CORS & Security

### Step 6.1 — CORS configuration

```typescript
// main.ts
app.enableCors({
  origin: configService.get('CORS_ORIGINS').split(','),
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Authorization', 'Content-Type'],
  credentials: true,
});
```

### Step 6.2 — Security middleware

- Helmet for HTTP headers
- Rate limiting (global + per-endpoint)
- Input validation on all DTOs (class-validator with whitelist: true, forbidNonWhitelisted: true)
- Global exception filter for consistent error responses

---

## Phase 7: Docker & Deploy

### Step 7.1 — Dockerfile

Multi-stage build: Node 20 → build → Node 20-slim runtime

### Step 7.2 — docker-compose.yml

For local dev: NestJS + env variables

---

## Verification

1. **Unit tests**: Each service method tested with mocked Supabase client
2. **Integration tests**: Auth flow with mocked JWKS endpoint
3. **E2E tests**:
   - `POST /api/collect` with sample Facebook post data → verify item created
   - `GET /api/items` → returns items scoped to user
   - `POST /api/items` → creates item with all fields
   - Unauthorized request → 401
   - Rate limit test on /api/collect
4. **Manual testing**: Use Postman/Bruno collection with real Authentik tokens

---

## Key Decisions

- **Service role key**: Backend uses Supabase service role key (bypasses RLS) and enforces access control in code via `user_sub` filtering
- **camelCase API ↔ snake_case DB**: Mapping layer in each service
- **Gradual migration**: Web app continues using direct Supabase initially; migrate endpoint by endpoint to NestJS
- **Type auto-creation**: Platform-specific types created lazily on first collect
- **Image handling**: Start with source URLs, add file server upload when ready
