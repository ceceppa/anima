### STORY-1: Anima.on() chain plays directly

#### What and why
A developer chaining a motion off `Anima.on(...)` currently has to drop out of the fluent chain and make a separate `Anima.play(motion, target)` call to start it. Adding `.play()` to the chain lets them start the motion in the same expression they built it in, matching how the rest of the convenience API already reads.

#### Done when
- [ ] `Anima.on(target).move_by(delta, duration).play()` starts the motion on `target` immediately, the same way `Anima.play(motion, target)` does
- [ ] Calling `.play()` on a motion built via `Anima.on(...)` returns the same `AnimaPlayback` controls `Anima.play()` returns
- [ ] Test: calling `.play()` on a motion that was not built via `Anima.on()`/`Anima.item()` (no captured target) reports an error naming the missing target instead of silently doing nothing

#### Not this story
- Adding `.play()` as a bare `AnimaMotion` method usable on any hand-constructed motion — only convenience-created motions (which already carry a captured target) support it this story
- Changing `Anima.play(motion, target)`'s own signature or behaviour

#### Notes
None.

#### Implementation Reference
- **Build:** `.play()` chain method on the motion returned by `Anima.on()`'s semantic methods; wraps the existing `Anima.play(self, captured_target)` entry point (`tech-spec.md §Playback interface`)
- **Files:** `addons/anima/motion/runtime/anima_on_motion_factory.gd` (captured-target storage per `tech-spec.md §Target-bound authoring contract`); `addons/anima/motion/resources/anima_property_motion.gd` (`.play()` chain method)
- **Contract:** `tech-spec.md §Target-bound authoring contract` — "A transient direct target may be used for immediate playback only"
- **Rules:** `project-rules.md §Testing` — GUT unit test; `project-rules.md §Documentation` — add the `##` doc comment for the new `.play()` method
- **Do not:** do not add `.play()` to `AnimaMotion` broadly — only the convenience-created path that already has a captured target

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
