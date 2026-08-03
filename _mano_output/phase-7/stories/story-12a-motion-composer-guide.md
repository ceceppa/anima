### STORY-12a: Motion Composer guide

#### What and why
Anima authors who open the "Anima" bottom panel in the Godot editor for the first time have no explanation of what it does or how to drive it — Motion Composer, Group Composer, Property Motion Composer, and Group Inspector all shipped without a usage guide. A published guide lets an author open the panel, edit a group or a property motion, and read a compiled group's status without reverse-engineering the UI by trial and error.

#### Done when
- [ ] The guide exists at `docs/content/docs/anima/guides/motion-composer/index.md`, states what the Motion Composer panel is for, and explains how to open it (the "Anima" tab at the bottom of the Godot editor, populated once a scene node with an `AnimaMotion` resource is selected).
- [ ] The guide documents editing a group motion and editing a property motion inside the panel, including how the panel decides which one is shown.
- [ ] The guide documents the "Inspect Group" view reached from a group motion: resolved targets, generated timing, validation feedback, and compilation status, and how to return to editing.
- [ ] Every UI step in the guide that benefits from a screenshot has an `![alt](...)` image reference; each one not yet captured has an HTML comment directly beneath it stating exactly what to capture (panel name, editor state, what must be visible).

#### Not this story
- No changes to any `addons/anima/editor/*.gd` source — this story is documentation only.
- No redesign of the panel layout, generated timeline, or preview viewport.
- No guide for grid-motion-specific playground UI (`examples/grid_motion_playground.*`) — that is example/demo content, not an `addons/anima/editor/` script.
- Guides for any `addons/anima/editor/` script added after this story are covered by the standing rule, not a dedicated future story.

#### Notes
Six scripts back this one panel and are covered by this single guide rather than one guide each, since an author experiences them as one dock, not six separate tools: `anima_motion_composer.gd` (root panel, registered via `addons/anima/anima_plugin.gd`'s `add_control_to_bottom_panel`), `anima_composer_session.gd` (workspace/selection state — no UI of its own, fold into how the panel remembers what's open), `anima_group_composer.gd` and `anima_property_motion_composer.gd` (the two Setup-view editors the panel switches between), `anima_group_inspector.gd` (the Inspection view), and `anima_group_compiler.gd` (the compilation eligibility/status the Inspection view surfaces — its own doc comment notes it is editor/tooling code, not something runtime playback depends on).

This is a mid-build addition covering `project-rules.md §Documentation → "Editor Usage Guides"` retroactively for editor scripts from already-`done` stories (story-3, story-4, story-8); the rule was adopted after those shipped, so no guide exists yet for any of them.

#### Implementation Reference
- **Files:** `docs/content/docs/anima/guides/motion-composer/index.md`; any placeholder screenshots alongside it in the same folder (Hugo leaf-bundle style)
- **Rules:** `_mano_output/project-rules.md §Documentation` → "Editor Usage Guides" bullet — front matter, placeholder-image + capture-note convention, hand-written prose distinct from the generated API reference
- **Scope:** `addons/anima/editor/anima_motion_composer.gd`; `addons/anima/editor/anima_composer_session.gd`; `addons/anima/editor/anima_group_composer.gd`; `addons/anima/editor/anima_property_motion_composer.gd`; `addons/anima/editor/anima_group_inspector.gd`; `addons/anima/editor/anima_group_compiler.gd`
- **Do not:** duplicate the generated member-level explanation already published at `docs/content/docs/anima/anima-motion-composer.md` and its sibling generated pages — this guide is the workflow walkthrough, not a second API reference.

## Changes

- Guide location: moved from `docs/content/docs/anima/guides/motion-composer/` to `docs/content/docs/guides/motion-composer/`, with a new `docs/content/docs/guides/_index.md` section index giving it its own "Guides" menu entry, because the user wanted guides to live outside the `anima` API-reference section rather than nested inside it. `project-rules.md §Documentation → "Editor Usage Guides"` updated to the same path for future guides.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
