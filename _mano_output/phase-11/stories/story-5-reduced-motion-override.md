### STORY-5: Reduced-motion speed override

#### What and why
A player who has reduced-motion needs currently has no way for Anima to respect that preference at all — every motion plays at its full, authored pace regardless. This story gives a developer one project-wide switch and, per motion, an optional calmer pace it should use instead, so an app can offer a meaningfully gentler experience without redesigning every animation.

#### Done when
- [ ] With the global reduced-motion switch off, and no `AnimaBehaviour` attached to the target, a motion with a reduced-motion speed set still plays at its normal effective speed — no change from today
- [ ] With the global reduced-motion switch on, and no `AnimaBehaviour` attached to the target (or one left at its default), a motion that has a reduced-motion speed set plays at that speed instead of its normal effective speed
- [ ] With the global reduced-motion switch on, a motion that has no reduced-motion speed set is unaffected and plays at its normal effective speed
- [ ] A target whose attached `AnimaBehaviour` explicitly enables reduced motion gets the reduced-motion speed applied even while the global switch is off
- [ ] A target whose attached `AnimaBehaviour` explicitly disables reduced motion is unaffected even while the global switch is on
- [ ] With the global switch on, a group motion on a target with no `AnimaBehaviour` (or one left at its default) starts its items together instead of sequentially/staggered — the same collapse-to-parallel treatment an explicitly-enabled behaviour already gets today
- [ ] Test: a GUT unit test toggles the global switch and asserts the speed a motion plays at, across all three `AnimaBehaviour` states and with no behaviour attached
- [ ] Test: the new `Anima.reduced_motion` field and `AnimaMotion.reduced_motion_speed` field each have an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for them

#### Not this story
- The full per-motion reduced-motion policy (FULL/SHORTEN/SIMPLIFY/COMPLETE_IMMEDIATELY) — this phase ships only the minimal on/off speed override
- A new `AnimaSettings` class — the existing `AnimaBehaviour.ReducedMotion` tri-state is reused as-is, not replaced or wrapped in a new settings resource
- Any playground UI toggle for this switch — blocked on an unresolved design-brief conflict, see the execution log

#### Notes
`Anima.reduced_motion` is not a temporary placeholder superseded by a future class — it *is* the "system-preference adapter" `AnimaBehaviour.ReducedMotion.SYSTEM`'s own doc comment already named as missing. This story is also the one that closes that gap in `AnimaGroupPlayback._uses_reduced_motion()`, which today only checks for an explicit `ENABLED` behaviour.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima.gd` (`static var reduced_motion: bool`); `addons/anima/motion/resources/anima_motion.gd` (`reduced_motion_speed` field); `addons/anima/motion/runtime/anima_playback.gd` (`_advance()`'s three-way resolution before applying `reduced_motion_speed`); `addons/anima/motion/runtime/anima_group_playback.gd` (`_uses_reduced_motion()` extended to the same three-way resolution)
- **Contract:** `tech-spec.md` §Speed, direction, and reduced motion — "Reduced-motion override" paragraph, including the `AnimaBehaviour.ReducedMotion` resolution rules
- **Rules:** Testing, Documentation — same `project-rules.md` sections as story-1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
