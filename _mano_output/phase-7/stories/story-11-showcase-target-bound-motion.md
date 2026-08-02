### STORY-11: Showcase target-bound motion

#### What and why
Developers evaluating the new convenience layer can run one focused playground and connect its short authored example to a visible Card motion. The example makes normal replay and reverse behaviour tangible without becoming a code editor.

#### Done when
- [ ] Running the convenience playground shows the shared header, one Card, a readable selected `Anima.on()` example, a motion-family selector, and restart/reverse controls.
- [ ] Choosing a motion family changes the shown example and replays the matching Card motion.
- [ ] Restart and reverse demonstrate the selected motion’s normal recorded playback behaviour.
- [ ] The scene uses the shared Theme, shared Card, shared selector components, shared header, and `ExamplePlayground` root.
- [ ] Test: selecting each showcased family produces a visible Card run and replay controls return it through the selected run.

#### Not this story
- Grid controls or Grid formula selection.
- New shared visual components.

#### Implementation Reference
- **Files:** `examples/convenience_motion_playground.tscn`; `examples/convenience_motion_playground.gd`; `tests/Anima.integration.convenience-playground.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Key technical decisions` — `AnimaPlayback.reverse()` now covers a leaf/composite target-bound motion, not just groups
- **UX:** `_mano_output/ux-flow.md §Convenience Motion Example Scene`
- **Design:** `_mano_output/design-brief.md §Component guide`; `§Screen composition — Composition Example Scene`
- **Rules:** `_mano_output/project-rules.md §Example Scenes`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
