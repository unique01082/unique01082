# Prompt: Design & Build LightNote — Photography Note-Taking App

> **Target AI**: Figma Make (design UI + generate code)
> **Output**: UI design (required) + production-ready code (Vite + React + TypeScript + Tailwind CSS)
> **Format**: Single-page application (SPA) with client-side routing, no SSR, no backend
> **Data persistence**: localStorage (with abstraction layer supporting future REST API / Firebase)

---

## 1. Project Overview

Design and build **LightNote** — a photography-focused note-taking web application for photographers who want to organize and manage their Lightroom presets, color profiles, color styles, and photo albums in one beautiful interface.

**Purpose**: Help photographers catalog, describe, and reference their editing styles (presets, profiles, color grades) with rich metadata, reference images, external links, and organized albums.

**App name**: LightNote
**Tagline**: "Organize your light, perfect your style"
**Domain**: `lightnote.baole.space`
**Tech stack**: Vite + React + TypeScript + Tailwind CSS v4
**Design direction**: Gradient / Creative — vibrant, colorful, expressive. Inspired by photography aesthetics with warm tones, lens flares, and light-themed motifs. NOT minimal or monochrome.

---

## 2. Core Data Models

These are the data structures that power the entire application. All data is stored in `localStorage` initially, with an API abstraction layer that can switch to RESTful or Firebase backends.

```yaml
CustomProperty:
  id: string
  name: string
  type: "text" | "textarea" | "number" | "select"
  options: string[]  # Only for select type

ItemType:
  id: string          # e.g., "profile", "preset", "style"
  name: string        # e.g., "Color Profile", "Preset", "Color Style"
  icon: string        # "palette" | "camera" | "sparkles" | "image"
  customProperties: CustomProperty[]

LightroomItem:
  id: string
  name: string
  type: string        # References ItemType.id
  tone: string        # e.g., "Warm", "Cool", "Neutral"
  description: string
  effect: string      # Visual effect description
  vibe: string        # e.g., "Moody", "Bright", "Vintage"
  images: string[]    # Base64 data URIs or HTTP URLs for reference images
  links: string[]     # External reference URLs (tutorials, downloads, etc.)
  customData: Record<string, any>  # Dynamic fields from CustomProperty
  createdAt: string   # ISO date string

Album:
  id: string
  name: string
  description: string
  author: string
  link: string        # External link
  coverImage: string  # Base64 or URL
  photos: string[]    # Array of image URLs or base64
  linkedItems: string[]  # Array of LightroomItem IDs linked to this album
  createdAt: string
  updatedAt: string
```

### Default Item Types (pre-configured)

```yaml
defaultTypes:
  - id: "profile"
    name: "Color Profile"
    icon: "palette"
    customProperties:
      - { id: "camera-compatibility", name: "Camera Compatibility", type: "text" }
      - id: "color-science"
        name: "Color Science"
        type: "select"
        options: ["Adobe Standard", "Camera Standard", "Vivid", "Neutral", "Faithful", "Monochrome"]

  - id: "preset"
    name: "Preset"
    icon: "camera"
    customProperties:
      - { id: "author", name: "Author", type: "text" }
      - id: "genre"
        name: "Genre"
        type: "select"
        options: ["Portrait", "Landscape", "Street", "Wedding", "Fashion", "Travel"]
      - { id: "price", name: "Price", type: "number" }

  - id: "style"
    name: "Color Style"
    icon: "sparkles"
    customProperties:
      - { id: "intensity", name: "Intensity", type: "select", options: ["Subtle", "Medium", "Strong"] }
      - { id: "best-for", name: "Best For", type: "textarea" }
```

---

## 3. Application Pages & Routes

The app has **4 main views** connected via client-side routing (`react-router-dom v7`):

```yaml
routes:
  - path: "/"
    name: "Home / Items Dashboard"
    description: "Main dashboard showing all Lightroom items (presets, profiles, styles) with search, filter tabs, and CRUD operations"

  - path: "/albums"
    name: "Albums Gallery"
    description: "Grid of photo albums with cover images, search, and CRUD operations"

  - path: "/albums/:id"
    name: "Album Detail"
    description: "Detailed view of a single album with metadata sidebar, photo grid, and linked items"

  - path: "/settings"
    name: "Settings"
    description: "Manage item types & custom properties, theme preferences, data management (export/backup)"

  - path: "*"
    name: "404 Not Found"
    description: "Custom-designed 404 page matching the gradient/creative style"
```

---

## 4. Page-by-Page Design Specification

### 4.1 Home — Items Dashboard (route: `/`)

This is the main view and the heart of the application.

#### 4.1.1 Header / Navbar (shared across all pages)
- **Sticky** at top with `backdrop-blur` and semi-transparent background.
- In dark mode: `bg-black/60 backdrop-blur-xl` with subtle bottom border glow.
- In light mode: `bg-white/70 backdrop-blur-xl` with soft shadow.
- **Left side**: App logo + name.
  - Logo: A stylized aperture/lens icon with gradient fill (`from-amber-400 to-orange-500`), inside a rounded-lg container.
  - App name: "LightNote" in bold, gradient text (`from-amber-400 to-orange-600`).
