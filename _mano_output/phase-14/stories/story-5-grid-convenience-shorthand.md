### STORY-5: One-line grid motion shorthand

#### What and why
A developer who wants to animate a container's children as a grid can call one line — the same ergonomics `Anima.on()` already gives a single node — instead of hand-building a target collection and a grid motion and calling play separately every time. The existing Grid Motion Example Scene switches to this shorthand internally, proving it plays exactly the same as before.

#### Done when
- [ ] Starting a grid motion through the one-line shorthand animates the same targets, in the same order, with the same timing as building the equivalent grid motion by hand and playing it.
- [ ] The shorthand's chainable settings (item motion, dimensions, distance formula, start point, stagger interval) each take effect the same way setting the matching field on a hand-built grid motion would.
- [ ] Calling play through the shorthand with no item motion ever set reports an error and plays nothing, instead of silently animating with an empty template.
- [ ] Opening the Grid Motion Example Scene and running it behaves exactly as it did before this story, now driven internally by the shorthand instead of a hand-built motion.
- [ ] The generated API reference documents the shorthand's entry point and every chainable setting.

#### Not this story
- Any new visible control or UI in the Grid Motion Example Scene — this story only changes what builds the motion internally.
- The Dynamic Values playground family — story-6.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (new — `AnimaGridMotionFactory`); `addons/anima/motion/runtime/anima.gd` (`Anima.grid(container)`); `examples/playground/grid_motion_playground.gd` (switch its internal grid-motion construction to the shorthand)
- **Contract:** `tech-spec.md` §Grid convenience shorthand — exact chain-method names, defaults inherited from `AnimaGridMotion`'s own constructor, `.play()`'s error behaviour on a missing item motion
- **Tests:** `tests/AnimaGridMotionFactory.test.gd` (new, unit — chain methods, missing-item-motion error); `tests/Anima.integration.grid-motion-authoring.test.gd` (extend — shorthand produces a play equivalent to the hand-built path)
- **Do not:** add a Dynamic Values family or any playground UI change in this story

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
