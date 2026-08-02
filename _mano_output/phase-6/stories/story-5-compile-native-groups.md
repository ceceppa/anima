### [STORY-5]: Compile native groups

#### What and why
Animation authors can validate a group for native Animation output and compile it when every target and order is known. Unsupported live or non-deterministic input explains why it cannot be compiled.

#### Done when
- [ ] An eligible static group compiles into a native Animation whose visible item starts match the authored playback and ordering.
- [ ] A group using runtime-only targets, live membership, callbacks, unresolved references, or non-deterministic ordering remains uncompiled and names the blocking reason.
- [ ] Revalidating after an author changes the group updates its compile eligibility.
- [ ] Browsing `AnimaGroupCompiler` in Godot explains eligibility and blocker messages in plain language.
- [ ] Test: an eligible static collection produces a native Animation, while each blocked source shows a distinct reason.

#### Not this story
- Composer controls for viewing validation results.
- Native-code acceleration.

#### Implementation Reference
- **Files:** `addons/anima/editor/anima_group_compiler.gd`
- **Docs:** source `##` comments generate the online `AnimaGroupCompiler` reference through `npm run docs:api`; do not hand-edit generated pages.
- **Tests:** `tests/AnimaGroupCompiler.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Editor Boundaries`, `§Derived Scheduling`, `§Testing`, and `§Documentation`; consume the execution record and document public declarations in plain language for newcomers.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
