### [STORY-1]: Resolve target collections

#### What and why
Animation authors can point a group at supported collections and see the nodes it will animate. Filtering happens before scheduling, so a group always acts on the intended subset.

#### Done when
- [ ] A group can resolve children, explicit nodes, scene-group members, descendants, and runtime-supplied targets into one collection for a play.
- [ ] Choosing odd or even filtering leaves only the matching zero-based positions in the resolved collection.
- [ ] A group with duplicate, empty, or departed targets follows its configured policy and exposes a clear validation message when it cannot play.
- [ ] Browsing `AnimaTargetCollection` in Godot explains its target sources and filtering choices in plain language.
- [ ] Test: the same fixed collection resolves in its visible collection order, and odd and even filters select disjoint items.

#### Not this story
- Ordering, start timing, or visual playback.
- Per-target item-motion mapping.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_target_collection.gd`; `addons/anima/motion/runtime/anima_target_resolver.gd`
- **Docs:** source `##` comments generate the online `AnimaTargetCollection` reference through `npm run docs:api`; do not hand-edit generated pages.
- **Tests:** `tests/AnimaTargetCollection.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model` and `§Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Folder Structure`, `§Naming`, `§Derived Scheduling`, `§Documentation`, and `§Testing`; document every public declaration in plain language for newcomers.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
