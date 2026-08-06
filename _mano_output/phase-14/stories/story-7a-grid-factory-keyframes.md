### STORY-7a: `.keyframes()` shorthand on the grid factory

#### What and why
A developer building a keyframed grid-item animation can call `.keyframes(...)` directly on `Anima.grid(container)` — the same name and argument shape `Anima.on(target).keyframes(...)` already gives a single node — instead of nesting a separate `Motion.keyframes(...)` call inside `.with_item_motion(...)`.

#### Done when
- [ ] Calling `.keyframes(...)` on `Anima.grid(container)` and playing it animates every resolved child through the declared keyframe steps, the same as building the equivalent keyframe motion by hand and passing it to `.with_item_motion(...)`.
- [ ] `.keyframes(...)`'s duration argument sets the built keyframe motion's duration, the same way explicitly building and configuring one by hand does.
- [ ] Calling `.keyframes(...)` still returns something further chain calls (e.g. `.with_dimensions(...)` or `.play()`) can be called on, the same as every other `Anima.grid(container)` chain method.
- [ ] `Anima.on(target).keyframes(...)` continues to work exactly as it did before this story, returning the built motion directly rather than a chainable factory.
- [ ] The generated API reference documents the new method on the grid factory, including that it returns the factory (not the motion), unlike its same-named counterpart on the single-target factory.

#### Not this story
- Any change to `AnimaOnMotionFactory.keyframes()`'s own existing behaviour or return type.
- Any change to the Grid Motion Example Scene or the convenience playground — this is a runtime API addition only.

#### Notes
Mid-build addition to phase-14, requested after all 7 original stories shipped. The public-interface readiness gap this raised (ambiguity between `AnimaOnMotionFactory.keyframes()` and a new grid-side method) was resolved via a `mano spec` update before this story was written.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`keyframes(initial: Dictionary = {}, duration: float = 0.0) -> AnimaGridMotionFactory`)
- **Contract:** `tech-spec.md` §Grid convenience shorthand — exact signature, and the deliberate "same name, different return type than `AnimaOnMotionFactory.keyframes()`" decision
- **Tests:** `tests/AnimaGridMotionFactory.test.gd` (extend — `.keyframes()` sets `item_motion`/`duration` correctly, returns the factory, chains into `.play()`); `tests/Anima.integration.grid-motion-authoring.test.gd` (extend — a grid played via `.keyframes(...)` produces the same result as the hand-built equivalent)
- **Do not:** touch `AnimaOnMotionFactory.keyframes()`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
