### STORY-0: Motion resource bootstrap

#### What and why
A Godot developer integrating Anima gets a base motion type to build on: every future motion — Sequence, Parallel, Property motion, and beyond — extends this one Resource, so its shape has to be right and testable from the first commit. This story also lays down the folder structure the rest of Phase 1 depends on.

#### Done when
- [ ] Constructing the base motion resource with no arguments produces the documented default values.
- [ ] The addon loads in the Godot editor with the new motion module present and produces no script errors.
- [ ] Test: a unit test constructs the base motion resource and asserts its default field values.

#### Not this story
- No composite or leaf motion types yet (Sequence, Parallel, Property motion) — those are separate stories.
- No runtime execution — the base contract methods exist but are not exercised end-to-end until later stories.
- No easing (`AnimaEase`) — separate story.

#### Notes
Establishes the folder and naming layout every later story in this phase follows.

#### Implementation Reference
- **Build:** base motion Resource type; module scaffolding
- **Data:** field list and defaults — `tech-spec.md` §Data model (`AnimaMotion` row)
- **Files:** `project-rules.md` §Folder Structure (`addons/anima/motion/resources/`, `addons/anima/motion/runtime/`)
- **Rules:** `project-rules.md` §Naming — `Anima`-prefixed PascalCase `class_name`, matching snake_case filename
- **Rules:** `project-rules.md` §Architecture — do not add or edit anything under `project.godot`'s `[autoload]`; do not reference `addons/anima/core`, `addons/anima/utils`, or `addons/anima/animations`
- **Test:** `project-rules.md` §Testing — one `<ClassName>.test.gd` per class

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
