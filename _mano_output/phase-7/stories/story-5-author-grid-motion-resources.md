### STORY-5: Author grid motion resources

#### What and why
Grid-motion authors can describe a tiled collection, its start point, and its ordering as one reusable motion. Invalid grid settings explain what must change before an author tries to play the motion.

#### Done when
- [ ] An author can create a Grid motion that applies one shared item motion to a tiled target collection.
- [ ] A Grid motion defaults to Top ordering and accepts an authored start point that may be any valid tile.
- [ ] A partially filled final row plays without changing the declared grid dimensions.
- [ ] Invalid grid dimensions or an invalid start point are reported in validation before playback.
- [ ] Test: valid and invalid grid declarations expose the described playability outcome.
- [ ] Added public Grid motion API has editor-visible documentation.

#### Not this story
- Formula-specific propagation ranks.
- The runnable Grid playground.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_grid_motion.gd`; `tests/AnimaGridMotion.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model`; `§Grid motion contract`
- **Rules:** `_mano_output/project-rules.md §Folder Structure`; `§Naming`; `§Patterns`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
