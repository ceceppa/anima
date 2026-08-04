### STORY-1: Fix reverse across motion kinds

#### What and why
Motion authors can trust that reversing any motion — a single property change, a composed sequence or parallel, a group, or a grid — returns every target to the state it started from, instead of the reverse control silently doing nothing or leaving a target in the wrong place.

#### Done when
- [ ] Reversing a single-target motion authored through `Anima.on()` (demonstrable in the Convenience Motion Example Scene) returns the target to its starting value along the same path played backward.
- [ ] Reversing a Sequence or Parallel composition (demonstrable in the Composition Example Scene) reverses each child and their order/timing so the visible result matches playing the reversed motion forward from its natural start.
- [ ] Reversing a Group Motion (demonstrable in the Group Motion Example Scene, across Sequential/Parallel/Stagger playback and every ordering mode) returns every item to its starting state along the same resolved schedule played backward.
- [ ] Reversing a Grid Motion (demonstrable in the Grid Motion Example Scene, across at least one wave-based and one strict-traversal formula) returns every cell to its starting state.
- [ ] A Group Motion whose item motion is itself a Sequence or Parallel (nested composition) reverses to the same starting state as an equivalent non-nested item motion.
- [ ] Test: each motion kind above has an automated reverse-then-compare-to-forward-reversed check.
- [ ] Test: reversing before any frame has played reports an error rather than silently doing nothing, for every motion kind.

#### Not this story
- Keyframe motion reversal (KeyFrames aren't built yet).
- `Anima.play_backwards()` or any other way to start already reversed (story-4).
- Re-verifying reversal for motion kinds untouched by this bug and already covered by Phase 7's parity tests.

#### Notes
Start with a reproduction per motion kind before changing the reversal mechanism. `tech-spec.md §Key technical decisions` already claims this coverage exists; determine whether each failure is a genuine regression or an untested path before altering `AnimaMotionInstance.build_reversed()` or `AnimaGroupPlayback` for that kind.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_playback.gd`; `addons/anima/motion/runtime/anima_property_motion_instance.gd`; `addons/anima/motion/runtime/anima_group_playback.gd`; `addons/anima/motion/runtime/anima_group_scheduler.gd`; `tests/AnimaPlayback.test.gd`; `tests/Anima.integration.nested_composition.test.gd`; `tests/Anima.integration.convenience-playground.test.gd`; `tests/Anima.integration.group-motion-playground.test.gd`; `tests/Anima.integration.grid-playground.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Key technical decisions` (`reverse()` coverage claim); `§Grid motion contract`
- **Rules:** `_mano_output/project-rules.md §Derived Scheduling`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