- **Right side (desktop)**: Navigation buttons + theme toggle.
  - "Albums" button with image icon.
  - "Settings" button with gear icon.
  - Light/Dark mode toggle (sun/moon icon) with smooth rotation animation.
- **Right side (mobile)**: Theme toggle + hamburger menu icon.
  - Hamburger opens a **slide-in sheet** from the right with full navigation links.
- **Navbar transitions**: On scroll down, navbar gets more opaque and adds a subtle gradient border at the bottom.

#### 4.1.2 Search Bar
- Positioned below navbar, max-width `md` (28rem), with left-aligned layout.
- Has a search icon inside the input field (left side).
- Glass-morphism style input: semi-transparent background, subtle border glow on focus.
- Focus state: gradient border ring (`from-amber-400 to-orange-500`).
- Placeholder: "Search presets, profiles, styles..."
- **Real-time filtering**: filters items by name, description, tone, vibe, effect, and custom data values.

#### 4.1.3 Toolbar Row (Add Button + Sort + View Toggle)
A horizontal row below the search bar containing three elements:

**Add Item Button (left):**
- Prominent gradient button: `from-amber-400 to-orange-500` background, white text.
- Icon: Plus (+) icon on the left.
- Label: "Add New Item"
- On hover: gradient shifts slightly, subtle lift (translateY -2px), shadow intensifies.
- On click: opens the **Add/Edit Item Dialog** (see Section 5.1).
- **Keyboard shortcut**: `Ctrl+N` (or `Cmd+N` on Mac) opens this dialog from anywhere in the app.

**Sort Dropdown (center-right):**
- Glass-morphism styled select dropdown, compact size.
- Icon: ArrowUpDown (sort icon) on the left.
- Sort options:
  - "Newest First" (default) — sort by `createdAt` descending
  - "Oldest First" — sort by `createdAt` ascending
  - "Name A–Z" — alphabetical by name
  - "Name Z–A" — reverse alphabetical
  - "Type" — grouped by item type
- Active sort option displayed in the trigger button.
- Sort preference persists in `localStorage`.

**View Toggle (right):**
- Two icon buttons side by side: Grid icon | List icon.
- Active view has gradient background fill; inactive is ghost/outline.
- **Grid view** (default): The standard card grid layout described in 4.1.5.
- **List view**: Compact horizontal rows, one item per row:
  - Each row shows: type icon + item name + tone + vibe + image count + link count + action buttons.
  - Rows have subtle hover highlight and glass-morphism row styling.
  - More items visible at once — optimized for quick scanning.
- View preference persists in `localStorage`.
- Smooth transition animation when switching views.

#### 4.1.4 Filter Tabs
- Horizontal tab bar spanning full width.
- Tabs: **All** | **Color Profile** | **Preset** | **Color Style** | (+ any user-created types)
- Each tab shows its icon + name + item count in parentheses, e.g., "🎨 Color Profile (5)"
- Active tab has gradient bottom border and gradient text color.
- Inactive tabs: muted text, hover shows subtle glow.
- On mobile: horizontally scrollable if tabs overflow.
- Tabs are **dynamically generated** from the `types` data — new types added in Settings automatically appear here.

#### 4.1.5 Item Cards Grid
- **Responsive grid**: 1 column (mobile) → 2 columns (sm) → 3 columns (lg) → 4 columns (xl).
- Gap: `gap-6`.
- **Empty state**: When no items match filters, show a centered illustration with muted icon, heading "No items found", description text, and a CTA to add a new item.

##### Individual Item Card Design
- **Glass-morphism card**: Semi-transparent background (`bg-white/5` dark, `bg-white/80` light), `backdrop-blur-md`, thin border at 10% opacity.
- **Hover effect**: Lift 4px (`translateY(-4px)`), border glows with gradient matching the item type's accent color, shadow intensifies.
- **Card layout** (top to bottom):
  1. **Header row**: Type badge (left) + action buttons (right, visible on hover).
     - Type badge: Small pill with icon + type name. Colors:
       - `palette` → orange gradient badge
       - `camera` → blue gradient badge
       - `sparkles` → purple gradient badge
       - `image` → green gradient badge
     - Action buttons (appear on hover with smooth opacity transition):
       - Edit button (gear icon) → opens Edit dialog
       - Delete button (trash icon, red) → opens confirmation dialog
  2. **Item name**: Bold, clickable (opens Edit dialog), truncated if long.
  3. **Reference Images Section** (if images exist):
     - Header: "📷 Images (N)" with "View" button on the right.
     - 3-column grid of square thumbnails (max 6 shown).
     - Each thumbnail: rounded corners, border, hover zoom-in effect.
     - If more than 6 images: show "+N" overflow indicator.
     - Clicking any thumbnail or "View" opens the **Image Viewer** (full-screen lightbox).
  4. **Description**: 2-line clamp, muted text.
  5. **Tone & Vibe row**: Two-column layout showing "Tone: Warm" and "Vibe: Moody" (truncated).
  6. **Effect**: "Effect: ..." with 2-line clamp.
  7. **Links Section** (if links exist):
     - Header: "🔗 Links (N)"
     - Show first 2 links as clickable pills with external link icon, auto-detected link type coloring:
       - `tutorial` (YouTube): green
       - `inspiration` (Instagram): purple
       - `portfolio` (Behance/Dribbble): blue
       - `official` (Adobe): orange
       - `download`: red
       - `reference`: gray
     - "+N more" indicator if more than 2 links.
  8. **Related Albums** (if the item is linked from any album):
     - Header: "📁 Related Albums (N)"
     - Show first 2 album names as clickable badges linking to `/albums/:id`.

