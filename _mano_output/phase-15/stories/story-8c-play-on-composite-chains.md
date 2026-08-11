### STORY-8c: .play() works on .then()/.with() composites of different-target motions

#### What and why
A developer combining several `Anima.on()` motions built against *different* nodes — e.g. moving one panel out while moving another in and fading a third — currently has no way to start that combined chain with `.play()`; only a single, un-combined `Anima.on()` motion supports it. Extending `.play()` to `.then()`/`.with()` composites, resolving each leaf's target independently, lets a developer write and start the whole combined animation in one fluent statement instead of building it and calling `Anima.play()` separately, or issuing one `Anima.play()` call per node.

#### Done when
- [ ] `Anima.on(a).move_by(...).with(Anima.on(b).move_by(...)).with(Anima.on(c).color(...)).play()` animates `a`, `b`, and `c` each against their own node, all starting together
- [ ] The same pattern using `.then(...)` instead of `.with(...)` plays each step in sequence, each still animating its own node
- [ ] `Anima.on(node).move_by(...).with(Anima.on(node).opacity(...)).play()` (same node on both sides) still works exactly as it did before this story
- [ ] Test: `.play()` on a hand-built canonical motion (`Motion.to(...)`, no `Anima.on()` involved) still reports an error and returns `null`, unchanged from today
- [ ] Test: reverse, complete, revert, cancel, and pause all still work correctly on a playback started this way, each still affecting the correct per-leaf target

#### Not this story
- Any new validation for a composite that genuinely mixes a captured-target leaf with an uncaptured canonical leaf — that failure surfaces the same way an incorrectly-targeted canonical motion already fails today
- Group/grid motions — their per-item target resolution is a separate, already-working mechanism

#### Notes
None.

#### Implementation Reference
- **Build:** move `convenience_target: Node = null` from `AnimaPropertyMotion` up to `AnimaMotion`; move `.play()` up alongside it, checking `convenience_target` the same way; have `AnimaOnMotionFactory._stamp_origin` keep setting it exactly as it does today (now inherited, no call-site change there); update `.then(other)`/`.with(other)` on `AnimaMotion` to set the returned `AnimaSequence`/`AnimaParallel`'s own `convenience_target` to `self.convenience_target` only when it equals `other.convenience_target` (both non-null and identical) — otherwise leave the composite's `convenience_target` `null`
- **Runtime:** every leaf instance's target-consuming methods (`AnimaPropertyMotionInstance.advance()`, `restore_initial()`, `force_complete()`, `_apply_pivot()`, `_advance_spring()`) resolve an `effective_target := property_motion.convenience_target if property_motion.convenience_target != null else target` and use `effective_target` everywhere they currently use the passed-in `target` parameter; composite instances (`AnimaSequenceInstance`, `AnimaParallelInstance`, `AnimaRepeatInstance`) are unchanged — they already just forward whatever `target` they receive to each child
- **Contract:** `tech-spec.md` §Target-bound authoring contract, "`.play()` and per-leaf convenience targets (phase-15)" — exact propagation rule, `.play()` signature, and its narrowed error case (leaf `AnimaPropertyMotion` with no `convenience_target` only)
- **Files:** `addons/anima/motion/resources/anima_motion.gd` (`convenience_target`, `.play()`, `.then()`/`.with()` propagation); `addons/anima/motion/resources/anima_property_motion.gd` (remove the now-inherited `convenience_target`/`.play()`); `addons/anima/motion/runtime/anima_property_motion_instance.gd` (effective-target resolution in `advance()`/`restore_initial()`/`force_complete()`/`_apply_pivot()`/`_advance_spring()`)
- **Rules:** `project-rules.md §Testing` — extend `tests/AnimaMotion.test.gd` (or the closest existing home) with unit coverage for `convenience_target` propagation on `.then()`/`.with()`; extend `tests/Anima.integration.convenience-composition.test.gd` with an integration test exercising the exact multi-target `.play()` scenario above; `project-rules.md §Documentation` — update the `##` doc comments for `convenience_target`, `.play()`, `.then()`, and `.with()` to reflect their new home and propagation rule
- **Do not:** do not add a new validation path for a composite mixing captured and uncaptured leaves — per the phase brief's "Not this story"

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
