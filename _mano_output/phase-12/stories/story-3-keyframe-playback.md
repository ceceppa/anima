### STORY-3: Keyframe playback and evaluation

#### What and why
A developer who has authored a keyframe motion (story 1/2) still can't actually play it — nothing evaluates the tracks against a running clock yet. This story makes an authored keyframe motion actually animate its target through every declared stop, in order, at whatever speed the playback is running.

#### Done when
- [ ] Playing a keyframe motion with a single track and two stops (`"from"`/`"to"`) animates the target's property from the first value to the second over the motion's duration
- [ ] Playing a keyframe motion with a mid-point stop (e.g. `"from"`/`50`/`"to"`) passes visibly through the mid-point value partway through the motion, not just interpolating straight from start to end
- [ ] Playing a keyframe motion with multiple properties animates all of them together, each following its own track
- [ ] A per-stop `_ease` value is respected for the segment arriving at that stop; a stop with no `_ease` uses the motion's default easing
- [ ] A single-stop track holds that value for the whole motion (no interpolation, no error)
- [ ] Changing a playback's speed (`speed_scale`) or reversing direction changes how fast a keyframe motion plays, the same as every other motion kind — no keyframe-specific code needed for this, confirming the inherited speed/direction fields actually reach `advance()`
- [ ] Test: GUT unit tests on `AnimaKeyframeMotionInstance.advance()` for the mid-point pass-through, multi-property, single-stop, and per-segment-easing cases; an integration test drives a keyframe motion through `Anima.play()`
- [ ] Test: every new public method has an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for it

#### Not this story
- Reversal — see story 4
- The playground demo — see story 5
- Dynamic values inside keyframes — depends on `AnimaValue`, not built

#### Notes
Depends on story 1 (the resource/tracks it evaluates).

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_keyframe_motion_instance.gd`
- **Contract:** `tech-spec.md` §Keyframe motions — the evaluation algorithm (bracketing stops, segment-local `u`, per-segment easing, boundary clamping); `estimate_duration()`/`create_runtime()`/`validate()` base-contract requirements
- **Rules:** Patterns — `project-rules.md` §Patterns (every `AnimaMotion` subtype implements the base contract explicitly, no inherited default); Testing, Documentation — same sections as story 1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
