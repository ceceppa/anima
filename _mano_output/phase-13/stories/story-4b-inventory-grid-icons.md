### STORY-4b: Icons inside the Inventory Grid component

#### What and why
A developer looking at the Inventory frame needs each tile to actually show an item icon, centred and sized sensibly within its own tile — and the whole tile-plus-icon system needs to live as its own `%InventoryGrid` component instead of logic spread across the Inventory Hook layer's own script, so it can be reused and reasoned about on its own.

#### Done when
- [ ] Each placed tile shows one icon image loaded from `examples/showcase/grid/assets/icons`, centred within that tile
- [ ] No icon is ever larger than a configurable maximum percentage of its tile's size (default 80%) — the icon keeps its own aspect ratio, never stretched or overflowing its tile
- [ ] That maximum-size percentage is adjustable, the same way the minimum gap already is (story 4a); lowering it and rebuilding visibly shrinks every icon
- [ ] The tile-plus-icon placement system is its own `%InventoryGrid` component, not logic inline in the Inventory Hook layer's own script
- [ ] If `assets/icons/` has no image files, tiles still render using the already-established fallback placeholder instead of erroring
- [ ] Test: an integration test builds the grid against the real `assets/icons/` folder and asserts every placed tile has a centred icon child no larger than the configured maximum ratio of the tile's own size

#### Not this story
- Which specific icon each tile shows, or any particular assignment order across the available icons — any reasonable, deterministic assignment satisfies this story
- Any change to the tile-fitting/centring math itself — story 4a's algorithm is reused as-is by the new component, not redesigned

#### Notes
`%InventoryGrid` is the natural new home for what story 4a built directly in `InventoryHookLayer` (`_tile`, `_inventory_content`, `_build_tile_grid()`, `_fit_count()`, `_grid_origin()`) — moving that logic into its own component, not duplicating it, is the expected shape of this story.

Per the project rule added this phase ("known, fixed image/shader assets belong in the `.tscn`, never `load()` in script"), loading icons via code remains correct here specifically because the folder's file count/identity isn't known until the scene runs — the rule's own explicit runtime-count exception.

Depends on: story 4a.

#### Implementation Reference
- **Files:** a new `examples/showcase/grid/inventory_grid.gd`/`.tscn` component (or wherever `%InventoryGrid` ends up living in the current restructure), composed into `examples/showcase/grid/layer_1.tscn`
- **Rules:** Architecture — `project-rules.md` (the runtime-count-unknown exception to "known, fixed image/shader assets belong in the `.tscn`"); Naming — `project-rules.md` §Naming (plain descriptive component name, no `Anima` prefix); Editor-Authored Content — `project-rules.md` §Example Scenes (the max-icon-ratio value as an adjustable `@export`, following `min_gap`'s own established pattern); Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
