### STORY-8: Fade convenience shorthands

#### What and why
A developer fading a node in or out today has to reach for the more general `.opacity(to, duration)` and remember which value means which direction. `fade_in(...)` and `fade_out(...)` name the intent directly, the same way `move_by()`/`scale_by()` already read as intent-named shortcuts over their generic property methods.

#### Done when
- [ ] `Anima.on(node).fade_out(duration).play()` fades `node`'s opacity from its current value to `0`
- [ ] `Anima.on(node).fade_in(duration).play()` fades `node`'s opacity from its current value to `1`
- [ ] Test: `fade_out`/`fade_in` on a non-`CanvasItem` target fails validation the same way `.opacity()` already does

#### Not this story
- Adding any other named shorthand beyond `fade_in`/`fade_out`

#### Notes
Depends on Story 1 (`.play()` on the convenience chain) for the AC's `.play()` calls to be meaningful end-to-end, but `fade_in`/`fade_out` themselves can be built and tested independently.

#### Implementation Reference
- **Build:** `.fade_in(duration = 0.0)` / `.fade_out(duration = 0.0)` on `AnimaOnMotionFactory`, delegating to the existing `.opacity(to, duration)` (`tech-spec.md §Convenience method interface`) with `to = 1.0` / `to = 0.0`
- **Files:** `addons/anima/motion/runtime/anima_on_motion_factory.gd`
- **Rules:** `project-rules.md §Testing` — GUT unit test; `project-rules.md §Documentation` — add the `##` doc comments for `fade_in` and `fade_out`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
