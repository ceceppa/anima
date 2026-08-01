### [STORY-9]: Showcase group motion

#### What and why
People evaluating Anima can run one focused Group Motion example and compare playback and ordering choices on decorative artwork cards. The example makes the group feature tangible without presenting rank, timeline, speed, or reduced-motion controls.

#### Done when
- [ ] Opening `examples/group_motion_playground.tscn` presents a Group Motion header, playback selector, ordering selector, and restart/reverse controls.
- [ ] The showcase arranges StateCards as one row or one column, never a grid, and each card uses a distinct Region from the shared artwork atlas.
- [ ] Choosing playback or ordering restarts the visible collection with the selected combination; restart plays forward and reverse replays that collection backward.
- [ ] The visible selector choices demonstrate sequential, parallel, staggered, directional, centred, index-origin, odd, even, and seeded-random group behavior.
- [ ] Test: the example scene opens and a selector choice starts a group playback through the public Anima entry point.

#### Not this story
- A grid layout, rank labels, timeline, speed selection, or reduced-motion control.
- New shared visual components or letter-label fallback artwork.

#### Implementation Reference
- **Files:** `examples/group_motion_playground.tscn`; `examples/group_motion_playground.gd`
- **Components:** reuse `examples/shared/components/example_header.tscn`, `state_card.tscn`, `selector_dock.tscn`, `selector_button.tscn`, and `playback_controls.tscn`
- **Tests:** `tests/Anima.integration.group-motion-playground.test.gd`
- **UX:** `_mano_output/ux-flow.md §Group Motion Example Scene`
- **Design:** `_mano_output/design-brief.md §Visual direction`, `§Typography and layout`, and `§Component guide`
- **Rules:** `_mano_output/project-rules.md §Example Scenes`; use the shared Theme and `StateCard` atlas Region contract, shared selectors, shared header, and editor-authored static content.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
