### [STORY-0]: Group resources

#### What and why
Animation authors can define one reusable group motion with an item motion, playback settings, and group policies. This makes code, the Inspector, and the Composer start from the same authored resource.

#### Done when
- [ ] An author can save a Group Motion with its shared item motion and group configuration, reopen it, and see the same choices.
- [ ] A Group Motion reports missing item motion and incompatible settings before playback starts.
- [ ] The API reference pages for `AnimaGroupMotion` and `AnimaGroupDistribution` describe their purpose, editable choices, and a minimal runnable example.
- [ ] Test: a saved group with one item motion can be loaded and validated without changing its authored settings.

#### Not this story
- Resolving target collections or starting item playback.
- A compatibility enum or dictionary migration surface.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_group_motion.gd`; `addons/anima/motion/resources/anima_group_distribution.gd`
- **Docs:** `docs/content/docs/anima/anima-group-motion.md`; `docs/content/docs/anima/anima-group-distribution.md`
- **Tests:** `tests/AnimaGroupMotion.test.gd`; `tests/AnimaGroupDistribution.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model` and `§Group animation semantics`
- **Rules:** `_mano_output/project-rules.md §Folder Structure`, `§Naming`, `§Patterns`, `§Documentation`, and `§Testing`; add `##` comments for every public declaration.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
