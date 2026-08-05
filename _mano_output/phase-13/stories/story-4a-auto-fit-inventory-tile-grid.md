### STORY-4a: Auto-fit, centred tile grid for the Inventory frame

#### What and why
A developer building the Inventory frame's tile layout needs the tiles arranged as a full, evenly-spaced grid that always fits its container without any tile being cut off at the edges — and centred so the block of tiles doesn't sit lopsided when the container's size doesn't divide evenly into whole tiles plus gaps.

#### Done when
- [ ] Given the Inventory frame's own tile and container, the algorithm places as many whole tiles as actually fit along each axis, with at least the configured minimum gap between neighbouring tiles — the count is computed from the real tile size, container size, and gap, not fixed to a specific number, and no tile is ever partially cut off at a container edge
- [ ] The resulting block of tiles is centred within its container on both axes, with equal leftover space on opposite sides
- [ ] The minimum gap between tiles is an adjustable value; increasing it and rebuilding visibly reduces how many tiles fit
- [ ] If the container is too small to fit even one whole tile, no tiles are placed rather than the algorithm erroring or placing a clipped tile
- [ ] Test: a unit test checks the computed column/row count and centred placement for at least two different container/tile/gap combinations, including one that doesn't divide evenly

#### Not this story
- The Scene-4 finale matrix's own 16 mini-grids — this story covers the main Inventory frame only; extending the same algorithm there is a separate, later decision
- Sourcing the tile artwork itself — `%Tile` is already an authored node/scene; this story only adds the placement math around it

#### Notes
`%Tile`'s own size and `%InventoryContent`'s container size together determine the fitted count — a true auto-fit, not a fixed number. This supersedes `phase-13/phase-brief.md`'s Exit Criteria wording ("an empty 5×5 inventory grid"), which described a fixed 5×5 grid; the brief itself is now stale on this point and should be corrected via `mano start` when convenient — this story does not edit it.

Per the newly-added project rule ("known, fixed image/shader assets belong in the `.tscn`"), `%Tile` should already be an `ext_resource`/scene-authored node, not loaded via code — this story only adds the placement math around it, it doesn't change how the tile art itself is sourced.

#### Implementation Reference
- **Files:** `examples/showcase/grid/layer_1.gd` (or wherever the Inventory-frame layer script ends up living after the current restructure)
- **Design:** `design-brief.md` §Showcase: Grid — visual direction (Inventory frame spec: slot size, gap) — treat the specific pixel values there as the tile/gap sizing this algorithm fits from, not a hardcoded literal grid loop or a fixed column/row count
- **Rules:** Architecture — `project-rules.md` (the new "known, fixed image/shader assets belong in the `.tscn`" rule) for how `%Tile` itself is sourced; Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
