# Prompt: Design & Build Personal Website — baole.space

> **Target AI**: Figma Make (design UI + generate code)
> **Output**: UI design (required) + production-ready code (Vite + React + TypeScript + Tailwind CSS)
> **Format**: Single-page application (SPA), no SSR, no backend

---

## 1. Project Overview

Design and build a **personal website + tools portal** for a web developer named **Bao LE**.

**Purpose (dual)**:
1. **Personal introduction** — Showcase who Bao LE is: a web developer, photographer, and gamer based in Ho Chi Minh City, Vietnam.
2. **Portal hub** — Serve as a central gateway linking to 4 web applications, each deployed on a different subdomain under `baole.space`.

**Domain**: `baole.space` (root domain — this website)
**Tech stack**: Vite + React + TypeScript + Tailwind CSS v4
**Design direction**: Gradient / Creative — vibrant, colorful, expressive. NOT minimal or monochrome.

---

## 2. Owner Profile Data

Use this structured data to populate all personal sections. Render these values — do not invent or alter them.

```yaml
name: "Bao LE"
location: "Ho Chi Minh City, Vietnam 🇻🇳"
roles:
  - "Web Developer"
  - "Photographer"
  - "FPS Gamer"
tagline: "ReactJS library maker — every problem I face becomes open source."
bio: >
  I'm Bao LE, a web developer who turns real-world problems into open-source
  libraries. Photographer at heart — I capture emotions with a permanent +0.3 EV
  bias because optimism. Veteran FPS gamer with 15+ years and countless headshots.
philosophy: '"In code we trust, in games we clutch, in photos we overexpose (+0.3 EV)"'
personality:
  - "Cheerful"
  - "Optimistic"
  - "Sociable"
interests:
  - label: "Photography"
    detail: "Always overexposing by +0.3 EV because optimism"
  - label: "Post-rock music"
    detail: "Coding sessions powered by Explosions in the Sky, This Will Destroy You, Mono"
  - label: "FPS Gaming"
    detail: "15+ years competitive, legendary sniper, clutch master"
social:
  github: "https://github.com/unique01082"
  facebook: "https://www.facebook.com/baolq.it/"
  instagram: "https://www.instagram.com/_justablue/"
  steam: "https://steamcommunity.com/id/unique01082"
  email: "bao.lq.it@gmail.com"
coding_playlist:
  title: "Coding Playlist"
  vibe: "Post-rock instrumental epicness"
  tracks:
    - "A wild river to take you home"
    - "Hidden Valley"
    - "A Gallant Gentleman"
  artists:
    - "Explosions in the Sky"
    - "This Will Destroy You"
    - "Mono"
  spotify_embed: null  # Add Spotify playlist URL here if available
resume:
  available: true
  filename: "BaoLE-Resume.pdf"
  label: "Download CV"
```

---

## 3. Tools Portal — Subdomain Applications

This is the **core portal feature**. Display these 4 applications as visually prominent cards, each linking out to its subdomain. Each card must have: icon/emoji, app name, one-line description, subdomain URL as a "Launch →" button.

```yaml
tools:
  - name: "LightDrift"
    subdomain: "lightdrift.baole.space"
    url: "https://lightdrift.baole.space"
    description: "Web-based RAW images explorer — browse, preview, and process camera RAW files right in the browser."
    icon: "📷"
    color_accent: "from-violet-500 to-fuchsia-500"

  - name: "LightNote"
    subdomain: "lightnote.baole.space"
    url: "https://lightnote.baole.space"
    description: "Photography-focused note-taking — organize shooting plans, gear lists, and editing notes."
    icon: "📝"
    color_accent: "from-amber-400 to-orange-500"

  - name: "Eldwyn"
    subdomain: "eldwyn.baole.space"
    url: "https://eldwyn.baole.space"
    description: "A digital board game — strategy, fun, and friendly competition."
    icon: "🎲"
    color_accent: "from-emerald-400 to-cyan-500"

  - name: "Cost"
    subdomain: "cost.baole.space"
    url: "https://cost.baole.space"
    description: "Simple cost tracking — log expenses, split bills, stay on budget."
    icon: "💰"
    color_accent: "from-rose-400 to-pink-500"
```

