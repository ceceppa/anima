### STORY-8: Inspect convenience motions

#### What and why
Motion authors can open a convenience-created motion in the Composer and understand the real target and property behind its friendly name. Editing it changes the same motion that code and playback use.

#### Done when
- [ ] Opening a convenience-created motion in the Composer shows its semantic name, canonical property, target, values, timing, and easing.
- [ ] An author can edit the motion in the Composer and observe the changed resource when it is played again.
- [ ] A generic property motion offers an understandable property choice with the current value and validation feedback.
- [ ] Undo and redo return the authored motion between its before and after states without creating a separate visual copy.
- [ ] Test: a motion created through the convenience surface is edited in the Composer, then plays with the edited result.

#### Not this story
- A broader Composer layout, generated timeline, or preview-viewport redesign.
- Grid-specific Composer controls.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_motion_composer.gd`; `tests/Anima.integration.composer-convenience.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract`; `§Motion Composer shell`
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries`; `§Architecture`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
