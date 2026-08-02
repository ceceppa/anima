### STORY-6: Derive grid propagation

#### What and why
Grid-motion authors can select a recognisably different wave or traversal from any chosen tile. Replaying a selected configuration produces the same order, which makes the effect explainable and testable.

#### Done when
- [ ] Each selected Grid formula produces its defined propagation across a tile collection: distance waves, diagonal waves, angular waves, spirals, and serpentine traversals.
- [ ] Clockwise and anticlockwise propagation use 12 o’clock around the selected point, and tiles at the same angle begin together.
- [ ] Selecting a different valid start point changes the resulting propagation from that tile; the start point is not restricted to the grid centre.
- [ ] Top, Bottom, Center, Together, Odd, Even, Random, and Index ordering choices visibly change the selected grid run as described.
- [ ] Test: fixed grids and start points replay each formula and ordering choice in a deterministic visible sequence.

#### Not this story
- Grid playback lifecycle, compilation, or Composer presentation.
- Formula families outside the selected phase scope.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_group_order.gd`; `tests/AnimaGridOrder.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Grid motion contract`; `§Group animation semantics`; `§Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Derived Scheduling`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
