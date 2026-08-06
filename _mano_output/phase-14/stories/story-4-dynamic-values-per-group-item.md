### STORY-4: Dynamic values resolve independently per group and grid item

#### What and why
A developer animating a group or grid of nodes with one shared motion template can use a dynamic value inside that template and have every item resolve it against its own target — its own size, its own position in the grid — instead of every item collapsing onto whichever target happened to resolve first. This is the other half of what the RPG showcase needs: the same pulse motion, applied to many icons, each keeping its own real scale.

#### Done when
- [ ] The same dynamic-value motion applied across a group's items resolves each item's value against that item's own target, never a value shared or copied from another item.
- [ ] Inside a grid motion, a dynamic value reading the item's row or column reflects that specific item's actual position in the grid, not a fixed or default coordinate.
- [ ] Inside a group, a dynamic value reading the item's index or the group's total count reflects that item's actual position among the group, not a fixed or default number.
- [ ] Inside a group, a dynamic value reading from "root" resolves against the group's own container, never an individual item — distinct from reading the item's own target.
- [ ] A property motion whose value is a dynamic value is never offered for native-Animation compilation, reported the same way any other value that can't be baked ahead of time already is.
  - [ ] Test: a grid of 9 items using row/column dynamic values produces 9 distinct resolved values, one per cell, not 9 copies of the same value.
- [ ] The generated API reference documents that a value's group/grid-position sources only resolve inside a group or grid item, and states what they resolve to outside one.

#### Not this story
- Building the group or grid motion itself — this story assumes the existing group/grid machinery.
- The `Anima.grid()` shorthand — story-5.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_motion.gd` (`create_runtime(context: AnimaValueContext = null)` signature extension — a backward-compatible default, existing callers unaffected); the group playback's per-item start logic under `addons/anima/motion/runtime/` (build and pass each item's own context); `addons/anima/editor/anima_group_compiler.gd` (new `Blocker.DYNAMIC_VALUE`, checked after the existing `ITEM_MOTION_NOT_A_PROPERTY_MOTION` gate)
- **Contract:** `tech-spec.md` §Dynamic values ("AnimaValueContext and how it reaches an instance", "Compile-eligibility interaction") — context sourced from the group's own `AnimaExecutionRecord` (no duplicate per-item tracking), `group_normalised_index = group_index / max(group_count - 1, 1)`, `root` = the group's own container
- **Rules:** `project-rules.md` §Architecture ("Resources hold authored config only... resolved targets, ordering, ranks... belong to a playback or execution record") — the per-item context is built from the existing execution record, not a new duplicated per-item store
- **Tests:** `tests/AnimaGroupPlayback.test.gd` (extend — per-item context construction); `tests/AnimaGroupCompiler.test.gd` (extend — `DYNAMIC_VALUE` blocker); `tests/Anima.integration.dynamic-values.test.gd` (extend — a grid motion whose item motion uses row/column/root dynamic values)
- **Do not:** change compile-eligibility for a motion that has no dynamic value — add only the one new blocker check

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
