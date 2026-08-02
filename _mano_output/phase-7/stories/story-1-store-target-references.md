### STORY-1: Store target references

#### What and why
Motion authors can save a target-bound motion without accidentally preserving a live scene object that will not exist when the motion is reopened. Immediate code playback remains straightforward while saved resources stay portable.

#### Done when
- [ ] A motion played directly against a scene node visibly animates that node.
- [ ] A saved target-bound motion can be reopened and resolve its authored target without retaining the old live node.
- [ ] Attempting to save a motion with an unsafe live target gives the author a clear resolution instead of silently storing it.
- [ ] Test: immediate playback and saved-resource targeting produce the expected target behaviour in separate scene instances.
- [ ] Added public target-reference API has editor-visible documentation.

#### Not this story
- Common convenience property methods.
- Group-item target binding.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_target_reference.gd`; `addons/anima/motion/runtime/anima.gd`; `tests/AnimaTargetReference.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Data model`; `§Target-bound authoring contract`
- **Rules:** `_mano_output/project-rules.md §Folder Structure`; `§Naming`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
