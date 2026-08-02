### STORY-12: Showcase grid motion

#### What and why
Developers can run a focused 5×5 Card grid and watch any formula begin from the tile they choose. The demonstration makes Grid motion’s order, selected point, and replay behaviour legible without exposing unused timeline or rank tools.

#### Done when
- [ ] Running the Grid playground shows a 5×5 Card grid, Order From, Formula, and restart/reverse controls in the established example-scene visual language.
- [ ] Tapping any Card makes it the visible persistent start point, immediately replays the selected configuration, and retains that point for later replays and configuration changes until another Card is tapped.
- [ ] Selecting Top, Bottom, Center, Together, Odd, Even, Random, or Index changes the observed grid ordering; Top is the initial selection.
- [ ] Selecting a formula from the picker returns to the grid and replays the chosen order from the retained point.
- [ ] The playground exposes no rank labels, timeline, speed, or reduced-motion controls.
- [ ] The scene uses the shared Theme, shared Card, shared selector components, shared header, and `ExamplePlayground` root.
- [ ] Test: selecting a non-central Card, an order, and a formula produces the matching Grid run; restart and reverse replay that same selected configuration.

#### Not this story
- Additional Grid formulas beyond the phase contract.
- Retrofitting existing playgrounds to `ExamplePlayground`.

#### Notes
Depends on: stories 0, 5, 6, and 7.

#### Implementation Reference
- **Files:** `examples/grid_motion_playground.tscn`; `examples/grid_motion_playground.gd`; `tests/Anima.integration.grid-playground.test.gd`
- **UX:** `_mano_output/ux-flow.md §Grid Motion Example Scene`; `§Grid Formula Picker`
- **Design:** `_mano_output/design-brief.md §Grid stage`; `§Order From`; `§Formula control and picker`; `§Screen composition — Grid Motion Example Scene`
- **Rules:** `_mano_output/project-rules.md §Example Scenes`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
