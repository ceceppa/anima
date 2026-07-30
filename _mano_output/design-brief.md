# Design Brief — Anima

Visual direction: `v2_stuff/ex1.jpg` (a modern, dark, dashboard-style aesthetic). Phase 3 shipped a scoped-down version with no header and a flat control layout; Phase 4 brings in the reference image's header, contained stage, and floating selector dock. Scrubbing, speed, reduced-motion, and the full easing/direction picker remain reference for later phases, not built now.

## Accessibility target

WCAG 2.1 AA. Every pairing below is checked against it.

## Framework / component library

Not a web framework — this is a Godot scene. "Components" are Godot `Control`-derived scenes/scripts (`StateCard`, `PlaybackControls`, per `project-rules.md` §Example Scenes) styled via one custom Godot `Theme` resource (`examples/shared/theme/anima_examples.tres`) applied at the scene root, replacing every default control style.

## Colour palette

| Token | Hex | Use |
|---|---|---|
| `bg` | `#0A0E1A` | Scene background |
| `surface` | `#121826` | Card/panel backgrounds |
| `text-primary` | `#F8FAFC` | Headings, primary labels |
| `text-secondary` | `#94A3B8` | Subtitles, descriptions |
| `accent` | `#4F46E5` | Selected tab fill, restart button fill |
| `accent-text` | `#818CF8` | "Playing" state label (text on `surface`, not filled) |
| `positive` | `#2DD4BF` | "Completed" state label (text on `surface`) |
| `positive-fill` | `#0D9488` | Large/bold display fills only (e.g. a big letter on a card) — too low-contrast with white text at normal size |
| `border` | `#1E293B` | Card/panel dividers (decorative only, not a text pairing) |
| `stage-bg` | `#0E1420` | Content stage background — one step lighter than `bg`, one step darker than `surface`, so header/stage/cards read as three distinct layers |
| `dock-bg` | `rgba(18, 24, 38, 0.85)` (`surface` at 85% alpha) | Selector dock background — translucent so it reads as floating over the stage, not another flat panel |

Contrast checks (normal text, AA needs 4.5:1; large/bold text needs 3:1):
- `text-primary` on `bg`: 18.4:1 ✅ AA (and AAA)
- `text-primary` on `surface`: 16.9:1 ✅ AA (and AAA)
- `text-secondary` on `surface`: 6.9:1 ✅ AA
- `text-secondary` on `stage-bg`: 7.4:1 ✅ AA
- White on `accent`: 6.3:1 ✅ AA
- `accent-text` on `surface`: 5.9:1 ✅ AA
- `positive` on `surface`: 9.5:1 ✅ AA (and AAA)
- White on `positive-fill`: 3.7:1 — fails normal-text AA (needs 4.5:1), passes large-text AA (needs 3:1). **Restricted to large/bold display use only** (see table) — do not use for body or caption text.

## Typography

Inter (Google Font, system-ui fallback).
- Header title: 28px / 700, `text-primary`
- Header subtitle: 14px / 400, `text-secondary`
- Stage type title ("Sequence", "Stagger", …): 20px / 700, `text-primary`
- Stage type description: 14px / 400, `text-secondary`
- Body / description (general): 14px / 400, `text-secondary`
- Status pill / caption / example counter ("01 / 05"): 12px / 500, uppercase, letter-spacing 0.02em

## Spacing scale

4, 8, 12, 16, 24, 32, 40, 48, 56, 64 (px).

- Header horizontal padding: 32px. Header vertical padding: 24px.
- Stage internal padding: 40px.
- Header-to-stage gap: 24px. Stage description-to-cards gap: 40px. Cards-to-dock gap: 48px. Gap between cards: 40px.

## Border radius

- `radius-md`: 12px — cards, selector-dock items/indicator, the restart button
- `radius-dock`: 16px — the selector dock's own outer shape
- `radius-lg`: 24px — the content stage container
- `radius-full`: 9999px — status pills

Nested radii step down from the outside in (stage 24 → dock 16 → dock item 12) so the rounded shapes read as intentionally nested, not repeated at the same size.

## Icon style

Line icons only, 20px box, 1.5px stroke, no fill — matches the restart icon and the small icons on the composition-type selector.

## Component guide