#### 4.1.6 Delete Confirmation Dialog
- Modal overlay with backdrop blur.
- Glass-morphism styled dialog box.
- Warning icon at top.
- Title: "Delete Item"
- Description: 'Are you sure you want to delete "[item name]"? This action cannot be undone.'
- Two buttons: "Cancel" (ghost/outline) and "Delete" (red gradient, destructive).

---

### 4.2 Albums Gallery (route: `/albums`)

#### 4.2.1 Header
- Same shared navbar as Home.
- Back arrow button linking to `/`.
- Page icon: Image/gallery icon with gradient coloring.
- Page title: "Albums" in bold.
- Right side: Theme toggle + "Create Album" button (gradient, with plus icon).

#### 4.2.2 Search
- Same glass-morphism search bar style as Home.
- Placeholder: "Search albums..."
- Filters by album name, description, and author.

#### 4.2.3 Album Cards Grid
- **Responsive grid**: 1 column (mobile) → 2 columns (sm) → 3 columns (lg) → 4 columns (xl).
- **Empty state**: Centered illustration + "No albums found" + "Create Album" button.

##### Individual Album Card Design
- Glass-morphism card with hover lift effect.
- **Layout** (top to bottom):
  1. **Header**: Album name (clickable link to `/albums/:id`) + author name + hover action buttons (edit, delete).
  2. **Cover Image**: Aspect ratio 16:9 (video-like), rounded corners, border. Click navigates to album detail.
     - If no cover: placeholder with image icon + "No cover image" text, gradient placeholder background.
     - On hover: subtle opacity change.
  3. **Description**: 2-line clamp.
  4. **Linked Items**: Badge pills showing linked preset/profile/style names (max 3, "+N more").
  5. **Footer row**: Photo count on left ("12 photos"), "View Photos" button + external link icon on right.

#### 4.2.4 Create Album Dialog
See Section 5.2.

---

### 4.3 Album Detail (route: `/albums/:id`)

#### 4.3.1 Header
- Back arrow → `/albums`
- Album name as page title + author subtitle.
- Right side: Theme toggle + "Edit" button + "Delete" button (destructive outline).

#### 4.3.2 Layout: Two-Column (desktop) / Single Column (mobile)

**Left Sidebar (1/3 width on desktop):**
- **Cover Image Card**: Square aspect ratio, rounded, clickable to open in Image Viewer.
  - Gradient overlay on hover.
  - If no cover: placeholder with gradient background + camera icon.
- **Metadata Section** below cover:
  - Description paragraph.
  - Created date with calendar icon.
  - Author with user icon.
  - External link (if exists) with link icon.
  - **Related Items list**: Each shows icon matching type + item name + type label. Styled as interactive list items.

**Right Content (2/3 width on desktop):**
- **Photos section card**:
  - Header: "Photos (N)" + "View All" button (opens Image Viewer with all photos).
  - Empty state: illustration + "No photos yet" + "Edit Album" button.
  - Photo grid: 2 columns (mobile) → 3 columns (sm) → 4 columns (md). Square aspect ratio thumbnails with rounded corners.
  - Each photo: hover opacity effect, click opens Image Viewer at that index.

---

### 4.4 Settings (route: `/settings`)

#### 4.4.1 Header
- Back arrow → `/`
- Settings icon + "Settings" title.
- Theme toggle on right.

#### 4.4.2 Settings Sections (stacked cards)

**Card 1: Item Types & Custom Properties**
- Title: "Item Types & Custom Properties"
- Description: Explain that users can manage their item types and define custom properties.
- Show type count: "You currently have N types configured."
- Grid of type preview cards (1 col mobile, 2 col sm, 3 col lg):
  - Each shows: type name, custom property count, first 2 property names as bullets.
  - Glass-morphism style with gradient left border matching type color.
- "Manage Types & Properties" button → opens **Type Management Dialog** (Section 5.3).

**Card 2: Appearance**
- Title: "Appearance"
- Description text.
- Theme toggle row with label + description + toggle button.
- Visual preview: small mockup showing current theme.

**Card 3: Data Management**
- Title: "Data Management"
- Description: "Export or import your data. All items, albums, and type configurations are included."
- Three sub-cards in a responsive grid (1 col mobile, 3 col desktop):
  - **Storage**: "Currently using local browser storage" + storage usage indicator (e.g., "~2.4 MB used") + "Configure Storage" button (disabled/coming soon with "Coming Soon" badge).
  - **Export**: "Download all your data as a JSON file" + "Export Data" button (active, gradient-styled).
    - On click: exports all localStorage data (`lightroom-items`, `lightroom-albums`, `lightroom-types`) as a single JSON file named `lightnote-backup-YYYY-MM-DD.json`.
    - Shows success toast: "Data exported successfully! File saved."
  - **Import**: "Restore data from a previously exported JSON file" + "Import Data" button (active, outline-styled).
    - On click: opens a file picker accepting `.json` files.
    - After file selection: shows a **confirmation dialog** with:
      - Warning icon
      - Message: "This will replace all existing data with the imported file. This action cannot be undone."
      - Option checkboxes: "Import Items (N items)", "Import Albums (N albums)", "Import Types (N types)" — all checked by default, user can uncheck to skip.
      - "Cancel" and "Import" buttons.
    - On import: validates JSON structure, overwrites selected data in localStorage, reloads app state.
    - Shows success toast: "Data imported successfully! N items, N albums, N types restored."
    - Shows error toast if file is invalid: "Invalid backup file. Please select a valid LightNote export."
