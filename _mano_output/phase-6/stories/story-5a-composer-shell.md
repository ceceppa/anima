### [STORY-5a]: Build Composer shell

#### What and why
Godot authors can open an authored motion in a real Motion Composer workspace instead of relying on an assumed editor panel. They can move through that motion’s resource graph and choose the scene node that gives a group its target and preview context.

#### Done when
- [ ] Selecting an authored motion in the Inspector and choosing Open in Motion Composer opens the Anima bottom panel with that motion as the current resource graph.
- [ ] Selecting a motion in the open graph changes the editing context without making a second copy of the resource.
- [ ] Selecting a scene node supplies the target and preview context for the selected group.
- [ ] Without a selected scene node, a group remains editable and the workspace explains that resolving and previewing need a scene-node context.
- [ ] Closing the panel or opening a different Inspector motion leaves the authored resource available to code and the Inspector with its saved choices intact.
- [ ] Browsing `AnimaComposerSession` and `AnimaMotionComposer` in Godot explains the workspace, graph selection, and scene-node context in plain language.
- [ ] `npm run docs:api` generates the matching online reference from those source comments.
- [ ] Test: opening a resource, changing the selected graph motion, and changing the selected scene node keeps one authored resource graph and exposes the chosen context to the workspace.

#### Not this story
- Creating or configuring a Group Motion.
- Group inspection, playback controls, validation, or compilation results.
- A separate visual-only motion format.

#### Implementation Reference
- **Files:** update `addons/anima/anima_plugin.gd`; `addons/anima/editor/anima_composer_session.gd`; `addons/anima/editor/anima_motion_composer.gd`
- **Docs:** source `##` comments generate the `AnimaComposerSession` and `AnimaMotionComposer` references through `npm run docs:api`; do not hand-edit generated pages.
- **Tests:** `tests/Anima.integration.motion-composer-shell.test.gd`
- **UX:** `_mano_output/ux-flow.md §Motion Composer — Workspace`
- **Contract:** `_mano_output/tech-spec.md §Motion Composer shell` and `§Data model`
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries`, `§Naming`, `§Testing`, and `§Documentation`; keep the panel outside runtime/resource layers, use public resources, and document every public declaration for newcomers.

#### Notes
Depends on: story-5. Story 6 adds Group Motion creation and setup to this reachable workspace.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
