### STORY-8b: Grid playground demonstrates with_delay and lifecycle callbacks

#### What and why
A developer opening the grid playground after phase 15 can configure order, formula, and start point through `Anima.grid(...)`, but nothing demonstrates the phase-15 additions to that same shorthand — `with_delay(...)` or `on_started(...)`/`on_completed(...)`. Adding visible feedback for these lets them confirm the grid factory's new chain methods actually work end to end, the same way the convenience playground demonstrates `Anima.on()`'s additions.

#### Done when
- [ ] The grid motion built in `_build_grid_motion()` is delayed via `with_delay(...)` before it starts, and the delay is visibly noticeable (the grid does not begin moving the instant Restart/a selector is pressed)
- [ ] `on_started(...)` and `on_completed(...)` are wired to visible feedback in the scene (e.g. updating the formula description label or an equivalent visible element) when the grid motion starts and finishes
- [ ] Restart, Reverse, Complete, Revert, Speed, and Reduced-motion controls all still work correctly with the delay and callbacks in place

#### Not this story
- The convenience-motion playground (see story-8a)
- The showcase scenes under `examples/showcase/grid/`
- Changing the grid's own per-item stagger timing

#### Notes
None.

#### Implementation Reference
- **Build:** add `.with_delay(...)`, `.on_started(...)`, and `.on_completed(...)` to the existing chain in `_build_grid_motion()` (`examples/playground/grid_motion_playground.gd`), which currently ends `.with_stagger_interval(0.1)` before the target-collection/order configuration that follows
- **Files:** `examples/playground/grid_motion_playground.gd`
- **Contract:** `Anima.grid()`'s new chain methods per `_mano_output/phase-15/stories/story-5-grid-with-delay.md` and `story-6-grid-lifecycle-callbacks.md`
- **Rules:** `project-rules.md §Testing` — extend `tests/Anima.integration.grid-playground.test.gd` with a test asserting the delay is applied (`playback.motion.delay > 0.0` or equivalent observable pause) and that the started/completed callbacks fire once each across a full run, following the shape of that file's existing `test_restart_and_reverse_replay_the_same_selected_grid_configuration`
- **Do not:** do not add a `Test:` AC to the story itself beyond what's above — covered by the pointer above per `project-rules.md §Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
