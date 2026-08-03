### STORY-3: Editor tooling showcase scene

#### What and why
A developer today only has the written Motion Composer guide to learn the dock from — no runnable example to click through. This story adds a single `examples/editor/` scene with four pre-configured nodes, one per Motion Composer state, so a developer can open it in the Godot editor and see the entry point, Group Setup, Property Motion editing, and Group Inspection all working live.

#### Done when
- [ ] `examples/editor/motion_composer_showcase.tscn` exists with four nodes: one carrying an authored Group Motion, one carrying an authored Property Motion, one carrying a compiled/resolved group, and one with no motion assigned.
- [ ] Selecting the node with no motion assigned shows the top-level Motion Composer entry-point empty state.
- [ ] Selecting the node with an authored Group Motion opens Group Setup showing that motion's configuration.
- [ ] Selecting the node with an authored Property Motion opens the Property Motion editing view showing that motion's configuration.
- [ ] Selecting the node with a compiled/resolved group opens Group Inspection showing its resolved target list.

#### Not this story
- Any new Motion Composer behaviour beyond what story-1 and story-2 already ship — this story only demonstrates it.
- A written guide update — the existing `docs/content/docs/guides/motion-composer` guide is unchanged by this story.

#### Notes
Depends on: story-1, story-2 (the showcase demonstrates their behaviour; build it last). If building this scene surfaces a dead end beyond the two named in the phase brief's Acknowledged Risks, log it rather than silently expanding this story's scope.

#### Implementation Reference
- **Files:** `examples/editor/motion_composer_showcase.tscn`
- **Rules:** four-node single-scene structure (`project-rules.md §Example Scenes`); plain Godot nodes only, no shared theme or `examples/playground/shared/` component — opened, not run (`project-rules.md §Example Scenes`)
- **UX:** `ux-flow.md §Editor Tooling Showcase Scene`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
