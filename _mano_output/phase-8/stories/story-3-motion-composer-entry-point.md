### STORY-3: Add a Motion Composer entry point for ordinary nodes

#### What and why
A developer who selects a node carrying an Anima motion — without first hunting for and expanding the motion resource field in the Inspector — can open it in the Motion Composer directly, and any panel state that currently has nothing to show tells them what to do next instead of leaving them stuck.

#### Done when
- [ ] Selecting a node whose script exports an `AnimaMotion` (or subtype) field shows an "Anima" Inspector section with an Open Motion Composer action for that field.
- [ ] Choosing Open Motion Composer opens that field's assigned motion in the panel, the same as opening it from the resource field already does.
- [ ] A node with a motion field currently set to nothing shows a message explaining that a motion needs to be assigned before it can be opened, instead of a disabled or missing button.
- [ ] A node with more than one motion field lists each field by name with its own Open action.
- [ ] A node with no motion fields shows no "Anima" section, unchanged from today.
- [ ] The Motion Composer's own empty state (nothing open yet), and the Group Setup view's "no group selected" state, each name a concrete next step reachable from that state instead of a dead-end message.
- [ ] Test: selecting a node with an assigned motion field and choosing Open Motion Composer results in that same motion open in the panel.

#### Not this story
- The fuller per-node Anima Inspector section (Enable Anima toggle, Lifecycle/Defaults/Layout/States/Shared Element/Accessibility groups) — only the entry point and next-step messaging ship this story.
- Any other Motion Composer usability change beyond the entry point and the two named empty states.
- The easing curve library and motion pivot control — separate stories.

#### Implementation Reference
- **Files:** `addons/anima/anima_plugin.gd` (`AnimaMotionInspectorPlugin._can_handle()` / `_parse_begin()`); `addons/anima/editor/anima_motion_composer.gd` (empty-state message); `addons/anima/editor/anima_group_composer.gd` (no-group-selected message); `tests/AnimaMotionInspectorPlugin.test.gd` (new); `tests/Anima.integration.motion-composer-shell.test.gd`; `tests/Anima.integration.group-composer.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Motion Composer entry point` — the `PROPERTY_HINT_RESOURCE_TYPE` detection mechanism, the per-field entry behaviour, and the next-step-message contract
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries` (every empty/dead-end panel state names a reachable next action); `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
