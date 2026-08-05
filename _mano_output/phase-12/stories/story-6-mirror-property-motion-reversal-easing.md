### STORY-6: Mirror easing on AnimaPropertyMotion reversal

#### What and why
A developer reversing an ordinary property motion (not a keyframe) currently gets the same easing shape played backward — an ease-in segment still looks like ease-in when reversed, instead of the correctly-mirrored ease-out. This was left as a known, separate gap while keyframe reversal was being built; bringing it in now means both reversal paths behave consistently, which is also what makes keyframe reversal's own correctness legible — a tester comparing a reversed property motion against a reversed keyframe motion should see the same mirroring rule apply to both, not one mirrored and one not.

#### Done when
- [ ] Reversing a property motion authored with a named easing (e.g. ease-in) plays back with the mirrored shape (ease-out), the same rule `AnimaEase.mirrored()` already applies to keyframe reversal
- [ ] Reversing a property motion authored with an easing that has no mirror (linear, an ease-in-out variant, or a parameterised kind like spring) is unaffected — same shape either direction, no change from today
- [ ] Test: GUT coverage comparing a property motion's actual reversed curve against its expected mirrored shape, not just its start/end values

#### Not this story
- Any change to `AnimaEase.mirrored()` itself, or to keyframe reversal — both already exist by the time this story runs
- Any change to how `from_value`/`to_value` swap on reversal — only the easing changes

#### Notes
Depends on story 4 (`AnimaEase.mirrored()` must exist first). This is a small, isolated fix: one line in `AnimaPropertyMotionInstance.build_reversed()` swaps `reversed.ease = property_motion.ease` for `reversed.ease = property_motion.ease.mirrored()`.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_property_motion_instance.gd` (`build_reversed()`)
- **Contract:** `tech-spec.md` §Keyframe motions — "Easing mirroring" paragraph for `AnimaEase.mirrored()`'s exact behaviour
- **Rules:** Testing — same section as story 1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
