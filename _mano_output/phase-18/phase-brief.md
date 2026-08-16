# Phase Brief — Anima — Phase 18

## Why this phase

Phase 17 shipped 99 ported animation presets with only automated tests to verify them — no one has actually watched them play. This phase builds the playground that lets a developer browse and see the catalog.

## Design principle

If it isn't watchable, it isn't verified — the playground exists to let a human actually see the catalog, not just trust a test suite.

## Phase goal

A developer can open a playground scene, pick any of the 99 ported presets by category, and watch it play using the existing shared playback controls.

## Phase scope

- A new `examples/playground/` scene: a category sidebar (mirroring Anima v1's own 16 source folders, not a collapsed grouping) and, per category, a grid of buttons naming each preset in it.
- Selecting a category shows that category's presets; selecting a preset plays it in a live preview stage.
- The existing shared playback controls (restart, reverse, complete, revert, speed, reduced-motion) work against whatever preset is currently playing.

## Not this phase

- No search, tags, favourites, or "duplicate into project" — this is a browse-and-preview playground, not the full Preset Browser (a separate, deferred backlog item).
- No hand-authored or example motions from other playgrounds shown here — only the 99 catalog presets.
- No dedicated menu entry or launcher — the scene is opened like any other `examples/playground/` scene, by name.
- No changes to how `.then()`/`.with()` compose motions beyond firing each child's own callbacks — the composite's own top-level callback behaviour is unchanged.

## Exit criteria

1. Open the playground
   - Scene opens: category sidebar shows all 16 categories, a preset from the default category is already playing in the stage
2. Browse by category
   - Selecting a different category: the grid updates to that category's presets; the first one plays automatically
3. Pick a preset
   - Selecting a preset from the grid: the stage replays that exact preset
4. Playback controls
   - Restart/reverse/complete/revert/speed/reduced-motion all visibly affect whichever preset is currently playing

## Validation plan

### Questions

- Does browsing the catalog by category actually make it easy to spot a preset that looks wrong?

### Try

- Open the playground and click through every category, watching each preset play from start to finish.

## Assumption log

| Assumption | Risk if wrong |
|---|---|
| This playground is deliberately a narrowed version of the deferred "Preset Browser" backlog item (browse-and-preview only, no search/tags/favourites/duplicate) — not the final shape the catalog's discovery UI will take. | The Preset Browser lands later and this playground's simple category-grid structure gets reworked rather than extended. |

## Acknowledged risks

- 99 presets in one grid per category (up to 51 in Entrance) may be a lot to scan visually — no attempt is made to sub-group or search within a category this phase.