- All sub-cards have subtle gradient borders.

---

### 4.5 Custom 404 Page (route: `*`)
- Matches the app's gradient/creative style.
- Large "404" text with gradient fill (amber → orange → pink), slightly animated (subtle pulse or float).
- Heading: "Page Not Found"
- Subtext: *"This preset seems to be missing from your library..."*
- Photography-themed decorative element: abstract aperture/lens bokeh blobs in background.
- CTA button: "← Back to Home" with gradient styling, linking to `/`.
- Same deep gradient background as the rest of the app.

---

## 5. Dialog / Modal Specifications

All dialogs use glass-morphism styling with backdrop blur, gradient-accented headers, and smooth open/close animations (scale + fade).

### 5.1 Add/Edit Item Dialog

- **Max width**: `2xl` (42rem).
- **Max height**: `90vh` with internal scroll.
- **Title**: "Add New Item" or "Edit Item" (dynamic).
- **Tabbed form** with 3 tabs:

**Tab 1: Basic Info**
- Name (text input, required)
- Type (select dropdown, required) — populated from available types
- Tone (text input, placeholder: "e.g., Warm, Cool, Neutral")
- Vibe (text input, placeholder: "e.g., Moody, Bright, Vintage")
- Description (textarea, 3 rows)

**Tab 2: Details**
- Effect (textarea, 3 rows, placeholder: "Describe the visual effect...")
- **Image Upload Section**:
  - Drag & Drop zone with dashed border, upload icon, "Drag & drop images here" text + "Choose Files" button.
  - Supports file upload (reads as base64 data URI) + manual URL input.
  - Shows uploaded images in a 2×3 grid with:
    - Image preview (square aspect ratio)
    - URL input below each (for URL-based images)
    - Red circular "X" remove button on hover
  - Max 10 images.
  - Counter: "Images (3/10)"
- **Link Manager Section**:
  - "Reference Links (N/20)" counter.
  - Add link row: URL input + category dropdown (Tutorial, Inspiration, Portfolio, Official, Download, Reference) + "Add" button.
  - List of added links with:
    - Auto-detected category badge (color-coded)
    - Editable URL
    - Remove button
  - Max 15 links.

**Tab 3: Custom Fields**
- Dynamically rendered fields based on the selected item type's `customProperties`.
- Field types:
  - `text` → standard text input
  - `textarea` → multi-line textarea (3 rows)
  - `number` → number input
  - `select` → dropdown with predefined options
- If no custom properties: show message "No custom fields defined for this type."

**Footer**: Separator line + "Add Item" / "Update Item" submit button (gradient).

### 5.2 Album Dialog (Create/Edit)

- **Max width**: `3xl` (48rem).
- **Tabbed form** with 4 tabs:

**Tab 1: Basic Info**
- Album Name (required)
- Author (text input)
- Description (textarea)
- External Link (URL input)

**Tab 2: Cover Image**
- Description text explaining purpose.
- Image Upload component (max 1 image).

**Tab 3: Photos**
- Description text.
- Image Upload component (max 50 images).

**Tab 4: Linked Items**
- Description: "Select which items (profiles, presets, styles) this album relates to."
- Scrollable list (max-height 60) of all existing items with:
  - Checkbox + type icon + item name + type label for each item.
- Below: "Selected Items:" section showing chosen items as badge pills with type icons.

**Footer**: "Create Album" / "Update Album" button.

### 5.3 Type Management Dialog

- **Max width**: `4xl` (56rem).
- **Add New Type** section at top:
  - Type name input + icon selector dropdown (Palette 🎨, Camera 📷, Sparkles ✨, Image 🖼️) + "Add Type" button.
- **Existing Types** listed below:
  - Each type in an expandable card showing:
    - Type name + icon
    - Custom properties list with inline editing:
      - Property name (editable text)
      - Property type (dropdown: text, textarea, number, select)
      - Options (for select type): comma-separated input
      - Remove property button
    - "Add Property" button at bottom of each type
    - Delete type button (with confirmation)

### 5.4 Image Viewer (Full-Screen Lightbox)

- **Full-screen overlay** with black background.
- **Header bar** (top, semi-transparent): Image title + counter ("3 of 12") + action buttons (Download, Open in new tab, Close).
- **Main image**: Centered, `object-contain`, fills available space.
- **Navigation**: Left/right arrow buttons on sides (visible on hover, semi-transparent black background).
  - Keyboard accessible: left/right arrow keys.
