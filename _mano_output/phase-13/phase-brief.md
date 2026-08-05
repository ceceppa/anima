# Phase Brief — Anima — Phase 13

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Anima's only demo surfaces are the developer-facing playgrounds — Phase 12's review flagged that they're useful for testing but not built to be shown off. Anima needs a marketing-ready showcase that can actually get watched on social media.

## Design Principle

Every visual and animation choice serves getting the video watched and shared, not developer testing — this is content, not another playground.

## Phase Goal

A developer can open one Godot scene, press play, and watch the full ~15-second RPG-inventory storyboard run end-to-end exactly as scripted — ready to capture with Godot's own Movie Writer for a social post.

## Phase Scope

- A dark-fantasy RPG inventory showcase scene composed of the four scripted beats: items rippling into a MxN inventory grid, a vanilla-Godot-vs-`Anima.grid()` code comparison, three grid formulas demonstrated back-to-back with their triggering code line shown live, and a 4x4 matrix of 16 inner 5x5 grids animating together into a closing logo/call-to-action
- The closing matrix plays its 16 inner grids in a centre-outward wave, one whole inner grid's own animation starting per wave, with the delay between waves exposed as an adjustable value
- Text overlays for each scene's banner/caption content, as simple placeholder copy the user can revise directly
- The scene consumes whatever RPG art (background, inventory frame, item icons) the user places under its own assets location; sourcing or creating that art is not part of this phase

## Not This Phase

- Producing or exporting the final video file — the user renders it separately once satisfied with the scene, via Godot's own capture tooling
- Creating, sourcing, or licensing any RPG art assets — the scene consumes assets the user supplies
- Any new Anima runtime capability — every showcased formula (centre-outward, corner-diagonal, random) already exists; this phase composes and demos them
- Publishing, scheduling, or posting to any social platform

## Exit Criteria

1. Playing the scene
   - Open the showcase scene and press play: it runs the full sequence automatically, with no manual triggering between beats
2. The four beats
   - 0:00–0:02: an empty 5x5 inventory grid fills as items ripple into its slots, with the opening banner text visible
   - 0:02–0:05: a full-screen code comparison appears, vanilla Godot beside a single `Anima.grid()` call, both fully readable
   - 0:05–0:12: the inventory grid replays three distinct grid formulas back-to-back, each with its triggering code line shown at the bottom of the screen
   - 0:12–0:15: a 4x4 matrix of 16 inner grids animates in a centre-outward wave into a closing logo and call-to-action text
3. Adjustable timing
   - Changing the outer matrix's wave delay value and replaying the scene visibly changes how fast the wave spreads across the 16 grids

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The 4x4 matrix's centre-outward wave, where each wave step starts one whole inner grid's own animation, is achievable with Anima's existing group/composition primitives, with no new runtime capability | If nesting one grid motion as a single group "item" isn't actually supported today, this phase's finale scene needs new runtime work, not just composition |

## Acknowledged Risks

- The RPG art assets this scene depends on (background, inventory frame, item icons) are supplied separately by the user and may not all be ready by the time the scene is built — the scene should degrade to visibly obvious placeholders rather than fail silently if an asset is missing

## Stated Technical Preferences

<!-- Verbatim from the source; not scoped or decided by `mano start`. `mano spec` evaluates these and must flag any override. -->

- "I'll be placing the assets in: examples/showcase/grid/assets."
- "I'll be using the Godot Movie Writer once I'm happy with the scene created"

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
