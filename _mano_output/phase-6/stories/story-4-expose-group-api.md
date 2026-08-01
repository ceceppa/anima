### [STORY-4]: Expose group API

#### What and why
Animation authors can construct and play a group from the same public Anima API used for other motions. The configured resource remains suitable for opening and editing in the Composer.

#### Done when
- [ ] An author can create a group with a collection, shared item motion, playback, distribution, ordering, filtering, and policies through the public code API.
- [ ] A group authored in code can be opened in the Motion Composer with the same selected configuration.
- [ ] The public API documentation includes one standalone group example that plays a collection.
- [ ] Test: a group built through the public API plays through `Anima.play(...)` and exposes the configured choices to the caller.

#### Not this story
- A visual-only Composer format.
- Compatibility names from Anima v1.

#### Implementation Reference
- **Files:** update `addons/anima/motion/resources/anima_motion_builder.gd`; update `addons/anima/motion/runtime/anima.gd`
- **Docs:** `docs/content/docs/anima/anima.md`
- **Tests:** `tests/Anima.integration.group-api.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Current Technical Summary`, `§Data model`, and `§Product principle constraints`
- **Rules:** `_mano_output/project-rules.md §Architecture`, `§Naming`, `§Testing`, and `§Documentation`; no autoload and update `##` comments for changed public declarations.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
