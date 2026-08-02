### STORY-0: Establish playground foundation

#### What and why
Example authors can open any new playground at a readable scale on HiDPI displays. The shared root keeps that experience consistent without copying display setup into each demo.

#### Done when
- [ ] A new runnable playground using the shared root opens with its content scaled for the operating-system display scale.
- [ ] A minimal playground test scene can launch through the shared root without scene-specific display setup.

#### Not this story
- Retrofitting existing playgrounds to the shared root.
- Building either Phase 7 showcase.

#### Implementation Reference
- **Files:** `examples/shared/components/example_playground.gd`; test in `tests/ExamplePlayground.test.gd`
- **Rules:** `_mano_output/project-rules.md §Example Scenes` — shared root and HiDPI requirement
- **Do not:** no local HiDPI helper in a playground script

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
