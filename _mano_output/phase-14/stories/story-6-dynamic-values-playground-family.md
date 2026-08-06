### STORY-6: Dynamic Values family in the convenience playground

#### What and why
A developer exploring Anima's convenience playground can select "Dynamic Values" from the existing family selector and watch a live example — the same way every other convenience-motion family already demonstrates itself — instead of only reading about dynamic values in documentation.

#### Done when
- [ ] Choosing "Dynamic Values" from the convenience playground's family selector plays a Card motion driven by a dynamic value read from the Card's own current state.
- [ ] The same selection also demonstrates a dynamic value used inside a keyframe step.
- [ ] The same selection also demonstrates two dynamic values combined arithmetically.
- [ ] A short read-only example line names the dynamic-value code being demonstrated, matching how every other convenience family already shows its own example line.
- [ ] Restarting or reversing the Dynamic Values example behaves the same as restarting or reversing any other convenience family's example.

#### Not this story
- The `Anima.grid()` shorthand or any change to the Grid Motion Example Scene — story-5.
- Any new shared UI component — this reuses the existing Family selector and example-line pattern as-is.

#### Notes
The phase brief describes this and the `Anima.grid()` demo as living in "the same playground." `ux-flow.md`'s existing scenes split by shape instead: the Convenience Motion Example Scene already demonstrates single-target families like this one, and the separate Grid Motion Example Scene already demonstrates collection motions and is where story-5 wires in the shorthand. Both are existing playground scenes, and each capability lands in the one whose established shape actually fits it — flagged in the execution log rather than forcing both into one scene.

Examples scripts are not scanned by the API-documentation generator (`tech-spec.md` §API documentation pipeline), so this story has no doc-reference AC.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.gd`, `examples/playground/convenience_motion_playground.tscn` (new `Family` entry + example line + Card wiring, following the existing family pattern Keyframes and Spring already used)
- **Contract:** `tech-spec.md` §Dynamic value interface for the exact API the example line demonstrates; `design-brief.md` §Component guide (`Card`, `SelectorDock`/`SelectorButton`) for the reused visual treatment — no new visual component
- **Tests:** `tests/Anima.integration.convenience-playground.test.gd` (extend — Dynamic Values family selection, example line, restart/reverse)
- **Do not:** add any new shared component; reuse the existing Family enum/selector mechanism exactly as Keyframes and Spring already did

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