### Portal Card Design Requirements
- Cards arranged in a **2×2 grid** (desktop) → **single column** (mobile).
- Each card has a **gradient border or background** using its `color_accent`.
- On **hover**: subtle lift (translateY -4px), gradient intensifies, soft glow/shadow matching the accent color.
- Each card includes an **external link icon** next to the "Launch →" button to indicate it opens a new subdomain.
- Cards should feel like **app launcher tiles** — inviting the user to click through.

---

## 4. Featured Open-Source Projects

Display these projects in a horizontally scrollable row or responsive grid. Each project card includes: name, description, tech tags, GitHub link, and star count badge.

```yaml
projects:
  - name: "lightdrift-libraw"
    description: "Node.js Native Addon for LibRaw — process 100+ RAW image formats with JavaScript. 50+ API methods, worker thread support, buffer creation API."
    github: "https://github.com/unique01082/lightdrift-libraw"
    npm: "https://www.npmjs.com/package/lightdrift-libraw"
    stars: 7
    tags: ["Node.js", "C++", "LibRaw", "Native Addon", "Photography"]
    highlight: true

  - name: "Folder Structure Sync"
    description: "Interactive CLI tool for syncing folder structures with smart selection, dependency handling, and beautiful terminal output."
    github: "https://github.com/unique01082/folder-structure-sync"
    npm: "https://www.npmjs.com/package/folder-structure-sync"
    stars: 0
    tags: ["Node.js", "CLI", "DevTools"]

  - name: "React Twilight"
    description: "Universal Box component for React — style, props, and behavior your way. A flexible building block for design systems."
    github: "https://github.com/unique01082/react-twilight"
    stars: 1
    tags: ["React", "TypeScript", "UI Component"]

  - name: "React Instances"
    description: "Library that manages React Component instances — interact with, observe, and control components from anywhere in your app."
    github: "https://github.com/unique01082/react-instances"
    stars: 2
    tags: ["React", "State Management", "JavaScript"]

  - name: "LightDrift Photo Viewer"
    description: "Part of the LightDrift ecosystem — a dedicated web viewer for browsing and previewing RAW photography files."
    github: "https://github.com/unique01082/lightdrift-photo-viewer"
    stars: 0
    tags: ["React", "Photography", "Image Processing"]
```

### Project Card Design Requirements
- If `highlight: true`, the card gets a **special border glow** or "Featured" badge to stand out.
- Each card shows tech **tags as small pills/badges**.
- GitHub star count displayed as a subtle badge (e.g., ⭐ 7).
- NPM link shown as a small npm icon/badge if available.
- Cards have glass-morphism or frosted-glass effect over the gradient background.

---

## 5. Tech Stack Showcase

Display as an icon grid with labels. Use skill icons or simple icon representations.

```yaml
skills:
  primary:
    - { name: "TypeScript", icon: "ts" }
    - { name: "React", icon: "react" }
    - { name: "JavaScript", icon: "js" }
    - { name: "Node.js", icon: "nodejs" }
    - { name: "Java", icon: "java" }
  frontend:
    - { name: "HTML5", icon: "html" }
    - { name: "CSS3", icon: "css" }
    - { name: "Tailwind CSS", icon: "tailwind" }
    - { name: "Vite", icon: "vite" }
  tools:
    - { name: "Git", icon: "git" }
    - { name: "VS Code", icon: "vscode" }
    - { name: "NPM", icon: "npm" }
    - { name: "C++", icon: "cpp" }
```