Only what this phase's scene actually uses (see `ux-flow.md` § Composition Example Scene — note `ux-flow.md` still describes the Phase 3 layout as of this writing and needs a `mano ux` pass to catch up):

- **Shared example header** — new, reusable across every example scene. `surface` background, 1px `border` bottom edge, soft shadow (`rgba(0,0,0,0.24)`, 8px blur, 2px y-offset). Left-aligned: a 40px icon box, header title, header subtitle stacked beside it. Padding per Spacing scale above. Stays fixed across tab switches.
- **Content stage (container)** — new. `stage-bg` background, 1px `border` at 40% opacity, `radius-lg`, soft outer shadow (`rgba(0,0,0,0.32)`, 32px blur, 8px y-offset). Contains the stage type title/description, the card row, the background depth treatment, and the selector dock. Position and size never change when switching composition type — only its contents do.
- **Background depth treatment** — a radial gradient centred behind the card row, `accent` at 8% alpha fading to transparent, clipped to the stage's rounded corners. (Chosen over the dot/grid alternative for a softer, less busy field behind fast-moving cards.)
- **Stage type title + description** — top-left of the stage. Title uses the "Stage type title" style, description the "Stage type description" style below it. An example counter ("01 / 05", caption style) sits top-right of the stage, same row as the title. Crossfades over 120ms with a 4px horizontal shift when the type changes — no large enter/exit animation.
- **Selector dock** — new, replaces the old full-width selector strip. A compact floating dock centred below the cards, inside the stage: `dock-bg`, 1px `border` at low opacity, `radius-dock`, soft shadow. Holds one item per composition type (Sequence, Parallel, Stagger, Repeat, Race, Conditional), each a small line icon + label, `radius-md`.
  - **Selected indicator**: an `accent`-filled `radius-md` shape that physically moves and resizes to sit behind the newly selected item — 260ms, ease-out with a slight overshoot (spring feel). A subtle inner highlight and very low-alpha `accent` glow, not a hard fill.
  - **Label transition**: 140ms colour change from `text-secondary` (unselected) to white + bolder weight (selected). No label scaling.
  - **Press feedback**: on tap, the pressed item dips 2px on the y-axis and scales to 0.97 for ~80ms, springing back on release.
  - Selection is never colour-only: selected = `accent` background + white text + bold weight together. Keyboard focus renders as a distinct outline, separate from the selected-item look.
- **StateCard** — one per node in the current composition, `radius-md`, bold single-letter (or "True"/"False" for Conditional) label. It has no states of its own — it's one plain visual style (dark card, thin `border`-colour outline, soft shadow, `text-secondary` label) that Anima animates directly, the same way it would animate any other node: border colour drifting toward `accent` then `positive`, an outward glow rising and settling, the label tinting `accent-text` then `positive`, a small scale bump. The card doesn't know or render a "waiting"/"active"/"completed" concept — it just renders whatever values are currently being animated on it (`project-rules.md` §Example Scenes).
- **Duration badge** — *removed from the demo for now* (not currently shown). Spec kept here in case it returns: a small `radius-full` pill, `surface` background, showing the kind (`FIXED` / `ESTIMATED` / `DYNAMIC` / `INFINITE`) and, when known, the seconds value, in `text-primary`.
- **Restart button** — *removed from the demo for now* (not currently shown), so the selector dock holds only the six composition-type items, no trailing action. No pause/play, scrub, speed, or reduced-motion control this phase.

## Screen composition — Composition Example Scene

Top to bottom:
1. **Shared header** — icon + "Composition" + "Combine simple animations into expressive flows." Fixed position/size across tab switches.
2. **Content stage** (fixed position/size), containing, top to bottom:
   1. Stage type title + description (top-left), example counter (top-right) — crossfades on type switch.
   2. Background depth treatment (radial gradient), sitting behind the card row.
   3. Card row for the currently selected composition — cards demonstrate that type's behaviour (Sequence: one-at-a-time; Parallel: together; Stagger: travelling offset; Repeat: complete-then-restart; Race: winner vs. interrupted; Conditional: True/False).
   4. Selector dock, centred below the card row, holding the six composition-type items. (No duration badge or restart button — both removed from the demo for now, see Component guide.)

Header, stage, and dock positions never move; only the stage's internal content (title/description, cards, dock selection) changes when the user picks a different type.
