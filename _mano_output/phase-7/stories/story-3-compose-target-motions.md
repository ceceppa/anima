### STORY-3: Compose target motions

#### What and why
Motion authors can combine target-bound motions into intentional sequences and parallel moments without hidden multi-property behaviour. The same authored motion responds to normal control and lifecycle operations.

#### Done when
- [ ] Authors can place target-bound motions in sequence and parallel relationships through the established composition surface.
- [ ] A second property change is never implied merely by chaining another convenience call; an author can observe the explicit relationship they chose.
- [ ] Delay, duration, easing, repetition, reversal, and interruption choices visibly affect convenience-created playback in the same way as canonical playback.
- [ ] Reversing a motion without an explicit start value returns the target to the value observed when that run began.
- [ ] Test: sequence, parallel, interruption, and reverse runs through the public surface match equivalent canonical motions.
- [ ] Added public modifier and composition APIs have editor-visible documentation.

#### Not this story
- Per-group-item authoring.
- Grid scheduling.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_motion_builder.gd`; `addons/anima/motion/runtime/anima.gd`; `tests/Anima.integration.convenience-composition.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract`; `§Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Architecture`; `§Testing`; `§Documentation`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
