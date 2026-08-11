### STORY-4: with_ease accepts AnimaEase.Kind directly

#### What and why
A developer setting an easing curve on a motion built through `Anima.on(...)` wants to write `with_ease(AnimaEase.Kind.EXPONENTIAL)` directly — the same shorthand already available on keyframe and grid motions — instead of constructing a whole `AnimaEase` resource by hand just to name a curve.

#### Done when
- [ ] `Anima.on(target).move_by(delta, duration).with_ease(AnimaEase.Kind.EXPONENTIAL)` eases the motion with that curve
- [ ] Passing an already-built `AnimaEase` resource to `with_ease` still works unchanged
- [ ] Test: passing an unsupported value type to `with_ease` reports an error instead of silently ignoring it

#### Not this story
- Changing `AnimaPropertyMotion.ease`'s own stored type
- Changing `AnimaEase.from()`'s existing behaviour for keyframe/grid motions

#### Notes
None.

#### Implementation Reference
- **Build:** `AnimaPropertyMotion.with_ease(value)` routes a bare `AnimaEase.Kind` through the existing `AnimaEase.from(value)` factory (`tech-spec.md §Easing curve library`) before assigning `ease` — the same conversion `AnimaKeyframeMotion.with_ease()`/`AnimaGridMotionFactory.with_ease()` already perform
- **Files:** `addons/anima/motion/resources/anima_property_motion.gd`
- **Contract:** `tech-spec.md §Easing curve library` — `AnimaEase.from()` behaviour and its error case for unsupported input types
- **Rules:** `project-rules.md §Testing` — GUT unit test; `project-rules.md §Documentation` — update the `##` doc comment for `with_ease` to note the accepted `AnimaEase.Kind` shorthand

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
