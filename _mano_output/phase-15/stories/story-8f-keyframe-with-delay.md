### STORY-8f: AnimaKeyframeMotion supports with_delay

#### What and why
A developer delaying a keyframe motion built through `Anima.on(...).keyframes(...)` currently has no `with_delay()` — only property motions got one in story-3. Adding it gives keyframe motions the same delay chaining every other leaf motion type already has.

#### Done when
- [ ] `Anima.on(node).keyframes({...}).with_delay(0.5)` delays the keyframe motion's start by the given number of seconds
- [ ] Omitting `with_delay` leaves the keyframe motion starting with no delay, unchanged from today
- [ ] Test: `with_delay` returns the same `AnimaKeyframeMotion` so it stays chainable with `.with_duration()`/`.with_ease()`/`.with_pivot()` in any order

#### Not this story
- Moving `with_delay` onto the shared `AnimaMotion` base — kept as a per-leaf-type method, matching the existing `with_duration`/`with_ease`/`with_pivot` convention on both leaf types rather than introducing a new shared-base pattern

#### Notes
None.

#### Implementation Reference
- **Build:** `with_delay(value: float) -> AnimaKeyframeMotion` sets the inherited `AnimaMotion.delay` field directly and returns self — mirrors `AnimaPropertyMotion.with_delay()` exactly
- **Files:** `addons/anima/motion/resources/anima_keyframe_motion.gd`
- **Contract:** `tech-spec.md` §Keyframe interface — new `.with_delay(value)` row
- **Rules:** `project-rules.md §Testing` — GUT unit test on `AnimaKeyframeMotion`; `project-rules.md §Documentation` — add the `##` doc comment for the new method

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
