### STORY-6: Anima.grid() supports on_started/on_completed

#### What and why
A developer wants to know when a grid motion starts and finishes, the same way they already can with `.on_started()`/`.on_completed()` on any other motion, but `Anima.grid(...)` doesn't expose them yet.

#### Done when
- [ ] `Anima.grid(container).on_started(callback)` invokes `callback` once when the grid motion starts
- [ ] `Anima.grid(container).on_completed(callback)` invokes `callback` once when the grid motion finishes successfully
- [ ] Test: `on_completed`'s callback is not invoked when the grid motion is cancelled before finishing

#### Not this story
- Adding per-item started/completed callbacks for individual grid cells

#### Notes
None.

#### Implementation Reference
- **Build:** `.on_started(callback)`/`.on_completed(callback)` chain methods on the grid factory, setting `on_started_callback`/`on_completed_callback` on the constructed `AnimaGridMotion` — same fields and semantics `tech-spec.md §Target-bound authoring contract` already defines for any motion
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd`
- **Contract:** `tech-spec.md §Target-bound authoring contract` — `on_completed_callback` fires "only on a successful finish", never on cancellation
- **Rules:** `project-rules.md §Testing` — GUT unit test; `project-rules.md §Documentation` — add the `##` doc comments for both callback methods on the grid factory

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
