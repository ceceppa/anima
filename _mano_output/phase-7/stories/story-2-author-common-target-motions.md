### STORY-2: Author common target motions

#### What and why
Motion authors can describe the most common changes from a target node in a readable, discoverable form. Each choice has the same visible result as its canonical property-motion equivalent.

#### Done when
- [ ] Authors can create the supported position, relative movement, scale, rotation, opacity, colour, size, and generic-property motions through `Anima.on()`.
- [ ] Each supported motion visibly changes its target and can be played through the normal Anima playback surface.
- [ ] Supplying a starting value makes the motion begin from that value; omitting it begins from the value visible when the motion starts.
- [ ] Unsupported target or value combinations show an actionable validation message before playback.
- [ ] Test: every supported convenience motion produces the same visible property result as its canonical equivalent.
- [ ] Added public convenience APIs have editor-visible documentation.

#### Not this story
- Relationship composition between multiple motions.
- Reversal, interruption, or native compilation parity.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_property_motion.gd`; `addons/anima/motion/runtime/anima.gd`; `tests/Anima.integration.convenience-motions.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract`
- **Rules:** `_mano_output/project-rules.md §Folder Structure`; `§Naming`; `§Patterns`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
