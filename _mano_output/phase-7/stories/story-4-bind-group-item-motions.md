### STORY-4: Bind group item motions

#### What and why
Group-motion authors can write one item motion that adapts to each resolved member of a collection. This makes the convenience layer useful for a row, column, or grid without binding it to one fixed node.

#### Done when
- [ ] An author can use `Anima.item()` as a group’s shared item motion and each resolved target visibly receives its own motion.
- [ ] Replaying the same group applies the item motion to the current resolved targets rather than to a previously fixed node.
- [ ] A saved group item motion remains reusable across different target collections.
- [ ] Test: a group run through the public playback surface animates multiple targets independently and reverses them back through the recorded run.
- [ ] Added public group-item API has editor-visible documentation.

#### Not this story
- Callable destinations based on group-item context.
- Grid-specific order and formula behaviour.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_property_motion.gd`; `addons/anima/motion/runtime/anima.gd`; `tests/Anima.integration.group-item-motion.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract`; `§Data model`
- **Rules:** `_mano_output/project-rules.md §Architecture`; `§Derived Scheduling`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
