# Design Brief — Anima

## Visual direction

`v2_stuff/ex2.jpg` is a loose visual reference only: borrow its midnight background, restrained violet glow, contained stage, and clear control hierarchy. The Grid example keeps the already-agreed shared components and still omits its own rank badges and timeline — those stay specific to the Grid stage visualization, not the shared control bar.

**Phase 11 supersedes the earlier "no speed or reduced-motion controls" stance for the shared `PlaybackControls` bar.** That bar now needs to demonstrate `complete()`, `revert()`, a speed change, and the global reduced-motion flag end-to-end (see `phase-11/phase-brief.md` Exit Criteria). `v2_stuff/ex2.jpg`'s bottom transport bar is the concrete reference for this addition — its speed control and "Reduced motion" toggle are what's borrowed here (translated into this project's own component vocabulary below); its scrub slider and elapsed/total time readout are not, since progress-based seeking is explicitly a separate, not-yet-selected backlog item.

**Phase 20's Demo Selector** takes `v2_stuff/main-menu.jpeg` as a loose layout reference only: its title bar, card grid, and footer info bar are the borrowed structure. Its per-card neon colour-coding is not borrowed — this app keeps one `accent`/`accent-soft` colour language across every screen (see Colour palette), so every demo card shares that same treatment rather than a colour per category. The reference shows a flat card grid; the approved phase scope is two category tabs (2D/3D) above the card grid, so the tabs replace the reference's single flat list.

## Accessibility target

WCAG 2.1 AA. Every text pairing below meets the normal-text target unless explicitly marked as large-display-only.

## Framework / component library

This is a Godot scene. A custom Godot Theme is applied at the scene root; shared components are the only visual building blocks: `ExampleHeader`, `Card`, `SelectorDock`, `SelectorButton`, and, as of Phase 11, `ToggleSwitch` (see Component guide) — no new component beyond that one.

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
- **Playback controls** — a row of four circular icon buttons, 96px diameter: restart, reverse, complete, revert (in that order). Each button fills flat with `accent` (a `StyleBoxFlat`, not a gradient — a gradient fill can't carry a border) and gets a 2px `accent-soft` border, corner radius 48px (half the button size, so it stays a true circle). No glow — tried behind each button at 24% opacity per an earlier pass, dropped for reading as visual noise rather than depth; the buttons rely on the flat fill and border alone for definition. Icon graphics are `examples/playground/images/play.svg` (restart) and `reverse.svg`, supplied by the user, real artwork; `complete.svg` (a checkmark) and `revert.svg` (a counter-clockwise arrow to a starting mark) are new this phase and start as the same kind of placeholder glyph restart/reverse used before their own artwork arrived (✓ and ↺) — swap for real artwork the same way, no rush.
- **Speed control** — reuses `SelectorDock`/`SelectorButton` as a compact 3-item dock (`0.5×`, `1×`, `2×`) to the right of the button row — the same moving-`accent`-indicator selection pattern already used for Order From and Formula, not a new dropdown widget. `1×` is selected by default.
- **Reduced-motion toggle** — new `ToggleSwitch` component (below) paired with a `text-secondary` "Reduced motion" label, sitting at the far right of the same control row — directly mirrors `v2_stuff/ex2.jpg`'s bottom-right toggle.
- **ToggleSwitch** (new) — a 40×22px pill track, 18px circular thumb inset 2px. Off: `surface` track, `border` 1px outline, thumb `text-secondary`. On: `accent` track fill, no outline, thumb `text-primary` (white), slid to the right edge. State changes are an immediate snap, not an eased slide — this is a settings switch, not an animated demo subject. Contrast: `text-primary` thumb on `accent` track 6.4:1 ✅ AA (same pairing already verified for Playback controls' icon-on-`accent` treatment).
- **3D Card** — an `Icosahedron` mesh (`examples/playground/models/card.obj`) replacing the 2D artwork `Card` for the 3D Motion Example Scene only. `v2_stuff/icosahedron.png` is a loose visual reference for treatment, not colour: borrow its faceted-glass look — translucent faces, a bright fresnel rim where each facet edge catches the light, and a soft emissive glow from the core — but recolour it to the app's own palette (`accent` violet core glow, `accent-soft` fresnel rim) instead of the reference's green, so the 3D scene reads as the same product as every 2D playground. No text or letter on any face. A custom `ShaderMaterial` drives the fresnel rim and emissive core; `StandardMaterial3D` alone can't produce the edge-glow. Motion progress drives the same visual language the 2D `Card` already uses, translated to 3D: emissive intensity and fresnel strength stand in for border colour and glow, and the existing scale pulse carries over unchanged.
- **3D stage** — a `stage-bg` viewport background matching the 2D stages, an unlit/ambient key light so the shader's own emissive glow reads as the primary light source (no separate ambient scene lighting to colour-match), and the same restrained violet radial glow behind the card that the 2D stages already use.
- **Category sidebar** (new, phase-18) — `v2_stuff/animations.jpg` is a loose layout reference only (vertical category list, live preview stage, per-category button grid, bottom transport bar); its cyan/pink neon glow and iconography are not borrowed — this sidebar stays inside the established dark/violet system below. A fixed-width `surface` panel, left of the stage, listing the catalog's 16 categories (mirroring Anima v1's own source folders — Attention Seeker, Back Entrances/Exits, Bouncing Entrances/Exits, Fading Entrances/Exits, Lightspeed, Rotating Entrances/Exits, Slide Exits, Sliding Entrances, Specials, Text, Zooming Entrances/Exits) as a **vertical** extension of the existing `SelectorDock`/`SelectorButton` pattern: one shared moving `accent` indicator, now sliding vertically behind whichever category row is selected, rather than horizontally behind a button. Each row is a `SelectorButton`-style label (icon + name); selection still reads through the same indicator + white text + stronger weight convention every other selector in this app already uses — no new selection language, only a new axis.
- **Animation grid** — an ordinary (horizontal, wrapping) `SelectorDock` beneath the content stage, one `SelectorButton` per preset name in the selected category (e.g. `bounce`, `flash`, `headshake`, …). Selecting a button immediately replays that preset on whichever target it's compatible with (the label, or the sprite), exactly as `SelectorDock` selection already retriggers a stage animation elsewhere in this app.
- **Target-mode dock** (new, phase-18) — a compact 3-item horizontal `SelectorDock` (`Both` / `Control` / `Sprite2D`) at the top of the content stage. Purely a visibility switch for the two target halves below it — it never changes which target a preset actually animates on, only which half(s) are shown.
- **Demo Selector tabs** (new, phase-20) — a compact 2-item `SelectorDock` (`2D` / `3D`) at the top of the Demo Selector screen — the same moving-`accent`-indicator pattern already used for Order From, Formula, Target-mode dock, and Speed control; no new selection language.
- **Demo card** (new, phase-20) — a `surface` panel, 1px `border` outline, 16px corner radius, holding a 20px line icon, a 16px/700 title, and a 13px/400 `text-secondary` one-line description. Selected/focused state brightens the border to `accent-soft` with the existing soft shadow — the same treatment `Card`/`SelectorButton` already use. Contrast: `text-secondary` on `surface` 7.4:1 ✅ AA (already-verified pairing).
- **Info bar** (new, phase-20) — a full-width `surface` bar with a `border` top divider, 16px padding, a small info icon, and one `text-secondary` line naming the next action ("Choose a demo to open it."). Structure borrowed from `v2_stuff/main-menu.jpeg`'s footer bar, recoloured to this app's own palette.

## Screen composition — phase-18 — Animation Catalog Playground

1. **ExampleHeader** — fixed icon, "Animation Catalog", subtitle "Preview every ported preset by name."
2. **Category sidebar** — the vertical `SelectorDock` variant above, one row per category; `Attention Seeker` selected by default on first load.
3. **Target-mode dock** (new) — a compact 3-item horizontal `SelectorDock` (`Both` / `Control` / `Sprite2D`) at the top of the content stage, above the target visual. `Both` is selected by default. No stage title label — the grid's own selected button already names the current preset, so a repeated title was dropped.
4. **Content stage** — a split target area, not a single `Card`. Left half: a plain `Label` reading "anima" (the Control-family target every non-`lightspeed` preset plays on). Right half: the existing `Sprite2D` placeholder (the target `lightspeed` presets play on, since only `Sprite2D`/`Node2D` has a writable `transform` for their skew). The target-mode dock controls which half(s) are visible: `Both` shows the split view; `Control` shows only the label, full width; `Sprite2D` shows only the sprite, full width. Visibility is independent of which target the currently-selected preset actually animates — an idle target just sits at rest.
5. **Animation grid** — the horizontal `SelectorDock` beneath the stage, repopulated with that category's preset names whenever the category selection changes; the first preset in the new category becomes selected and plays automatically.
6. **Playback controls** — the existing shared bar (see Component guide) unchanged: restart, reverse, complete, revert, speed dock, reduced-motion toggle — it already works against whatever motion the stage is currently playing, so this phase reuses it with no new control.

## Screen composition — Composition Example Scene

1. **ExampleHeader** — fixed icon, title, and subtitle.
2. **Content stage** — stage title and description with a compact example counter.
3. **Card row** — three artwork cards show the selected composition through their existing animated treatment.
4. **SelectorDock** — selection changes the composition shown in the stage.

## Screen composition — Grid Motion Example Scene

1. **ExampleHeader** — fixed Grid Motion title and explanatory subtitle.
2. **Grid stage** — formula name and brief explanation sit above the Order From selector and a centered 5×5 Card grid; any selected tile can be the visible start point, without rank labels.
3. **Order From and Formula controls** — set the grid's propagation order and formula without moving the stable stage.
4. **Playback controls** — the shared four-button-plus-speed-plus-toggle bar (see Component guide) sits beneath the stage; the grid visualization itself still shows no rank badges or timeline.

## Screen composition — Phase 8 — 3D Motion Example Scene

1. **ExampleHeader** — same fixed icon/title/subtitle treatment as every 2D playground, retitled for this scene.
2. **3D stage** — the 3D Card (Icosahedron) centred in a `stage-bg` viewport with the same restrained violet radial glow the 2D stages use; the shader's own emissive glow is the primary light source.
3. **Example line and SelectorDock** — a short read-only `Anima.on()` example plus the family selector, same placement and treatment as the 2D Convenience Motion Example Scene.
4. **Playback controls** — the same shared bar as every other playground (see Component guide).

## Showcase: Grid — visual direction

A deliberately separate visual system from the rest of this brief — a scripted, self-contained scene for social-media capture (`examples/showcase/grid/`), not another dev-facing playground. It targets a viewer scrolling a feed, not a developer evaluating the API, so it does not reuse the shared Theme, `ExampleHeader`, `Card`, `SelectorDock`, or the palette above. `v2_stuff/prd-social-media.md` is the source storyboard (scenes, timing, exact copy); this section is its visual system. The user supplies all art (background, inventory frame art, item icons, logo) under `examples/showcase/grid/assets/` — this brief defines the UI chrome and layout around that art, not the art itself.

**Canvas.** 1920×1080 (16:9 landscape) — matches both the user's own inspiration reference (`v2_stuff/showcase-grid.mp4`, 1280×720) and the already-supplied `assets/background.jpg` (1672×941), and suits every platform in `v2_stuff/socials/` (bluesky, linkedin, reddit) better than a vertical-only format.

**Palette.**

| Token | Value | Use |
|---|---|---|
| `showcase-scrim` | `#000000` @ 55% | Dark overlay over the supplied background image — guarantees text/UI legibility regardless of that image's own brightness; not a substitute for the drop-shadow below |
| `showcase-text` | `#FFFFFF` | All on-screen banner, caption, and CTA text |
| `showcase-text-shadow` | `#000000` @ 85%, 0/4px offset, 12px blur | Drop shadow behind every text block, placed outside the central focus area per the storyboard's own direction |
| `frame-gold` | `#C9A227` | Inventory-slot border, finale-matrix divider lines — the one warm RPG accent against an otherwise near-neutral dark scene |
| `slot-bg` | `#1A120B` @ 80% | Empty/filled inventory slot background |
| `code-vanilla-bg` | `#2A0E0E` | "Vanilla Godot" code panel |
| `code-vanilla-accent` | `#E24A4A` | "Vanilla Godot" panel border/label |
| `code-anima-bg` | `#0E2A17` | "Anima" code panel |
| `code-anima-accent` | `#4ADE80` | "Anima" panel border/label |
| `caption-bg` | `#000000` @ 60% | Bottom-center live-code caption bar |

Contrast: `showcase-text` (#FFFFFF) is guaranteed ≥ 4.5:1 (AA) against any supplied background by the 55% black scrim alone (worst case: a pure-white source image scrimmed to ~50% grey, itself already ~4.6:1 against white; the drop shadow adds a further dark halo directly behind each glyph on top of that). `showcase-text` on `code-vanilla-bg`/`code-anima-bg`/`caption-bg` all exceed 12:1.

**Typography.** Same family as the rest of the project (Inter) for consistency — the RPG feel comes from the frame art and palette, not a novelty display font. Banner/caption text is Inter ExtraBold (800); code-panel text is a monospace fallback (`Consolas, Menlo, monospace`) sized to stay readable at 1080p without crowding the panel.

- Scene banners (Scene 1's hook line, Scene 4's "ANIMA FOR GODOT 4"): 56px/800, `showcase-text`, max width 1400px, centred, top-anchored at y=64px.
- Scene 4 sub-lines ("15+ Built-in Formulas • Open Source", "Link in Comments"): 28px/700, `showcase-text`.
- Code panel header labels ("Vanilla Godot" / "Anima"): 22px/700, matching accent colour.
- Code panel body: 20px/500 monospace.
- Bottom caption bar (live code line, Scene 3): 22px/600 monospace, `showcase-text`.

**Component guide (showcase-only).**

- **Inventory frame** — centred 5×5 grid. Slot: 120×120px, 16px gap (total grid 664×664px), `slot-bg` fill, 3px `frame-gold` border, 8px corner radius, 40%-opacity inset shadow for depth. An empty slot shows border only; a filled slot's item art fills the slot with an 8px inset margin.
- **Scene banner** — top-centred text block per the Typography spec above, always inside the `showcase-scrim` + drop shadow treatment; never placed over the busiest part of the background art.
- **Code comparison card** — full-bleed two-panel layout: `code-vanilla-bg` panel left (960px), `code-anima-bg` panel right (960px), 4px centre gutter in `frame-gold`. Each panel: header label top, code body below, 48px internal padding.
- **Formula caption bar** — a `caption-bg` pill, 900px max-width, centred, 64px from the bottom edge, 16px vertical padding, showing the single active line of code per formula per the storyboard.
- **Finale matrix** — a 4×4 arrangement of 16 miniature inventory frames, each a scaled-down version of the main Inventory frame component (same slot/border treatment, 5× smaller), separated by 2px `frame-gold` divider lines. At 13.5s, a full-bleed `showcase-scrim` layer at 70% opacity dims the matrix behind the closing logo/CTA text, per the storyboard.
- **Logo/CTA block** — the existing `logo.svg` (repo root) centred over the dimmed finale matrix, with the two sub-line text rows beneath it per Typography above.

## Screen composition — phase-13 — Grid Showcase

1. **Scene 1 — Inventory Hook (0:00–0:02):** Inventory frame centred over the scrimmed background; slots fill with supplied item art as the scene banner text is visible top-centre.
2. **Scene 2 — Code Comparison (0:02–0:05):** Hard cut to the full-bleed Code comparison card; scene banner text repositions to this scene's header line.
3. **Scene 3 — Formula Showcase (0:05–0:12):** Hard cut back to the Inventory frame; the Formula caption bar updates as each of the three formulas plays.
4. **Scene 4 — Finale Matrix & CTA (0:12–0:15):** Hard cut to the Finale matrix; at 13.5s the scrim dims it and the Logo/CTA block fades in centred.

## Screen composition — phase-11 — Motion Playback Controls

1. **ExampleHeader** — reuses whichever playground scene the developer opens; not changed by this phase.
2. **Content stage / Card row** — unchanged; this phase's controls sit in the existing playback-controls row beneath any stage.
3. **Playback controls row** — four circular buttons (restart, reverse, complete, revert) in established order, left-aligned; a 3-item Speed `SelectorDock` (`0.5×`/`1×`/`2×`) to their right; the `ToggleSwitch` + "Reduced motion" label at the far right. One row, no wrap, matching `v2_stuff/ex2.jpg`'s left-to-right control hierarchy (transport → speed → accessibility switch).

## Screen composition — phase-20 — Demo Selector

1. **ExampleHeader** — fixed icon, "Demo Selector", subtitle "Browse the example playground."
2. **Demo Selector tabs** — the 2-item `SelectorDock` (`2D` / `3D`); `2D` selected by default.
3. **Demo grid** — a wrapping grid of Demo cards for the selected category: Composition, Group Motion, Convenience Motion, Grid Motion, and Animation Catalog under `2D`; 3D Motion under `3D`. Choosing a card opens that demo's own scene.
4. **Info bar** — fixed footer naming the next action ("Choose a demo to open it.").
