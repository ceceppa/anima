# Design Brief — Anima

Visual direction: `v2_stuff/ex1.jpg` (a modern, dark, dashboard-style aesthetic), scoped down to what Phase 3's single example scene actually shows — the fuller playground (tabs for every future composite type, scrubbing, speed, reduced-motion, the full easing/direction picker) is reference for later phases, not built now.

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

Contrast checks (normal text, AA needs 4.5:1; large/bold text needs 3:1):
- `text-primary` on `bg`: 18.4:1 ✅ AA (and AAA)
- `text-primary` on `surface`: 16.9:1 ✅ AA (and AAA)
- `text-secondary` on `surface`: 6.9:1 ✅ AA
- White on `accent`: 6.3:1 ✅ AA
- `accent-text` on `surface`: 5.9:1 ✅ AA
- `positive` on `surface`: 9.5:1 ✅ AA (and AAA)
- White on `positive-fill`: 3.7:1 — fails normal-text AA (needs 4.5:1), passes large-text AA (needs 3:1). **Restricted to large/bold display use only** (see table) — do not use for body or caption text.

## Typography

Inter (Google Font, system-ui fallback).
- Scene title: 20px / 600
- Section label ("Sequence", "Stagger", …): 16px / 600
- Body / description: 14px / 400, `text-secondary`
- Status pill / caption: 12px / 500, uppercase, letter-spacing 0.02em

## Spacing scale

4, 8, 12, 16, 24, 32, 48 (px).

## Border radius

- `radius-md`: 12px — cards, the selector strip, the restart button
- `radius-full`: 9999px — status pills

## Icon style

Line icons only, 20px box, 1.5px stroke, no fill — matches the restart icon and the small icons on the composition-type selector.

## Component guide

Only what this phase's scene actually uses (see `ux-flow.md` § Composition Example Scene):

- **Composition-type selector** — a horizontal strip of 6 segments (Sequence, Parallel, Stagger, Repeat, Race, Conditional), each with a small line icon + label. Selected segment: `accent` fill, white text, `radius-md`. Unselected: `surface` fill, `text-secondary` text.
- **StateCard** — one per node in the current composition. `radius-md`, `surface` background, a bold single-letter label. States: `waiting` (`border`-only outline, `text-secondary` label), `playing` (`accent` glow outline, `accent-text` label), `completed` (`positive` glow outline, `positive` label). Cards connect left-to-right with a thin dotted line in the state colour of the card it leads from.
- **Duration badge** — a small `radius-full` pill, `surface` background, showing the kind (`FIXED` / `ESTIMATED` / `DYNAMIC` / `INFINITE`) and, when known, the seconds value, in `text-primary`.
- **Restart button** — `radius-md`, `accent` fill, white icon, no label needed (icon-only, with a tooltip). No pause/play, scrub, speed, or reduced-motion control this phase (see `ux-flow.md`).

## Screen composition — Composition Example Scene

Top to bottom:
1. Scene title ("Composition Example") — small, `text-primary`, 20px/600.
2. Composition-type selector strip.
3. State-card row for the currently selected composition, connected by dotted lines, each with its status pill below.
4. Duration badge, right-aligned above the state-card row.
5. Restart button, centred below the state-card row.

No header branding, icons, or settings menu — those exist only in the reference image's fuller (future) vision, not this phase's scope.