- **Thumbnail strip** (bottom, semi-transparent): Horizontal scrollable row of small square thumbnails.
  - Active thumbnail has white border.
  - Click thumbnail to jump to that image.
- **Animations**: Fade transition between images.

---

## 6. Design Direction — Gradient / Creative (Photography-Themed)

### Color Palette

```yaml
gradients:
  # Dark mode
  dark_bg: "linear-gradient(135deg, #0a0a0f, #1a1025, #0f1419)"
  dark_card: "rgba(255, 255, 255, 0.05)"
  dark_card_border: "rgba(255, 255, 255, 0.08)"
  dark_card_hover_border: "rgba(255, 255, 255, 0.15)"

  # Light mode
  light_bg: "linear-gradient(135deg, #fefefe, #fdf6f0, #f8f0ff)"
  light_card: "rgba(255, 255, 255, 0.7)"
  light_card_border: "rgba(0, 0, 0, 0.08)"

  # Accent gradients (shared)
  accent_primary: "linear-gradient(135deg, #f59e0b, #ea580c)"       # Amber → Orange (warm, photographic)
  accent_secondary: "linear-gradient(135deg, #8b5cf6, #a855f7)"     # Violet → Purple (creative)
  accent_tertiary: "linear-gradient(135deg, #06b6d4, #3b82f6)"      # Cyan → Blue (cool)
  accent_warm: "linear-gradient(135deg, #f97316, #ef4444)"           # Orange → Red (warm alert)
  accent_success: "linear-gradient(135deg, #10b981, #06b6d4)"       # Green → Cyan

  # Type-specific accent colors
  type_profile: "from-orange-400 to-amber-600"    # Palette icon type
  type_preset: "from-blue-400 to-blue-600"         # Camera icon type
  type_style: "from-purple-400 to-purple-600"      # Sparkles icon type
  type_custom: "from-emerald-400 to-emerald-600"   # Image icon type

  text_primary_dark: "#ffffff"
  text_secondary_dark: "rgba(255, 255, 255, 0.7)"
  text_muted_dark: "rgba(255, 255, 255, 0.45)"
  text_primary_light: "#0a0a0f"
  text_secondary_light: "rgba(0, 0, 0, 0.6)"
  text_muted_light: "rgba(0, 0, 0, 0.4)"
```

### Visual Style

- **Background**:
  - Dark mode: Deep gradient base (`#0a0a0f → #1a1025 → #0f1419`) with subtle animated floating orbs (amber/orange, very low opacity ~5-8%, out of focus, drifting slowly).
  - Light mode: Soft warm gradient (`#fefefe → #fdf6f0 → #f8f0ff`) with subtle warm-toned blobs.
- **Cards**: Glass-morphism / frosted-glass:
  - Dark: `backdrop-blur-md`, `bg-white/5`, `border border-white/8`.
  - Light: `backdrop-blur-md`, `bg-white/70`, `border border-black/8`, subtle shadow.
  - Hover: border opacity increases, subtle gradient glow around the card edge, lift 4px.
- **Typography**:
  - Font: `Inter` from Google Fonts.
  - Page headings: 24–32px, bold, tracking-tight.
  - Card titles: 18–20px, semibold.
  - Body: 14–16px, regular.
  - Use `leading-relaxed` for readability.
- **Accent colors**: Warm amber/orange gradients as the primary accent (photography = warmth, light). Purple as secondary creative accent. Blue for cool/info tones.
- **Decorative elements**:
  - Subtle bokeh-like gradient circles floating in the background (CSS radial gradients or SVG).
  - Inspired by out-of-focus light circles in photography (bokeh effect).
  - Aperture blade motif as subtle watermark or decorative icon.
- **Icons**: Use `Lucide React` icon library throughout. Consistent 16px (small) / 20px (medium) / 24px (large) sizing.

### Animations & Micro-Interactions
- **Page transitions**: Fade-in on route change.
- **Cards**: Hover → lift 4px + border glow intensifies + shadow grows. Transition: `300ms ease`.
- **Buttons**: Hover → gradient shifts, subtle scale(1.02). Active → scale(0.98).
- **Dialogs**: Open with scale(0.95→1) + opacity(0→1) transition. Close: reverse.
- **Toast notifications**: Slide in from top-right, auto-dismiss after 5 seconds. Glass-morphism styling.
- **Loading states**: Pulsing skeleton cards with gradient shimmer effect. Full-screen loading overlay with glass-morphism card + spinning loader.
- **Tab transitions**: Active tab indicator slides smoothly.
- **Image hover**: Subtle scale(1.05) zoom on thumbnails.
- **Search focus**: Input border transitions to gradient glow.

### Responsive Breakpoints
- **Mobile** (<640px): Single column cards, hamburger nav, stacked dialogs, smaller typography.
- **Tablet** (640–1024px): 2-column grids, condensed spacing.
- **Desktop** (>1024px): Full layout, max-width container ~1280px centered, 3-4 column grids.

---

## 7. Component Architecture

