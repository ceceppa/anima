### STORY-2: Editor panel empty states name a next action

#### What and why
Group Setup, Group Inspection, and the Property Motion editing view (story-1) can each be reached with nothing configured yet — no target collection assigned, no resolved targets, or the wrong motion type selected. Today some of those states show controls with nothing to act on instead of telling the developer what to do next, the same class of dead end Phase 8 fixed at the top level. This story gives every one of those states its own concrete next-step message.

#### Done when
- [ ] A Group Motion with no target collection or item motion assigned shows a message naming the next step (assign a target collection and an item motion) instead of empty Inspect/Preview controls.
- [ ] Group Inspection with an empty resolved-target list shows a message naming the next step (return to Group Setup and assign a target collection) instead of a blank list.
- [ ] The Property Motion editing view, when the current selection isn't a Property Motion, shows a message naming the next step (select a Property Motion elsewhere in the graph).
- [ ] Test: opening Group Setup on a Group Motion with no item motion shows the empty-state message, not the settings controls.
- [ ] Test: opening Group Inspection on a group with zero resolved targets shows the empty-state message, not an empty list.

#### Not this story
- The Property Motion editing view's reachability (story-1) — this story only adds its empty-state message once that view is reachable.
- The `examples/editor/` showcase scene (story-3).
- Any change to the top-level Motion Composer entry-point message Phase 8 already shipped.

#### Notes
Depends on: story-1 (the Property Motion editing view's own empty-state case needs that view reachable first). The Group Setup and Group Inspection empty-state cases do not depend on story-1 and may be built first if that's more convenient.

`EditorInspectorPlugin`-derived panel classes can't be instantiated outside a real editor session (discovered in Phase 8) — expose each new message through a small plain method, the same pattern `AnimaGroupComposer.status_message()` and `AnimaMotionComposer.workspace_status_message()` already use, so the wording and triggering condition stay unit-testable.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_group_composer.gd` (`status_message()` — extend for the no-item-motion case); `addons/anima/editor/anima_group_inspector.gd` (empty resolved-target-list message); `addons/anima/editor/anima_property_motion_composer.gd` (wrong-type-selected message)
- **Rules:** every panel's nothing-actionable state names the concrete next action (`project-rules.md §Editor Boundaries`); expose each message through a small plain method, not only inline inside `_refresh()` (`project-rules.md §Editor Boundaries`)
- **Do not:** rewrite the existing top-level Motion Composer or Group Setup "select a Group Motion" messages Phase 8 already shipped

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
