### [STORY-6]: Author groups in Composer

#### What and why
Motion Composer authors can add or select a Group Motion and configure it in one focused setup surface. They can then inspect or preview the same resource that code authors use.

#### Done when
- [ ] In the Composer, an author can add or select a Group Motion and choose its collection, item motion, playback, distribution, ordering, filters, and policies.
- [ ] Selecting an option shows only its applicable settings and leaves unrelated settings out of the editing surface.
- [ ] Editing the Composer configuration updates the Group Motion opened by code without creating a second format.
- [ ] An author can open inspection or start a forward preview from Group Setup.
- [ ] The API reference page for `AnimaGroupComposer` explains how it edits a Group Motion.
- [ ] Test: a group edited in the Composer is accepted by the public playback entry point with the choices shown in setup.

#### Not this story
- Per-target timing details or compilation result presentation.
- A timeline, rank display, reduced-motion control, or speed control.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_group_composer.gd`
- **Docs:** `docs/content/docs/anima/anima-group-composer.md`
- **Tests:** `tests/Anima.integration.group-composer.test.gd`
- **UX:** `_mano_output/ux-flow.md §Motion Composer — Group Setup`
- **Contract:** `_mano_output/tech-spec.md §Product principle constraints`
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries`, `§Derived Scheduling`, `§Testing`, and `§Documentation`; Composer reads and edits public resources only and adds `##` comments for public declarations.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