```
src/
├── App.tsx                        # Root: router setup, theme provider, toast provider
├── main.tsx                       # Vite entry point
├── index.css                      # Tailwind directives + CSS variables + gradient utilities
├── constants/
│   └── defaults.ts                # Default item types, icon mappings
├── types/
│   └── index.ts                   # TypeScript interfaces (LightroomItem, Album, ItemType, etc.)
├── services/
│   └── api.ts                     # ApiService class with localStorage/REST/Firebase abstraction
├── hooks/
│   ├── useTheme.ts                # Light/dark theme toggle with localStorage persistence
│   ├── useToast.ts                # Toast notification system
│   ├── useScrollPosition.ts       # Track scroll for navbar transparency
│   ├── useKeyboardShortcuts.ts    # Global keyboard shortcuts (Ctrl+N, Escape, arrows, etc.)
│   └── useGoldenHour.ts           # Easter egg: Golden Hour Mode click counter + toggle
├── components/
│   ├── layout/
│   │   ├── Navbar.tsx             # Sticky navbar with scroll-aware transparency + mobile menu
│   │   ├── Footer.tsx             # App footer with branding, features, resources, credits
│   │   └── PageContainer.tsx      # Shared page wrapper (max-width, padding, bg gradient)
│   ├── items/
│   │   ├── ItemGrid.tsx           # Responsive grid wrapper for item cards
│   │   ├── ItemList.tsx           # Compact list view wrapper for items
│   │   ├── ItemCard.tsx           # Individual item card (glass-morphism, images, links, etc.)
│   │   ├── ItemRow.tsx            # Compact list row for list view
│   │   ├── AddEditDialog.tsx      # Tabbed dialog for creating/editing items
│   │   ├── ImageUpload.tsx        # Drag & drop + URL image uploader component
│   │   └── LinkManager.tsx        # Link input + auto-categorization component
│   ├── albums/
│   │   ├── AlbumGrid.tsx          # Responsive grid for album cards
│   │   ├── AlbumCard.tsx          # Individual album card with cover image
│   │   ├── AlbumDialog.tsx        # Tabbed dialog for creating/editing albums
│   │   └── AlbumDetail.tsx        # Album detail two-column layout
│   ├── settings/
│   │   ├── TypeManagement.tsx     # Type management dialog & card previews
│   │   ├── AppearanceCard.tsx     # Theme settings card
│   │   ├── DataManagementCard.tsx # Storage, export & import settings card
│   │   └── ImportConfirmDialog.tsx # Import confirmation with selective import options
│   ├── shared/
│   │   ├── ImageViewer.tsx        # Full-screen lightbox with navigation & thumbnails
│   │   ├── SearchBar.tsx          # Glass-morphism search input
│   │   ├── SortDropdown.tsx       # Sort options dropdown (name, date, type)
│   │   ├── ViewToggle.tsx         # Grid/List view toggle buttons
│   │   ├── FilterTabs.tsx         # Dynamic filter tab bar
│   │   ├── WelcomeCard.tsx        # First-time onboarding card
│   │   ├── KeyboardShortcuts.tsx  # Shortcuts cheat sheet popover
│   │   ├── EmptyState.tsx         # Reusable empty state illustration
│   │   ├── ConfirmDialog.tsx      # Reusable confirmation dialog (delete, etc.)
│   │   ├── LoadingOverlay.tsx     # Full-screen loading spinner with glass card
│   │   ├── LoadingCard.tsx        # Skeleton loading card with shimmer
│   │   └── ThemeToggle.tsx        # Sun/moon toggle button with rotation animation
│   └── ui/
│       ├── GlassCard.tsx          # Reusable glass-morphism card wrapper
│       ├── GradientButton.tsx     # Primary gradient-styled button
│       ├── GhostButton.tsx        # Outline/ghost button
│       ├── GradientBadge.tsx      # Colored pill/badge component
│       ├── GradientInput.tsx      # Input with gradient focus ring
│       ├── GradientSelect.tsx     # Select dropdown with gradient styling
│       ├── DialogShell.tsx        # Styled dialog wrapper (glass-morphism)
│       ├── TabBar.tsx             # Styled tab component with gradient indicator
│       └── Toast.tsx              # Toast notification component
├── pages/
│   ├── HomePage.tsx               # Items dashboard (search + tabs + grid + dialogs)
│   ├── AlbumsPage.tsx             # Albums gallery page
│   ├── AlbumDetailPage.tsx        # Single album detail page
│   ├── SettingsPage.tsx           # Settings page
│   └── NotFoundPage.tsx           # Custom 404 page
public/
├── favicon.svg                    # Aperture/lens icon favicon with gradient
└── og-image.png                   # Open Graph preview image
```

### Component Guidelines
- All components are **functional** (`React.FC` with TypeScript, strict mode).
- Use **Tailwind CSS classes** exclusively — no CSS modules, no styled-components.
- Animations: **CSS transitions** via Tailwind's `transition-*` utilities. Complex animations with **Framer Motion** if needed.
- No external UI library (no shadcn/ui, no Material UI, no Chakra). Build all components from scratch with Tailwind for maximum design control.
- All interactive elements: **keyboard accessible** with visible focus rings (gradient-styled focus-visible).
- Data logic separated from presentation (services/ folder for API, types/ for interfaces).
- Use React Context for theme state and toast notifications.

---

## 8. Special Design Features

### 8.1 Photography-Themed Loading States
- Skeleton loading cards should shimmer with a warm amber gradient sweep (like light sweeping across a photo).
- The main loading overlay shows an aperture icon that animates (blades rotating), inside a glass-morphism card.

