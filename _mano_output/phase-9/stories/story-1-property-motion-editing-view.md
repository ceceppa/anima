### STORY-1: Reach Property Motion Editing directly

#### What and why
A developer who selects a Property Motion inside the Motion Composer's open graph — not a Group Motion — currently lands on the same "select a Group Motion" dead end Phase 8 already fixed at the top level. This story makes that selection open the Property Motion's own editing view directly, so switching between a Group Motion and a Property Motion in the graph behaves the same way for both.

#### Done when
- [ ] Selecting a Property Motion anywhere in the Composer's open graph shows that motion's own editing view (target property, easing, duration, delay) instead of the Group Setup dead-end message.
- [ ] Selecting a Group Motion still shows Group Setup, unchanged from today.
- [ ] Switching the graph selection between a Group Motion and a Property Motion updates the shown view immediately, with no intermediate blank state.
- [ ] Test: selecting a Property Motion opens its editing view showing that motion's own target property.
- [ ] Test: selecting a Group Motion after a Property Motion was selected switches back to Group Setup.

#### Not this story
- Empty/nothing-actionable state wording for any panel (story-2).
- The `examples/editor/` showcase scene (story-3).
- Any new easing, pivot, or duration capability — this story only makes the existing Property Motion editing surface reachable from graph selection.

#### Notes
Reuses the Composer's existing `SETUP` session view (`tech-spec.md §Motion Composer shell`) — this is not a new view state, just type-appropriate content within it.

`EditorInspectorPlugin`-derived panel classes can't be instantiated outside a real editor session (discovered in Phase 8) — extract the selection-to-view switch logic into a plain testable helper the same way `AnimaMotionFieldScanner` was extracted from `AnimaMotionInspectorPlugin`, rather than trying to unit-test the panel class directly.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_motion_composer.gd` (selection-to-view switch); `addons/anima/editor/anima_property_motion_composer.gd` (existing Property Motion editing surface — wire in, do not recreate)
- **Contract:** `AnimaComposerSession`'s active view stays `SETUP`/`INSPECTION` (`tech-spec.md §Data model`, `§Motion Composer shell`) — no new view state
- **Rules:** the selection-to-view switch is one shared, type-driven switch, never a separate per-type entry point (`project-rules.md §Editor Boundaries`)
- **Do not:** invent a new `AnimaComposerSession` active-view value for this

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
