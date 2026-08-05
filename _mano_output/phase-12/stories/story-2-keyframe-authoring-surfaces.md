### STORY-2: Dictionary and fluent keyframe authoring produce the same resource

#### What and why
A developer who prefers building things up step by step, rather than writing one big dictionary literal, currently has no way to author a keyframe motion incrementally. This story gives them a fluent alternative — `Motion.keyframes().at(...).at(...)` — that produces the exact same result as the dictionary form, on both the global builder and the target-bound `Anima.on()` factory.

#### Done when
- [ ] `Motion.keyframes({...})` (dictionary form) and the equivalent built via `Motion.keyframes().at(...).at(...)` (fluent form) produce tracks with identical offsets, values, and easing
- [ ] `Anima.on(target).keyframes({...}, duration)` produces the same kind of motion the `Motion.keyframes()` dictionary form does, with `duration` set
- [ ] `.at(offsets, values)` returns the same motion (chainable), and merging a second `.at()` call for a new offset on an existing property adds a new stop to that property's track, sorted correctly alongside the ones already there
- [ ] `.with_duration(value)` sets the motion's duration directly
- [ ] Test: an equivalence test builds the same authored shape via both forms and asserts the resulting tracks match; GUT coverage for `.at()` merging into an existing track and `.with_duration()`
- [ ] Test: every new public method has an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for it

#### Not this story
- The offset/track parsing itself — both forms call into story 1's parser; this story is only the two entry points and the fluent merge path
- A bare `.duration(...)` method — collides with the existing `duration` field name, so this project follows its own established `with_` prefix convention instead (`tech-spec.md` §Keyframe motions)

#### Notes
Depends on story 1 (the resource and its internal parser must exist first).

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_motion_builder.gd` (`Motion.keyframes()`); `addons/anima/motion/runtime/anima_on_motion_factory.gd` (`.keyframes()`); `addons/anima/motion/resources/anima_keyframe_motion.gd` (`.at()`, `.with_duration()`)
- **Contract:** `tech-spec.md` §Keyframe interface — exact signatures and defaults for `Motion.keyframes()`, `AnimaOnMotionFactory.keyframes()`, `.at()`, `.with_duration()`
- **Rules:** Testing, Documentation — same sections as story 1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
