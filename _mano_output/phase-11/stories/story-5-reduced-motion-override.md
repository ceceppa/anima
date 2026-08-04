### STORY-5: Reduced-motion speed override

#### What and why
A player who has reduced-motion needs currently has no way for Anima to respect that preference at all — every motion plays at its full, authored pace regardless. This story gives a developer one project-wide switch and, per motion, an optional calmer pace it should use instead, so an app can offer a meaningfully gentler experience without redesigning every animation.

#### Done when
- [ ] With the global reduced-motion switch off, a motion with a reduced-motion speed set still plays at its normal effective speed — no change from today
- [ ] With the global reduced-motion switch on, a motion that has a reduced-motion speed set plays at that speed instead of its normal effective speed
- [ ] With the global reduced-motion switch on, a motion that has no reduced-motion speed set is unaffected and plays at its normal effective speed
- [ ] Test: a GUT unit test toggles the global switch and asserts the speed a motion plays at, with and without a reduced-motion speed set
- [ ] Test: the new `Anima.reduced_motion` field and `AnimaMotion.reduced_motion_speed` field each have an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for them

#### Not this story
- The full per-motion reduced-motion policy (FULL/SHORTEN/SIMPLIFY/COMPLETE_IMMEDIATELY) and the tri-state `AnimaSettings.reduced_motion` (System/Enabled/Disabled) — this phase ships only the minimal on/off flag
- Any playground UI toggle for this switch — blocked on an unresolved design-brief conflict, see the execution log

#### Notes
`Anima.reduced_motion` is a deliberately temporary field name and location (see `tech-spec.md` ⚠️ Note) — expect it to move under a future `AnimaSettings` class when the fuller reduced-motion item ships; this story does not need to anticipate that migration.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima.gd` (`static var reduced_motion: bool`); `addons/anima/motion/resources/anima_motion.gd` (`reduced_motion_speed` field)
- **Contract:** `tech-spec.md` §Speed, direction, and reduced motion — "Reduced-motion override" paragraph and its ⚠️ Note
- **Rules:** Testing, Documentation — same `project-rules.md` sections as story-1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
