### STORY-7b: One-line inventory pulse via `.keyframes()` / `.with_duration()` / `.with_ease()`

#### What and why
A developer looking at the RPG showcase's source sees its icon-pulse animation authored as a single fluent statement built on `Anima.grid(...)` — dimensions, propagation, the keyframe steps, duration, and easing all in one chain — instead of a target-collection, a separate motion-building function, and a multi-field resource assembled by hand. This is the showcase's own advertisement for how simple the API is meant to be.

#### Done when
- [ ] `AnimaKeyframeMotion.with_ease(...)` sets the motion's default easing and returns the motion, chainable directly onto `Anima.on(target).keyframes(...)` or `Motion.keyframes(...)`.
- [ ] `Anima.grid(container).with_duration(...)` sets the currently-configured item motion's duration and returns the factory, chainable into further calls or `.play()`.
- [ ] `Anima.grid(container).with_ease(...)` sets the currently-configured item motion's easing (or default easing, for a keyframe motion) and returns the factory, chainable the same way.
- [ ] Calling either grid-factory method before an item motion is set, or against an item motion with no duration/ease of its own, reports an error and leaves the factory otherwise still usable, instead of silently doing nothing or crashing.
- [ ] The inventory grid's icon-pulse animation is authored as a single fluent statement built on `Anima.grid(...).keyframes(...)`, and plays identically to how it plays today — same fade, same per-icon proportional scale, same easing shape.

#### Not this story
- Any other consumer of `.with_duration()`/`.with_ease()` beyond the inventory grid — this story wires them into the one place that motivated them.
- Any change to `AnimaOnMotionFactory` itself — `.with_ease()` lives on `AnimaKeyframeMotion`, already reachable from `Anima.on(target).keyframes(...)` with no factory-level change needed.
- Any change to `AnimaPropertyMotion.with_ease()` — it already exists and is untouched.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_keyframe_motion.gd` (`with_ease(value: AnimaEase) -> AnimaKeyframeMotion`); `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`with_duration(value: float)` / `with_ease(value: AnimaEase) -> AnimaGridMotionFactory`); `examples/showcase/grid/inventory_grid.gd` (`play()` rewritten as one fluent `Anima.grid(_icons)...` statement; `_build_item_motion()` folds into it)
- **Contract:** `tech-spec.md` §Keyframe interface (`.with_ease()`), §Grid convenience shorthand (`.with_duration()`/`.with_ease()` — exact fields touched per item-motion kind, and the error behaviour for a missing or incompatible item motion)
- **Tests:** `tests/AnimaKeyframeMotion.test.gd` (extend — `.with_ease()` sets `default_ease`, returns self); `tests/AnimaGridMotionFactory.test.gd` (extend — `.with_duration()`/`.with_ease()` set the right field for a property-motion and a keyframe-motion item motion, and report an error for a missing/incompatible one); `tests/Anima.integration.grid-showcase-inventory-hook.test.gd` (the existing per-icon pulse test is this story's regression guard — must still pass unchanged)
- **Do not:** add `duration`/`ease` reach-through for any `item_motion` kind beyond `AnimaPropertyMotion` and `AnimaKeyframeMotion`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
