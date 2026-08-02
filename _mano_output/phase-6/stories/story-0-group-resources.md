### [STORY-0]: Group resources

#### What and why
Animation authors can define one reusable group motion with an item motion, playback settings, and group policies. They can also discover every existing public Anima API through beginner-friendly help in Godot, with the same reference generated for the Hugo site.

#### Done when
- [ ] An author can save a Group Motion with its shared item motion and group configuration, reopen it, and see the same choices.
- [ ] A Group Motion reports missing item motion and incompatible settings before playback starts.
- [ ] Browsing `AnimaGroupMotion` or `AnimaGroupDistribution` in Godot shows beginner-friendly class and member help that explains their purpose, choices, and a minimal runnable example.
- [ ] Every existing public Anima declaration and every new Group Motion declaration has beginner-friendly `##` help in Godot that explains its author-visible purpose and unfamiliar terms.
- [ ] `npm run docs:api` generates the matching Hugo reference from `##` comments and stops with an actionable failure when any public declaration has no documentation.
- [ ] Test: the permanent documentation-pipeline test generates a group-resource reference from documented source and detects an undocumented public declaration.
- [ ] Test: a saved group with one item motion can be loaded and validated without changing its authored settings.

#### Not this story
- Resolving target collections or starting item playback.
- A compatibility enum or dictionary migration surface.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_group_motion.gd`; `addons/anima/motion/resources/anima_group_distribution.gd`
- **Docs:** `scripts/generate-api-docs.js`; update `package.json` with `docs:api` and run it before `dev` and `build`; generated pages under `docs/content/docs/anima/` are not hand-edited.
- **Migration:** use the generator’s missing-documentation output to retrofit every pre-existing public declaration before the final documentation run.
- **Tests:** `tests/AnimaGroupMotion.test.gd`; `tests/AnimaGroupDistribution.test.gd`; `tests/DocumentationPipeline.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model`, `§Group animation semantics`, and `§API documentation pipeline`
- **Rules:** `_mano_output/project-rules.md §Folder Structure`, `§Naming`, `§Patterns`, `§Documentation`, and `§Testing`; document every public declaration in plain language for newcomers.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
