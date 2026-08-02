### [STORY-6]: Author groups in Composer

#### What and why
Motion Composer authors can add or select a Group Motion in the established workspace and configure it in one focused setup surface. They can preview the same resource that code authors use without leaving that editing context.

#### Done when
- [ ] From a compatible parent in the Composer workspace, an author can add a Group Motion and select it; opening a standalone Group Motion also shows that same setup surface.
- [ ] An author can choose the group’s collection, item motion, playback, distribution, ordering, filters, and policies.
- [ ] Selecting an option shows only its applicable settings and leaves unrelated settings out of the editing surface.
- [ ] Editing the Composer configuration updates the Group Motion opened by code, and editor undo or redo restores the visible authored choice.
- [ ] With a valid scene-node context, an author can preview forward, stop, or reverse the current configuration, then continue editing it.
- [ ] With no usable scene-node context, preview remains unavailable with the workspace’s plain-language explanation.
- [ ] Browsing `AnimaGroupComposer` in Godot explains how it edits a Group Motion in plain language.
- [ ] `npm run docs:api` generates the matching online reference from the Group Composer source comments.
- [ ] Test: a group created and edited in the Composer plays through the public Anima entry point with the choices shown in setup.

#### Not this story
- Per-target timing details, validation, or compilation result presentation.
- A timeline, rank display, reduced-motion control, or speed control.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_group_composer.gd`; update `addons/anima/editor/anima_motion_composer.gd`
- **Docs:** source `##` comments generate the online `AnimaGroupComposer` reference through `npm run docs:api`; do not hand-edit generated pages.
- **Tests:** `tests/Anima.integration.group-composer.test.gd`
- **UX:** `_mano_output/ux-flow.md §Motion Composer — Group Setup`
- **Contract:** `_mano_output/tech-spec.md §Motion Composer shell` and `§Product principle constraints`
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries`, `§Derived Scheduling`, `§Testing`, and `§Documentation`; Composer reads and edits public resources only and documents public declarations in plain language for newcomers.

#### Notes
Depends on: story-5a. Story 7 adds the inspection and compilation view for this same selected group.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