### 8.2 Image Upload UX
- Drag & drop zone has a **dashed border** that animates to a **solid gradient border** when files are dragged over.
- The zone background shifts to a warm glow (`bg-primary/10`) during drag-over.
- File uploads are converted to base64 and displayed as immediate previews.
- URL-based images show a text input below the preview for editing. 

### 8.3 Smart Link Categorization
- When a user adds a URL, the app auto-detects the category based on domain:
  - YouTube → "Tutorial" (green badge)
  - Instagram → "Inspiration" (purple badge)
  - Behance/Dribbble → "Portfolio" (blue badge)
  - Adobe → "Official" (orange badge)
  - URLs with "download" or file extensions → "Download" (red badge)
  - Others → "Reference" (gray badge)
- User can override the auto-detected category via a dropdown.

### 8.4 Dynamic Type System
- Users can create entirely new item types beyond the 3 defaults.
- Each type has:
  - Custom name
  - Custom icon (from 4 options)
  - Unlimited custom properties (text, textarea, number, select fields)
- New types automatically appear in the Home page's filter tabs.
- Items of custom types get the type's assigned icon and color scheme.

### 8.5 Album ↔ Item Linking
- Albums can be linked to multiple items (presets, profiles, styles).
- Items show "Related Albums" badges linking back to the album detail page.
- This creates a bidirectional reference system for organizing photography workflows.

### 8.6 Keyboard Shortcuts
Implement global keyboard shortcuts for power users. Use a `useKeyboardShortcuts` custom hook.

| Shortcut | Action |
|---|---|
| `Ctrl+N` / `Cmd+N` | Open "Add New Item" dialog |
| `Escape` | Close any open dialog/modal/sheet |
| `←` / `→` arrow keys | Navigate prev/next in Image Viewer |
| `Ctrl+K` / `Cmd+K` | Focus the search bar |
| `Ctrl+E` / `Cmd+E` | Export data (from any page) |

- Shortcuts should NOT trigger when user is typing in an input/textarea field (except `Escape`).
- Shortcuts are discoverable via a small "⌨️" icon button in the navbar that shows a **keyboard shortcuts cheat sheet** popover on click.

### 8.7 Easter Egg — Golden Hour Mode 🌅
- **Trigger**: Clicking the navbar LightNote logo **5 times rapidly** (within 2 seconds).
- **Effect — "Golden Hour Mode"**:
  - The entire app's color temperature shifts warmer: apply a CSS filter `sepia(0.15) saturate(1.2) brightness(1.05)` with a smooth 800ms transition.
  - A toast notification appears: *"🌅 Golden Hour Mode activated — everything looks better in warm light!"*
  - The navbar logo subtly glows with an animated amber pulse.
  - Mode persists until the user clicks the logo 5 times again (toggle behavior).
  - State saved in `localStorage` so it persists across sessions.
- **Implementation**: A `useGoldenHour` custom hook with click counter + timeout reset. Apply the CSS filter on the root `<div>` via a className toggle.

### 8.8 First-Time Onboarding
When `localStorage` is empty (no items, no albums — first visit), show an **onboarding experience** instead of empty states:

- **Welcome Card** (replaces the items grid area on Home page):
  - Glass-morphism card, wider than normal, centered.
  - Aperture icon with animated gradient glow at top.
  - Heading: "Welcome to LightNote 📷"
  - Subheading: "Your photography preset & style organizer"
  - Three step indicators (horizontal, with icons):
    1. "📝 Create your first item" — describe a preset, profile, or color style.
    2. "📁 Organize into albums" — group related items and photos.
    3. "🎨 Customize your types" — add custom fields for your workflow.
  - Primary CTA button: "Create Your First Item →" (gradient, opens Add Item dialog).
  - Secondary link: "or explore Settings to customize types first"
- The welcome card **disappears permanently** once the user creates their first item.
- Uses `localStorage` flag `lightnote-onboarded` to track if onboarding was completed.
- The onboarding card has a subtle entrance animation (fade-in + scale from 0.95).

---

## 9. Code Generation Requirements

```yaml
build_tool: "Vite 6+"
framework: "React 19+"
language: "TypeScript (strict mode)"
styling: "Tailwind CSS v4"
animation: "CSS transitions + Framer Motion (optional for complex animations)"
fonts: "Inter via Google Fonts CDN"
icons: "Lucide React"
package_manager: "npm"
routing: "react-router-dom v7"
state_management: "React useState + useContext (no external state library)"
data_persistence: "localStorage with ApiService abstraction layer"
deployment_target: "Static hosting (Vercel / Cloudflare Pages)"
```

### SEO & Metadata
Add to `index.html`:
- `<title>`: "LightNote — Photography Notes & Preset Manager"
- `<meta name="description">`: "Organize your Lightroom presets, color profiles, and photography styles. A beautiful note-taking app for photographers."
- `<meta name="theme-color" content="#1a1025">`
- **Open Graph tags**:
  - `og:title`: "LightNote — Organize Your Light"
  - `og:description`: "Photography-focused note-taking — organize presets, profiles, and editing styles."
  - `og:image`: `/og-image.png`
  - `og:url`: "https://lightnote.baole.space"
  - `og:type`: "website"
