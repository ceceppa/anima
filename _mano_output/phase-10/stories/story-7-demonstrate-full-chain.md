### STORY-7: Demonstrate the full convenience chain end-to-end

#### What and why
Anyone opening the Convenience Motion Example Scene can see every capability this phase adds — lifecycle callbacks, repeat, and playback direction — working together on one motion, the same way the existing playground already demonstrates the base convenience API.

#### Done when
- [ ] The Convenience Motion Example Scene's selector includes an entry that chains `.move_by()`, `.on_started()`, `.on_completed()`, and `.repeat()` together on the same motion.
- [ ] Selecting that entry shows the callbacks firing, using the scene's existing read-only example-line pattern, each time the motion starts and each time it completes.
- [ ] The scene's existing restart/reverse controls work on that same entry, including starting it already reversed.
- [ ] Test: an integration test exercises this exact chained call end-to-end — lifecycle callbacks, repeat, and playback-direction control together, with reverse producing the correct end state.

#### Not this story
- New shared playground components — reuse `ExampleHeader`, `Card`, `SelectorDock`, `SelectorButton`, and the existing playback controls only.
- Any convenience-motion family not already in the existing selector, beyond the one new chained entry this story adds.

#### Notes
Depends on: stories 1 through 6. Owns the phase's end-to-end verification — this chained call is the concrete form of the Phase Goal's "lifecycle callbacks, repeat, and playback-direction control" together with working reverse.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.tscn`; `examples/playground/convenience_motion_playground.gd`; `tests/Anima.integration.convenience-playground.test.gd`
- **Contract:** `_mano_output/tech-spec.md` (this phase's additions — `§Target-bound authoring contract`, `§Convenience method interface`); `_mano_output/ux-flow.md §Convenience Motion Example Scene`; `_mano_output/design-brief.md §Component guide`
- **Rules:** `_mano_output/project-rules.md §Example Scenes`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
