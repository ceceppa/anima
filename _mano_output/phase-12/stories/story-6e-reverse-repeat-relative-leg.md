### STORY-6e: Reverse repeats the same segment for a repeated relative motion

#### What and why
A developer pressing Reverse on the Chained family (two `move_by(+50)` legs) expects the reverse to continue backward through each repetition the way the forward run continued forward — but instead every repetition of the reverse re-plays the exact same segment, visibly snapping back to the same starting point and re-animating the identical stretch a second time instead of continuing further back.

#### Done when
- [ ] Reversing a repeated relative motion (e.g. the Chained family's two `move_by(+50)` legs) visibly continues backward through each repetition — each repeated leg lands further back than the one before it, not repeating the same segment twice
- [ ] Test: an integration or unit test asserts each repetition of a reversed repeat produces a distinct intermediate value, not the same segment played more than once

#### Not this story
- Any change to `AnimaRepeatInstance.build_reversed()`'s "build a fresh reversed motion, restart from the top, never resume mid-cycle" rule (`tech-spec.md` §Key technical decisions) — that rule, and the preserved `count`/`delay_between`/`alternate` fields, are unaffected; only how a *relative* leg's value is reused across repetitions changes
- Any change to reversing a non-relative (`is_relative == false`) child — replaying the same absolute segment every repetition is already correct for those, since there's nothing to continue further

#### Notes
Per `tech-spec.md` §Key technical decisions: "reported backward-playback breakage is therefore treated as a regression or an untested path in [the reversal] implementation, not a missing decision; stories should reproduce it per motion kind before changing the reversal mechanism itself." This story is exactly that — the relative-child-of-a-repeat path, untested until now.

Root cause: `AnimaPropertyMotionInstance.build_reversed()` produces an absolute (non-relative) reversed motion from its own captured `from`/`to` values, regardless of whether the original motion was relative — `is_relative` isn't carried over. `AnimaRepeatInstance.build_reversed()` wraps that one reversed leg in a fresh count-N `AnimaRepeat`; because `_build_iteration_instance()` recreates a runtime from that same literal `from_value`/`to_value` every iteration, every repetition replays the identical absolute segment instead of continuing from the target's actual current value. The existing `test_chained_family_demonstrates_callbacks_repeat_and_reverse_together` only asserts the final resting position, which lands in the right place by coincidence — it never checks the intermediate path, which is why this shipped unnoticed.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_repeat_instance.gd` (`build_reversed()`, `_build_iteration_instance()`); `addons/anima/motion/runtime/anima_property_motion_instance.gd` (`build_reversed()`) for the `is_relative` field it currently drops
- **Contract:** `tech-spec.md` §Target-bound authoring contract — `is_relative` field semantics; §Key technical decisions — reversal's "restart from the top, never resume mid-cycle" rule this story must not violate
- **Rules:** Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
