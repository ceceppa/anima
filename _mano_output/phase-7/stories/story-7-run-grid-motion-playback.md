### STORY-7: Run grid motion playback

#### What and why
Grid-motion authors can play, reverse, validate, and compile a static grid motion with confidence that it follows the same lifecycle as other groups. A saved execution can be replayed without a reshuffled result.

#### Done when
- [ ] A valid Grid motion plays its selected shared item motion across the resolved tiles using the derived schedule.
- [ ] Reversing a completed or active Grid run returns tiles through the execution that was actually played.
- [ ] A static deterministic Grid motion can compile to a native Animation, while ineligible input shows a plain-language reason.
- [ ] Validation, preview, compilation, and reverse use one observable tile schedule for the same run.
- [ ] Test: a public Grid playback run, reverse run, and eligible compile path complete with matching tile outcomes.

#### Not this story
- Grid playground controls.
- New runtime playback subsystems outside Grid motion.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_group_playback.gd`; `tests/Anima.integration.grid-motion.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Grid motion contract`; `§Key technical decisions`; `§Product principle constraints`
- **Rules:** `_mano_output/project-rules.md §Architecture`; `§Derived Scheduling`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
