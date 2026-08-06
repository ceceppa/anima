### STORY-7c: `AnimaEase.from()` — bare `Kind` accepted by `with_ease()`

#### What and why
A developer configuring a common named easing curve through `with_ease(...)` — on a keyframe motion or the grid factory — passes the `AnimaEase.Kind` value directly, the same shorthand Anima v1 offered, instead of constructing and configuring a whole `AnimaEase` resource just to say "ease in and out."

#### Done when
- [ ] Calling `.with_ease(...)` on a keyframe motion with a bare `AnimaEase.Kind` value applies that curve, the same as building and passing a full `AnimaEase` resource with that `kind` set.
- [ ] Calling `.with_ease(...)` on `Anima.grid(container)` with a bare `AnimaEase.Kind` value applies that curve to the currently-configured item motion, the same as passing a full `AnimaEase` resource.
- [ ] Passing an already-built `AnimaEase` resource to either `with_ease(...)` still works exactly as it does today, including one with non-default parameters (e.g. a tuned spring).
- [ ] Passing a value that's neither an `AnimaEase.Kind` nor an `AnimaEase` resource reports an error instead of applying a nonsensical or silently wrong easing.
- [ ] The inventory grid's icon-pulse animation passes its easing directly as `AnimaEase.Kind.EASE_IN_OUT`, with no separate resource-construction step beforehand, and plays with the same easing shape it does today.

#### Not this story
- Any change to `AnimaPropertyMotion.ease`/`.with_ease()` — untouched, out of scope.
- The `.add()` operand-broadcast gap flagged earlier — the user is handling this separately.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_ease.gd` (`static func from(value: Variant) -> AnimaEase`); `addons/anima/motion/resources/anima_keyframe_motion.gd` (`with_ease(value: Variant)`); `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`with_ease(value: Variant)`); `examples/showcase/grid/inventory_grid.gd` (`play()` — pass `AnimaEase.Kind.EASE_IN_OUT` directly, remove the `pulse_ease` local)
- **Contract:** `tech-spec.md` §Easing curve library (`AnimaEase.from()` — exact coercion and error behaviour), §Keyframe interface and §Grid convenience shorthand (both updated `.with_ease()` rows)
- **Tests:** `tests/AnimaEase.test.gd` (extend — `.from()` passes an `AnimaEase` through unchanged, wraps a bare `Kind`, errors on an invalid type); `tests/AnimaKeyframeMotion.test.gd` (extend — `.with_ease()` accepts a bare `Kind`); `tests/AnimaGridMotionFactory.test.gd` (extend — `.with_ease()` accepts a bare `Kind`); `tests/Anima.integration.grid-showcase-inventory-hook.test.gd` (existing per-icon pulse test is this story's regression guard — must still pass unchanged)
- **Do not:** change `AnimaPropertyMotion.ease`/`.with_ease()`'s existing `AnimaEase`-only signature

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
