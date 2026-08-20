# Phase Brief — Anima — Phase 20

## Why This Phase

The example playground has grown across phases 16 and 18 with no way to browse between demos, and existing demos scale inconsistently at different display sizes. Fixing both before more demos are added keeps the playground usable as it grows.

## Vision

Open the playground and it reads as one coherent gallery of demos, not a pile of loose scenes — a person can jump between 2D and 3D demos from one place, and every demo looks correctly sized wherever it's viewed.

## Design Principle

Fix navigation and consistency for what already exists — no new demo content this phase.

## Phase Goal

A person can browse every existing playground demo from one consistent, correctly-scaled selector.

## Phase Scope

1. **Playground navigation and consistency**
   a. **Demo selector** — a person can switch between 2D and 3D demo groups from one selector in the playground (visual reference: `v2_stuff/main-menu.jpeg`)
   b. **Consistent scaling across playgrounds** — every existing playground demo scales consistently at any display DPI, via a shared scaling add-on

## Not This Phase

- No new demo content — the selector only organizes demos that already exist in the playground.
- No playground consistency work beyond display scaling — input handling, theming, and other per-demo differences stay as they are.
- No broader documentation or example restructuring — that is the deferred "Full documentation structure" backlog item.

## Exit Criteria

1. **Demo selector**
   a. Open the playground: a 2D/3D selector is visible
   b. Select 2D: only 2D demos are shown
   c. Select 3D: only 3D demos are shown
2. **Consistent scaling**
   a. Open any existing playground demo on a high-DPI display: it renders at the same relative size and clarity as the others
   b. Compare two different playground demos side by side at a non-default display scale: their scaling behaves identically

## Validation Plan

### Questions

- **Q1.** Does the 2D/3D selector make it easy to find a demo?
- **Q2.** Does every existing playground demo now scale consistently at high DPI?

### Try

- Open the playground, switch tabs, and browse demos — compare the result against the `v2_stuff/main-menu.jpeg` reference.
- Run the playground demos at a non-default display scale and visually compare sizing across demos.

## Assumption Log

| ID | Assumption | Risk if wrong |
|---|---|---|
| A1 | The playground's inconsistent scaling can be fully resolved by adopting one shared scaling add-on, rather than needing per-demo fixes. | Some playgrounds need individual scaling fixes beyond what the add-on covers. |

## Acknowledged Risks

- The referenced external add-on pattern was built for a different project; it may need adaptation to this project's Godot version or `ExamplePlayground` structure.
- No new demo content ships with the selector — it only ships once existing demos are wired to it.

## Stated Technical Preferences

<!-- Verbatim from the source; not scoped or decided by `mano start`. `mano spec` evaluates these and must flag any override. -->

- "let's create an add-on that handles that like done here: /Users/asenese/Projects/terra/addons/hidpi_scale"
