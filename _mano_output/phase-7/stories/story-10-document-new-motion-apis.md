### STORY-10: Document new motion APIs

#### What and why
New Anima authors can discover target-bound and Grid motion in the Godot editor, then find the same guidance in the generated online reference. This keeps the new v2 surface learnable without an obsolete v1 migration layer.

#### Done when
- [ ] Hovering every new public target-bound and Grid API in Godot explains its visible outcome, inputs, defaults, and relevant playback behaviour in plain language.
- [ ] The generated online reference includes pages for the new public APIs with an overview and a minimal working example.
- [ ] The getting-started guide demonstrates a target-bound motion, an explicit composition, and the equivalent canonical motion.
- [ ] Generated documentation has no hand-edited duplicate prose for the new APIs.

#### Not this story
- V1 compatibility aliases or migration documentation.
- New documentation tooling or a separate documentation format.

#### Notes
Depends on: stories 1 through 8; public comments are added as each API lands, and this story completes the generated-reference and getting-started deliverable.

#### Implementation Reference
- **Files:** `scripts/generate-api-docs.js`; `docs/content/docs/anima/`
- **Contract:** `_mano_output/tech-spec.md §API documentation pipeline`
- **Rules:** `_mano_output/project-rules.md §Documentation`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