- **Favicon**: SVG favicon featuring a stylized aperture/lens icon with amber-to-orange gradient fill.

### Code Quality
- Clean, readable, idiomatic TypeScript/React.
- Consistent naming: PascalCase for components, camelCase for functions/variables.
- Each component in its own file — no god-components.
- Data models and API logic separated from UI components.
- Semantic HTML (`<header>`, `<main>`, `<section>`, `<footer>`, `<nav>`, `<dialog>`).
- Accessible: `aria-label` on icon-only buttons, color contrast ≥ 4.5:1, alt text on images, keyboard navigation.
- Responsive: mobile-first with Tailwind's `sm:`, `md:`, `lg:`, `xl:` prefixes.

### Vite Configuration
- Standard `vite.config.ts` with React plugin.
- Tailwind CSS via `@tailwindcss/vite` plugin or PostCSS.
- Path alias: `@/` → `src/`.
- Build output: `dist/`.

---

## 10. Acceptance Criteria

The generated output must satisfy ALL of the following:

- [ ] **Home page**: Items dashboard shows search bar, filter tabs, item cards grid, and "Add New Item" button. All CRUD operations work (create, read, update, delete items).
- [ ] **Item cards**: Display name, type badge, reference images (with viewer), description, tone, vibe, effect, links (with auto-categorization), and related albums.
- [ ] **Albums page**: Gallery grid of album cards with cover images, search, and CRUD operations.
- [ ] **Album detail**: Two-column layout with metadata sidebar and photo grid. Linked items shown. Image viewer works.
- [ ] **Settings**: Type management (add/edit/delete types and custom properties), appearance toggle, working data export/import.
- [ ] **Export/Import**: Export button downloads a complete JSON backup file. Import button reads a JSON file, shows confirmation with selective import, and restores data.
- [ ] **Image Viewer**: Full-screen lightbox with prev/next navigation (including arrow key support), thumbnails, download, and open-in-new-tab actions.
- [ ] **Gradient/Creative design**: The app uses vibrant warm gradients (amber/orange primary), glass-morphism cards, decorative bokeh background elements, and is NOT a plain white or plain black page.
- [ ] **Dual theme**: Both light and dark modes work correctly with gradient-styled backgrounds and consistent glass-morphism treatment.
- [ ] **Responsive**: Layout works correctly on mobile (360px), tablet (768px), and desktop (1440px).
- [ ] **Animations**: Card hover effects (lift + glow), button hover transitions, dialog open/close animations, tab indicator slide, loading shimmer.
- [ ] **Accessibility**: Keyboard navigable, focus rings visible (gradient-styled), color contrast compliant, aria-labels on icon buttons.
- [ ] **Dynamic types**: Adding a new type in Settings automatically creates a new filter tab on the Home page and new items can use it.
- [ ] **Image upload**: Drag & drop file upload + URL input both work. Images display as base64 previews in cards.
- [ ] **Link management**: Auto-categorization works. Links display with colored type badges.
- [ ] **Local storage**: All data persists across page refreshes via localStorage.
- [ ] **Clean code**: Components properly separated, TypeScript strict, no `any` types, data in services layer.
- [ ] **Build succeeds**: `npm run build` completes without errors.
- [ ] **404 page**: Custom-designed 404 page matching the gradient/creative style.
- [ ] **Router**: All routes work (`/`, `/albums`, `/albums/:id`, `/settings`, `*` catch-all).
- [ ] **Sort options**: Items can be sorted by name (A-Z, Z-A), date created (newest/oldest), and type. Sort preference persists.
- [ ] **Grid/List toggle**: Users can switch between card grid view and compact list view on the Home page. View preference persists.
- [ ] **Keyboard shortcuts**: `Ctrl+N` opens Add dialog, `Escape` closes dialogs, arrow keys navigate Image Viewer, `Ctrl+K` focuses search. Cheat sheet popover accessible from navbar.
- [ ] **Easter egg**: Clicking the logo 5 times rapidly activates "Golden Hour Mode" (warm color temperature shift + toast notification). Toggleable and persisted.
- [ ] **Onboarding**: First-time visitors see a welcome card with guided steps instead of an empty grid. Disappears after creating the first item.

---

## 11. Design Mood & Inspiration

The overall aesthetic should evoke:
- **Photography warmth**: Amber/orange tones reminiscent of golden-hour light. The feeling of warmth and creativity.
- **Glass & light**: Glass-morphism everywhere — like looking through a camera viewfinder with frosted glass panels floating over a gradient backdrop.
- **Bokeh backgrounds**: Soft, out-of-focus light circles drifting in the background, inspired by bokeh in photography.
- **Professional tool with soul**: Not a cold utility app — it should feel like a photographer's personal creative workspace, warm and inviting.
- **Consistent with baole.space**: Part of the same visual family as the `baole.space` personal website — using the same gradient/creative design language but with a photography-warm color palette (amber/orange) instead of the cool purple/blue palette of the main site.

The design should feel like a **luxury photography app** — polished, warm, and deeply personal — a tool that photographers would be proud to use and show off.

---

*End of prompt. Generate both the UI design and the complete, production-ready codebase.*
