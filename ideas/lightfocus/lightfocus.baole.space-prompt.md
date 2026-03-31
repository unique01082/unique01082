Design and prototype a minimal yet addictive web app for personal task prioritization using a concentric circle (Bullseye) model.

## Core Concept

The interface is centered around 3 concentric circles:

* Inner circle: "Now" (max 3 items)
* Middle circle: "Next"
* Outer circle: "Later"

Users drag and drop tasks between circles. The system enforces focus and intentional prioritization.

## UX Principles

* Extreme minimalism (no clutter, no dashboards)
* Fast interaction (everything < 1 click or drag)
* Visually satisfying (smooth motion, subtle feedback)
* Addictive loop: add → prioritize → focus → complete → repeat

## Layout

* Fullscreen canvas with centered concentric circles
* Dark mode default (pure black / near black background)
* Soft glowing circles with subtle gradients
* Tasks displayed as floating pills/cards inside circles
* Floating "+" button for adding new task
* No sidebar, no navigation, single screen app

## Task Model (UI only, no backend logic needed in design)

Each task contains:

* title (short text)
* impact (1–5)
* effort (1–5)
* leverage (1–5)

Display:

* Task title always visible
* On hover: show mini radial indicators or bars for the 3 attributes

## Interactions

* Drag task between circles (snap animation)
* When dropping into "Now":

  * If >3 items → show warning or auto-push oldest out
* Click task → expand inline (not modal)
* Mark as done → fade out + subtle particle animation
* Add task:

  * Inline input (no modal)
  * Auto-focus cursor

## Addictive Details

* Micro animations:

  * Tasks gently float (very subtle)
  * Magnetic snapping to circle zones
* Sound (optional concept):

  * Soft click when dropping
* Completion feedback:

  * Small burst animation
  * Circle briefly pulses

## Visual Style

* Typography: Inter or similar clean sans-serif
* Color:

  * Background: #0A0A0A
  * Circles: soft gradient (gray → slightly tinted)
  * "Now": slightly warmer tone
* Blur/glass effect for task cards
* No borders, only shadows and glow

## Empty State

* Show subtle hint text:
  "Drop what matters most into the center."

## Data & Backend (for context only, not visualized heavily)

* Use Supabase as backend
* Keep schema extremely simple:

  * tasks table:

    * id
    * title
    * impact
    * effort
    * leverage
    * priority_tier (now/next/later)
    * created_at
* No auth complexity (assume single user)

## Constraints

* No complex dashboards
* No charts overload
* No settings page
* Everything happens on ONE screen

## Goal

The product should feel:

* Effortless to start
* Hard to stop using
* Emotionally satisfying when organizing work

Design it like a tool a solo builder would open 20 times a day.
