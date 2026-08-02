### [STORY-7]: Inspect groups in Composer

#### What and why
Motion Composer authors can inspect the targets and generated per-target timing for the group they configured. They can validate, compile when eligible, and return to setup when a blocker needs fixing.

#### Done when
- [ ] Inspecting a group shows its resolved targets in collection order and each target’s generated start timing.
- [ ] An author can validate from inspection and sees current issues without leaving the surface.
- [ ] An eligible group offers compilation; a blocked group stays inspectable and shows the plain-language blocker.
- [ ] Browsing `AnimaGroupInspector` in Godot explains inspection, validation, and compilation status in plain language.
- [ ] `npm run docs:api` generates the matching online reference from the Group Inspector source comments.
- [ ] Test: the Composer inspection presents the same resolved collection and timing used by playback and compilation.

#### Not this story
- A timeline view or visible rank labels.
- New scheduling behavior.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_group_inspector.gd`
- **Docs:** source `##` comments generate the online `AnimaGroupInspector` reference through `npm run docs:api`; do not hand-edit generated pages.
- **Tests:** `tests/Anima.integration.group-inspection.test.gd`
- **UX:** `_mano_output/ux-flow.md §Motion Composer — Group Inspection`
- **Contract:** `_mano_output/tech-spec.md §Motion Composer shell` and `§Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries`, `§Derived Scheduling`, `§Testing`, and `§Documentation`; render read-only projections of one execution record and document public declarations in plain language for newcomers.

#### Notes
Depends on: story-6. Preview controls remain in Group Setup; inspection does not introduce a second preview state.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