### Tech Stack Design Requirements
- Icons arranged in a **fluid grid** that wraps naturally.
- Each icon has a **subtle hover animation** (scale up, slight glow).
- Group labels ("Primary", "Frontend", "Tools & More") displayed above each group.
- Use [skillicons.dev](https://skillicons.dev) or inline SVG icons for visual consistency.

---

## 6. Design Direction — Gradient / Creative

### Color Palette

```yaml
gradients:
  hero_bg: "linear-gradient(135deg, #0f0c29, #302b63, #24243e)"
  accent_primary: "linear-gradient(135deg, #667eea, #764ba2)"
  accent_secondary: "linear-gradient(135deg, #f093fb, #f5576c)"
  accent_tertiary: "linear-gradient(135deg, #4facfe, #00f2fe)"
  card_bg: "rgba(255, 255, 255, 0.05)"
  card_border: "rgba(255, 255, 255, 0.1)"
  text_primary: "#ffffff"
  text_secondary: "rgba(255, 255, 255, 0.7)"
  text_muted: "rgba(255, 255, 255, 0.5)"
```

### Visual Style
- **Background**: Deep dark gradient base (#0f0c29 → #302b63 → #24243e) with subtle animated gradient mesh or floating orbs/blobs.
- **Cards**: Frosted glass / glass-morphism — `backdrop-blur`, semi-transparent white backgrounds, thin white border at ~10% opacity.
- **Typography**: `Inter` or `Space Grotesk` from Google Fonts. Hero heading: 56–72px bold. Section headings: 36–48px semi-bold. Body: 16–18px regular. Use `tracking-tight` and generous `leading`.
- **Accent colors**: Vibrant gradients on buttons, card borders, badges, and decorative elements.
- **Decorative elements**: Abstract gradient blobs/circles in the background (CSS or SVG), subtle and out-of-focus to create depth.
- **Animations & micro-interactions**:
  - Hero text: fade-in + slide-up on load, optionally a typing animation cycling through roles.
  - Sections: scroll-reveal (fade-in-up) as they enter viewport.
  - Cards: hover → lift 4px + intensified shadow + gradient border glow.
  - Buttons: hover → gradient shift or shimmer effect.
  - Smooth scroll between sections triggered by navbar links.
- **Photography vibe**: Incorporate subtle camera/lens/aperture motifs as decorative elements. The overall aesthetic should feel like a portfolio viewed through a creative lens.

### Responsive Breakpoints
- **Mobile** (<640px): Single column, hamburger nav, smaller hero text (36–44px).
- **Tablet** (640–1024px): 2-column grids, condensed spacing.
- **Desktop** (>1024px): Full layout, max-width container ~1200px centered.

---

## 7. Page Sections — Layout Specification

The website is a **single-page SPA** with smooth-scroll navigation. Sections appear in this order:

### 7.1 Navbar (sticky)
- Transparent on top → solid dark (`bg-black/80 backdrop-blur`) after scroll.
- Logo/name: "bao.le" or "BL" monogram on the left.
- Nav links: About · Tools · Projects · Skills · Contact — smooth scroll to each section.
- Mobile: hamburger menu that slides in from the right.

### 7.2 Hero Section
- **Full viewport height** (`100vh`).
- Deep gradient background with animated floating gradient orbs.
- Center-aligned content:
  - Small label/badge: `📍 Ho Chi Minh City, Vietnam`
  - Main heading: "Hi, I'm **Bao LE**" (large, bold, white).
  - Animated subtitle cycling through: "Web Developer" → "Photographer (+0.3 EV)" → "FPS Veteran" → "Open Source Maker" (use typing or fade transition).
  - Tagline paragraph: the `bio` text from profile data.
  - Three CTA buttons:
    - **Primary** (gradient bg): "Explore My Tools ↓" → scrolls to Tools section.
    - **Secondary** (ghost/outline): "View on GitHub →" → links to GitHub profile.
    - **Tertiary** (small, subtle): "📄 Download CV" → downloads resume PDF (`/BaoLE-Resume.pdf`).
- Subtle scroll-down indicator at bottom (animated chevron or mouse icon).

### 7.3 About Section
- Brief personal introduction (2–3 sentences from bio).
- 3 visual "trait cards" in a row:
  - 📷 Photography — "+0.3 EV optimist, capturing emotions"
  - 💻 Code — "Turning problems into open-source libraries"
  - 🎮 Gaming — "15+ years of competitive FPS, clutch master"
- Optional: a fun quote block with the `philosophy` text.
- A subtle gradient divider or decorative element separating from next section.

### 7.3b Photography Showcase (Mini Gallery)
- A compact horizontal gallery or filmstrip-style row of 4–6 photography placeholders.
- Use placeholder images (gradient-filled cards with camera icon + "Photo 1", "Photo 2", etc.) — the owner will replace them with real photos later.
- Each placeholder card has:
  - Rounded corners, subtle shadow, aspect ratio 3:2 (landscape photography standard).
  - On hover: slight zoom-in effect on the image, caption overlay fades in ("Saigon Streets", "Golden Hour", etc. as placeholder text).
- Strip caption below the gallery: *"Shot with +0.3 EV — because the world deserves a little extra light"*
- Design should feel like a **film negative strip** or **lightbox contact sheet** — fitting the photography identity.
- If Spotify playlist URL is provided in profile data, embed a **Spotify player widget** (compact/horizontal) below the gallery. Otherwise, show a styled "Now Playing" card listing the coding playlist tracks and artists from profile data with a 🎵 icon.

### 7.3c Coding Playlist
- A small, visually appealing card (glass-morphism style) placed within or after the About section.
- Displays the `coding_playlist` data: title, artists, and track names.
- Styled like a mini music player: album art placeholder (gradient square), track list, artist names as tags.
- If `spotify_embed` URL is provided, render an actual `<iframe>` Spotify embed (compact size, ~80px height).
- If not, render a static styled card with the track/artist data and a Spotify icon linking to a search.
- This adds personality and reinforces the post-rock vibe.

### 7.4 Tools Portal Section ⭐ (Most Important)
- Section heading: "My Tools" or "The Workspace" with a short subtitle: "Apps I've built, each living on its own subdomain under baole.space"
- **2×2 grid of Tool Cards** (see Section 3 for data and design requirements).
- Below the grid, a small note: "All tools are independent web apps hosted on subdomains of baole.space"
- This section should feel visually distinct — consider a slightly different background gradient or a bordered container to highlight its importance as the portal core.

### 7.5 Featured Projects Section
- Section heading: "Open Source" with subtitle: "Every problem I face becomes a library"
- **Horizontally scrollable row** on mobile, **3-column grid** on desktop (see Section 4 for data).
- "View all on GitHub →" link at the bottom, linking to `https://github.com/unique01082?tab=repositories`.

### 7.6 Tech Stack Section
- Section heading: "Tech Stack" or "Tools of the Trade"
- Icon grid grouped by category (see Section 5 for data).
- Clean, minimal layout that lets the icons breathe.

### 7.7 Contact / Footer Section
- Section heading: "Let's Connect" with subtitle: "Always open for collaborations, conversations about code, cameras, or post-rock"
- Row of social icon buttons (GitHub, Facebook, Instagram, Steam, Email) — each with hover gradient effect.
- Email displayed as a `mailto:` link.
- "📄 Download CV" button repeated here for easy access.
- Footer bar at very bottom: `© 2026 Bao LE — Built with React + Tailwind CSS` + a small "Made with ❤️" note.

### 7.8 Custom 404 Page
- A separate route (`/404` or catch-all `*`) for when users navigate to a non-existent path.
- Design must match the main site's gradient/creative style — NOT a plain white error page.
- Content:
  - Large "404" text with gradient fill, slightly glitchy or distorted animation.
  - Heading: "Page Not Found" or a playful message like "Lost in the void..."
  - A photography-themed subtext: *"Even at +0.3 EV, we can't find this page."*
  - CTA button: "← Back to Home" linking to `/`.
  - Decorative background: same gradient orbs/blobs as hero, but slightly more chaotic/scattered to convey "lost" feeling.
- Use `react-router-dom` (or equivalent) for route handling.

### 7.9 Easter Egg 🥚
- **Konami Code** (`↑↑↓↓←→←→BA`): When the user enters the Konami code on keyboard, trigger **"+0.3 EV Mode"**:
  - The entire page's brightness increases slightly (`filter: brightness(1.15)`) with a smooth 500ms transition.
  - A toast notification appears: *"🌅 +0.3 EV Mode activated — everything's a little brighter now!"*
  - After 5 seconds, brightness returns to normal (or stays until toggled again).
- **Logo easter egg**: Clicking the navbar logo/monogram **5 times rapidly** toggles a fun mode:
  - The subtitle text in hero temporarily changes to: *"Professional Headshot Machine 🎯"*
  - Reverts after 3 seconds.
- Implementation: a `useKonamiCode` custom hook + click counter on the logo.

---

## 8. React Component Tree

Generate these components with clean separation of concerns. All data should be hardcoded as TypeScript constants (no API calls).

```
src/
├── App.tsx                    # Root component, imports all sections + router
├── main.tsx                   # Vite entry point
├── index.css                  # Tailwind directives + custom gradient utilities
├── constants/
│   ├── profile.ts             # Owner profile data (name, bio, social, playlist, resume)
│   ├── tools.ts               # Portal tools array (4 items)
│   ├── projects.ts            # Featured projects array (5 items)
│   └── skills.ts              # Tech stack data grouped by category
├── components/
│   ├── Navbar.tsx             # Sticky navbar with scroll-aware transparency + logo easter egg
│   ├── Hero.tsx               # Full-viewport hero with animated subtitle + CV download
│   ├── About.tsx              # Personal intro + trait cards + philosophy quote
│   ├── PhotoGallery.tsx       # Mini photography showcase / filmstrip gallery
│   ├── CodingPlaylist.tsx     # Post-rock playlist card (static or Spotify embed)
│   ├── ToolsPortal.tsx        # Portal section with ToolCard grid
│   ├── ToolCard.tsx           # Individual tool/app card with gradient accent
│   ├── Projects.tsx           # Featured projects section
│   ├── ProjectCard.tsx        # Individual project card with tags
│   ├── TechStack.tsx          # Skills icon grid
│   ├── Contact.tsx            # Social links + contact info + CV download
│   ├── Footer.tsx             # Copyright bar
│   ├── NotFound.tsx           # Custom 404 page matching site design
│   ├── EVModeToast.tsx        # Toast notification for +0.3 EV easter egg
│   └── ui/
│       ├── GradientButton.tsx # Reusable gradient CTA button
│       ├── GhostButton.tsx    # Reusable outline/ghost button
│       ├── Badge.tsx          # Small pill/tag component
│       ├── SectionHeading.tsx # Consistent section title + subtitle
│       └── ScrollReveal.tsx   # Wrapper that animates children on scroll-enter
├── hooks/
│   ├── useScrollPosition.ts  # Track scroll position for navbar effect
│   ├── useIntersection.ts    # IntersectionObserver hook for scroll reveal
│   └── useKonamiCode.ts      # Detect Konami code input for easter egg
└── pages/
    ├── Home.tsx               # Main landing page (all sections composed)
    └── NotFoundPage.tsx       # 404 route page
public/
├── favicon.svg                # "BL" monogram favicon (SVG for sharpness)
├── og-image.png               # Open Graph preview image (1200×630)
└── BaoLE-Resume.pdf           # Downloadable CV/resume
```

### Component Guidelines
- All components are **functional** (React FC with TypeScript).
- Use **Tailwind CSS classes** exclusively for styling — no CSS modules, no styled-components.
- Animations: prefer **CSS transitions/animations** via Tailwind's `transition-*` and `animate-*` utilities. If complex animation is needed, use **Framer Motion** (`framer-motion` package).
- No external UI library (no Material UI, no Chakra, no shadcn/ui). Build from scratch with Tailwind.
- All interactive elements must be **keyboard accessible** with visible focus rings.

---

## 9. Code Generation Requirements

```yaml
build_tool: "Vite 6+"
framework: "React 19+"
language: "TypeScript (strict mode)"
styling: "Tailwind CSS v4"
animation: "CSS transitions + Framer Motion (optional)"
fonts: "Inter or Space Grotesk via Google Fonts CDN"
icons: "Lucide React or inline SVG"
package_manager: "npm"
routing: "react-router-dom v7 (for 404 page catch-all route)"
deployment_target: "Static hosting (Vercel / Cloudflare Pages / Nginx)"
```

### SEO & Open Graph Metadata
Add to `index.html`:
- `<title>`: "Bao LE — Web Developer, Photographer & Open Source Maker"
- `<meta name="description">`: "Personal website and tools portal of Bao LE. Explore LightDrift, LightNote, Eldwyn, and more."
- `<meta name="theme-color" content="#302b63">`
- **Open Graph tags** (for Facebook/Discord/LinkedIn previews):
  - `og:title`: "Bao LE — baole.space"
  - `og:description`: "Web developer turning problems into open-source libraries. Photographer at heart. FPS veteran."
  - `og:image`: `/og-image.png` (1200×630, gradient background with "Bao LE" text and tagline — generate this as a static image or placeholder)
  - `og:url`: "https://baole.space"
  - `og:type`: "website"
- **Twitter Card tags**:
  - `twitter:card`: "summary_large_image"
  - `twitter:title`, `twitter:description`, `twitter:image`: same as OG values
- **Canonical URL**: `<link rel="canonical" href="https://baole.space" />`

### Favicon & Branding
- **Favicon**: An SVG favicon (`/favicon.svg`) featuring a "BL" monogram with gradient fill matching the site's accent colors. Also provide a fallback `favicon.ico` (32×32).
- **Apple touch icon**: 180×180 PNG version of the monogram.
- **Browser tab title**: "Bao LE — baole.space"
- **Manifest** (optional): `site.webmanifest` with name, short_name, theme_color, background_color.
- Add all favicon/meta tags to `index.html` `<head>`.

### Code Quality
- Clean, readable, idiomatic TypeScript/React.
- Consistent naming: PascalCase for components, camelCase for functions/variables.
- Each component in its own file — no god-components.
- Data separated from presentation (constants/ folder).
- Semantic HTML (`<header>`, `<main>`, `<section>`, `<footer>`, `<nav>`).
- Accessible: proper `aria-label` on icon buttons, sufficient color contrast (≥ 4.5:1 for text), alt text on images.
- Responsive: mobile-first approach with Tailwind's responsive prefixes (`sm:`, `md:`, `lg:`).

### Vite Configuration
- Standard `vite.config.ts` with React plugin.
- Tailwind CSS configured via `@tailwindcss/vite` plugin or PostCSS.
- Path alias: `@/` → `src/`.
- Build output: `dist/` folder, ready for static deployment.

---

## 10. Acceptance Criteria

The generated output must satisfy ALL of the following:

- [ ] **Portal cards**: All 4 subdomain tools (LightDrift, LightNote, Eldwyn, Cost) are displayed as interactive cards with working external links.
- [ ] **Projects**: At least 5 open-source projects rendered with GitHub links, descriptions, and tech tags.
- [ ] **Profile**: Owner's name, bio, location, and all 5 social links are present and correct.
- [ ] **Gradient/Creative design**: The website uses vibrant gradients, glass-morphism cards, and decorative background elements — it is NOT a plain white or plain black page.
- [ ] **Responsive**: Layout works correctly on mobile (360px), tablet (768px), and desktop (1440px).
- [ ] **Smooth navigation**: Navbar links scroll smoothly to corresponding sections.
- [ ] **Animations**: At least hero text animation, card hover effects, and scroll-reveal on sections.
- [ ] **Accessibility**: Keyboard navigable, focus rings visible, color contrast compliant.
- [ ] **Clean code**: Components properly separated, TypeScript strict, no `any` types, data in constants.
- [ ] **Build succeeds**: `npm run build` completes without errors.
- [ ] **SEO & OG tags**: `index.html` contains title, meta description, Open Graph tags, Twitter Card tags, and canonical URL.
- [ ] **Favicon**: SVG favicon with "BL" monogram is present in `public/` and linked in `index.html`.
- [ ] **Photography gallery**: A mini gallery/filmstrip section with 4–6 placeholder image cards is rendered between About and Tools sections.
- [ ] **Coding playlist**: A styled playlist card showing post-rock tracks/artists appears in or near the About section.
- [ ] **Resume download**: A "Download CV" button exists in the Hero section and Contact section, linking to `/BaoLE-Resume.pdf`.
- [ ] **404 page**: Navigating to a non-existent route shows a custom-designed 404 page matching the site's gradient style, with a "Back to Home" button.
- [ ] **Easter egg**: Entering the Konami code activates "+0.3 EV Mode" (brightness increase + toast notification). Clicking the logo 5 times triggers a fun subtitle change.

---

## 11. Reference Mood & Inspiration

The overall vibe should combine:
- **Developer portfolio** aesthetics (gradient hero, tech stack grid, project cards)
- **Photography portfolio** warmth (the "+0.3 EV overexposure" metaphor — things are a bit brighter, warmer, more optimistic than expected)
- **App launcher / dashboard** feel for the Tools Portal section (think macOS Launchpad or a personalized start page)

The website should feel like visiting a creative developer's digital home — polished, personal, welcoming, and a gateway to their world of tools and creations.

---

*End of prompt. Generate both the UI design and the complete, production-ready codebase.*
