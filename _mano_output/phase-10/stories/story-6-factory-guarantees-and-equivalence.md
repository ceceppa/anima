### STORY-6: Harden factory guarantees and equivalence

#### What and why
Motion authors can reuse the same `Anima.on(target)` call to build several independent motions without one call's modifiers leaking into another, and can trust that every convenience method — including the ones added this phase — still produces exactly what the equivalent direct `Motion`/`AnimaRepeat` call would.

#### Done when
- [ ] Calling two different convenience methods from the same `Anima.on(target)` factory produces two independent motions; changing one does not change the other.
- [ ] Reusing the same factory reference to build a motion after an earlier motion from it has already been played, saved, or modified still produces a correct new motion, unaffected by the earlier one.
- [ ] Every convenience method added this phase (`on_started`/`on_completed`, `repeat`, `with_speed`, `property_by`, the backward-start entry point) produces a motion equivalent to building the same result directly through `Motion`/`AnimaRepeat`.
- [ ] Passing an unsupported value type to a convenience method reports a validation message naming the expected type, instead of failing silently or with an unrelated engine error.
- [ ] Test: an automated equivalence check covers every convenience method added this phase, following the existing parity-check pattern.

#### Not this story
- Adding new convenience methods beyond what this phase already scopes.
- The convenience creation-overhead performance budget — already covered by the existing benchmark; this story doesn't add a new one.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_on_motion_factory.gd`; `tests/AnimaOnMotionFactory.test.gd`; `tests/Anima.integration.convenience-parity.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract` (factory immutability); `§Convenience method interface`; `§Convenience performance budget`
- **Rules:** `_mano_output/project-rules.md §Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
