### STORY-8i: Grid showcase tests no longer leak playbacks across the suite

#### What and why
`Anima.integration.grid-showcase.test.gd`'s tests drive `grid_showcase.gd`'s real-timer-based `_run_show()` — several either check an early checkpoint without awaiting full completion, or await it while a downstream real-timer chain (`_wait_for_next()`) is still pending. Either way, an `AnimaPlayback` could still be registered in `AnimaRuntime.active_playbacks` when that test's own scene was torn down, then kept ticking against freed nodes on every later, unrelated test's frames — intermittently crashing or corrupting whichever test happened to run next.

#### Done when
- [ ] The full GUT suite passes cleanly regardless of run order, with no cross-test "previously freed"/null-target errors originating from grid-showcase tests
- [ ] `test_scene3_plays_after_scene1_and_scene2` reliably detects Scene 3 starting (its label text changing from the untouched placeholder)

#### Not this story
- Redesigning `grid_showcase.gd`/`scene_3.gd`'s own timing or structure — that's the showcase scene's own content, not a library or test-infrastructure concern
- General `AnimaRuntime` API changes — this uses the already-public `active_playbacks` array as-is

#### Notes
None.

#### Implementation Reference
- **Build:** `after_each()` in the test file cancels every still-active `AnimaPlayback` (`AnimaRuntime.get_singleton().active_playbacks.duplicate()`, then `.cancel()` each) after every test in this file
- **Files:** `tests/Anima.integration.grid-showcase.test.gd`
- **Rules:** `project-rules.md §Testing` — this is itself the required test-isolation fix; no further coverage needed beyond confirming the full suite passes

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
