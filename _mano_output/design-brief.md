# Design Brief — Anima

## Visual direction

`v2_stuff/ex2.jpg` is a loose visual reference only: borrow its midnight background, restrained violet glow, contained stage, and clear control hierarchy. The Grid example keeps the already-agreed shared components and deliberately omits its rank badges, timeline, speed controls, and reduced-motion switch.

## Accessibility target

WCAG 2.1 AA. Every text pairing below meets the normal-text target unless explicitly marked as large-display-only.

## Framework / component library

This is a Godot scene. A custom Godot Theme is applied at the scene root; existing shared components remain the only visual building blocks: `ExampleHeader`, `Card`, `SelectorDock`, and `SelectorButton`. No new shared component is introduced by this brief.

## Colour palette

| Token | Hex | Use |
|---|---|---|
| `bg` | `#060A16` | Scene background |
| `surface` | `#11182A` | Header, cards, and dock |
| `stage-bg` | `#0A1224` | Contained content stage |
| `text-primary` | `#F8FAFC` | Headings and selected labels |
| `text-secondary` | `#A8B4CC` | Supporting copy and unselected labels |
| `accent` | `#7C3AED` | Selected indicator and subtle stage glow |
| `accent-soft` | `#A78BFA` | Active card accent and focus treatment |
| `positive` | `#2DD4BF` | Completed visual treatment |
| `border` | `#26324B` | Decorative dividers and outlines |

Contrast checks: `text-primary` on `bg` 19.2:1; `text-primary` on `surface` 16.7:1; `text-secondary` on `surface` 7.4:1; white on `accent` 6.4:1; `positive` on `surface` 9.6:1. All pass AA.

## Typography and layout

Use Inter with the system fallback. Header title is 28px/700; subtitle, stage description, and body copy are 14px/400; stage title is 20px/700; the compact counter is 12px/500. Use a 4px base spacing scale with 16px card gaps, 24px header-to-stage separation, 32px horizontal stage padding, and 24px vertical stage padding. The stage radius is 24px; cards and dock items use 12px; the dock container uses 16px.

Line icons use a 20px box, 1.5px stroke, and no fill. Accent glow is decorative only and never conveys selection or focus by itself.

## Component guide

- **ExampleHeader** — fixed at the top: icon, “Composition”, and its subtitle. `surface` background with a `border` divider; no per-selection movement.
- **Content stage** — a stable `stage-bg` container with a low-opacity violet radial glow behind the cards. Its size and position do not change with selection.
- **Card** — existing shared card component: a scene-authored artwork texture fills the card with a 28% `bg` overlay for depth, plus a thin `border` outline and soft shadow. The artwork is decorative because the selected motion is named in surrounding copy and controls. Animation progress continues to drive the card's border, glow, opacity, and scale; it does not introduce a named-state UI.
- **SelectorDock / SelectorButton** — compact dock below the cards for the existing composition types. The dock owns one moving `accent` indicator; buttons provide label and focus treatment only. Selected state is conveyed by indicator, white text, and stronger weight together.
- **Grid stage** — a wide `stage-bg` panel holding a true 5×5 Card grid. Cards use a 10px gap and a consistent landscape ratio. A thin `accent-soft` ring plus a compact “Start” label identifies the chosen origin; any tile can be the origin, so it is never presented as inherently central. The marker is distinct from the animation glow and never shows a rank number.
- **Order From** — a full-width segmented `SelectorDock` sits between the stage heading and grid. Its choices are Top, Bottom, Center, Together, Odd, Even, Random, and Index; `Top` is selected by default. It uses the existing single moving indicator rather than per-button fills.
- **Formula control and picker** — the stage uses one compact control that names the selected formula. Its picker is a contained `surface` panel with formula names and one-line explanations; selected state uses the same moving indicator, white text, and stronger weight as `SelectorDock`. Formula families are grouped with quiet text labels, not decorative icons.
- **Playback controls** — reuse the shared controls beneath the stage for restart and reverse only. Do not add timeline, rank, speed, or reduced-motion controls to this playground.

## Screen composition — Composition Example Scene

1. **ExampleHeader** — fixed icon, title, and subtitle.
2. **Content stage** — stage title and description with a compact example counter.
3. **Card row** — three artwork cards show the selected composition through their existing animated treatment.
4. **SelectorDock** — selection changes the composition shown in the stage.

## Screen composition — Grid Motion Example Scene

1. **ExampleHeader** — fixed Grid Motion title and explanatory subtitle.
2. **Grid stage** — formula name and brief explanation sit above the Order From selector and a centered 5×5 Card grid; any selected tile can be the visible start point, without rank labels.
3. **Order From and Formula controls** — set the grid's propagation order and formula without moving the stable stage.
4. **Playback controls** — restart and reverse sit beneath the stage, without a timeline or playback-speed surface.
