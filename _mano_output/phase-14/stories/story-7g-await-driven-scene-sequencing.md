### STORY-7g: Await-driven scene sequencing

#### What and why
Watching the RPG-inventory showcase video, each scene now begins the instant the previous scene's own animation actually finishes playing, instead of at a fixed clock mark baked into the orchestrator — so if any scene's animation ever runs faster or slower, the whole show stays in sync with itself instead of cutting to the next scene mid-animation or sitting idle after one finishes early.

#### Done when

##### Scene sequencing
- [ ] Scene 2 (code comparison) becomes visible only after Scene 1's inventory-grid reveal has finished playing, not at a fixed elapsed-time mark.
- [ ] Scene 3 (formula showcase) becomes visible only after Scene 2's own display has finished, not at a fixed elapsed-time mark.
- [ ] Scene 4 (finale matrix) becomes visible only after Scene 3's third and final formula replay has finished playing, not at a fixed elapsed-time mark.
- [ ] Within Scene 3, each of the three formula replays starts only after the previous one has finished playing, not on a fixed per-formula timer.
- [ ] The dim overlay and closing logo/CTA appear only once every mini-grid in the Scene 4 finale matrix has finished its own animation, not at a fixed elapsed-time mark.

##### Test determinism
- [ ] Test: the entire four-scene sequence, from opening the scene to the closing logo/CTA appearing, can still be driven to completion by a test that advances time in fixed increments, with no dependency on real engine frame timing.

#### Not this story
- Authoring new visual animation content for Scene 2 — the design brief documents it as a hard cut with no motion of its own (`design-brief.md` line 119). This story only gives it a minimal placeholder `AnimaPlayback` so the sequencing chain has something to await; the user will replace it with real animation content separately.
- Scene 4's own internal centre-outward wave timing — already driven by `AnimaMotion.delay` baked into each mini-grid's motion, not elapsed-time polling; unaffected by this story.
- The one-time startup pause before Scene 1 begins in `_ready()` — a single beat before the sequence starts, not part of the elapsed-time scene-to-scene scheduling this story replaces.

#### Notes
- `%Layer1.play()` (`layer_1.gd`) currently returns nothing; it must return the `AnimaPlayback` that `%InventoryGrid.play()` already produces so the orchestrator has something to await for the Scene 1 → Scene 2 transition.
- Temporary/bounded per Step 0d: Scene 2's placeholder `AnimaPlayback` duration is a stand-in until the user adds Scene 2's real animation — any reasonable fixed duration is acceptable here, since the actual pacing is the user's own follow-up work.

#### Implementation Reference
- **Files:** `examples/showcase/grid/grid_showcase.gd` — replace `_process()`, `_advance_show()`, `_beat_for_elapsed()`, `_update_beat()`, `_elapsed`, `SCENE1_START`/`SCENE2_START`/`SCENE3_START`/`SCENE4_START`/`DIM_AT`/`TOTAL_DURATION`/`SCENE3_FORMULA_DURATION` with an async sequencing function that plays one scene, awaits its `AnimaPlayback`'s `finished` signal, then plays the next; `examples/showcase/grid/layer_1.gd` — `play()` returns the `AnimaPlayback` from `%InventoryGrid.play()` instead of discarding it
- **Contract:** `AnimaPlayback.finished(success: bool)` (already public) is the completion signal to `await`; `AnimaPlayback.step(delta)` (already public, `tech-spec.md` §Manual stepping) stays the only per-frame driver anywhere in this scene
- **Do not:** reintroduce `_process()`-based elapsed-time polling to decide which scene is showing; do not use `SceneTreeTimer`/`await ... timeout` for any per-scene dwell (including Scene 2's placeholder) — a manually-stepped `AnimaPlayback` is required instead so the sequence stays deterministically test-drivable, the same reasoning `layer_1.gd`'s own doc comment already states for why it avoids `SceneTreeTimer`
- **Tests:** `tests/Anima.integration.grid-showcase.test.gd` — rewrite every test currently driving the scene via `scene._advance_show(delta)` against fixed elapsed-time markers; drive the scene's currently-active playback(s) forward via manual `.step(delta)` calls until each awaited transition resolves instead (`project-rules.md` §Testing)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
