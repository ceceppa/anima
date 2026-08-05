### STORY-6d: Complete/Revert stop Keyframes instead of snapping

#### What and why
A developer pressing Complete or Revert while a Keyframes-family motion is playing in the convenience motion playground gets the same broken behaviour Phase 11 already fixed for every other family: the card just freezes wherever it happens to be, instead of Complete snapping to the authored end value or Revert snapping back to the start.

#### Done when
- [ ] Pressing Complete on a running Keyframes motion in the convenience motion playground snaps every animated property to its authored end-of-motion value immediately, not wherever it happened to be when pressed
- [ ] Pressing Revert on a running Keyframes motion in the convenience motion playground snaps every animated property back to its pre-animation starting value immediately
- [ ] Test: an integration test presses the real Complete button, then (on a fresh run) the real Revert button, on a running Keyframes family run inside the actual playground scene, and asserts the resulting property values — not just that the buttons emit their signals

#### Not this story
- Any change to Complete/Revert for any other family — Phase 11 already fixed those; this is scoped to the gap left by the new `AnimaKeyframeMotionInstance`
- Any change to `AnimaPlayback.complete()`/`revert()` themselves — that logic is already correct, proven by every other motion kind; only the missing per-instance overrides are in scope

#### Notes
Root cause identified by reading `addons/anima/motion/runtime/anima_motion_instance.gd`: `force_complete()`/`restore_initial()` are no-ops by default on the base `AnimaMotionInstance`, and every other leaf/composite instance (`AnimaPropertyMotionInstance`, `AnimaSequenceInstance`, `AnimaParallelInstance`, `AnimaRepeatInstance`, `AnimaRaceInstance`, `AnimaConditionalInstance`, `AnimaStaggerInstance`) already overrides both. `AnimaKeyframeMotionInstance` is the only one that doesn't — exactly the "buttons behave like a plain stop" symptom Phase 11's story-6a fixed everywhere else.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_keyframe_motion_instance.gd`
- **Contract:** `AnimaMotionInstance.force_complete()`/`restore_initial()` (`addons/anima/motion/runtime/anima_motion_instance.gd`) — the contract every other instance already implements; `AnimaPropertyMotionInstance`'s own `force_complete()`/`restore_initial()` for the pattern already used elsewhere in this codebase
- **Rules:** Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
