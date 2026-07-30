### STORY-6: In-editor help across the full public API

#### What and why
Whoever hovers any public Anima class, function, property, or signal in the Godot script editor — whether it shipped in Phase 1 or this phase — sees a real description instead of "No description available."

#### Done when
- [ ] Hovering `Anima`, `AnimaMotion`, `AnimaSequence`, `AnimaParallel`, `AnimaStagger`, `AnimaRepeat`, `AnimaRace`, `AnimaConditional`, `AnimaPropertyMotion`, `AnimaEase`, `AnimaDuration`, `AnimaPlayback`, `AnimaRuntime`, `Motion`, `AnimaNodeProxy`, and `AnimaBehaviour` in the Godot script editor shows a real one-line description for each class itself, not "No description available"
- [ ] Hovering each of those classes' public functions and properties shows a real description for each one individually, not just the class-level description
- [ ] Test: scanning every `.gd` file under `addons/anima/motion/` confirms every public `class_name`, `func`, `var`, and `signal` declaration has a `##` doc comment immediately above it

#### Not this story
- Markdown documentation pages under `docs/content/docs/anima/` — a separate, already-established process (`project-rules.md` §Documentation).
- Any new public API surface — this story only documents what exists after stories 1–5 land.

#### Notes
Sequenced last so it also covers `AnimaEase`'s new kinds, `AnimaNodeProxy`, and `AnimaBehaviour` from stories 1–5 without needing a follow-up pass.

#### Implementation Reference
- **Contract:** `project-rules.md` §Documentation — the `##` doc-comment convention and `[ClassName]`/`[method Class.name]`/`[param name]` reference syntax
- **Files:** every `.gd` file under `addons/anima/motion/resources/` and `addons/anima/motion/runtime/`
- **Test file:** `tests/` — a new scan-based test (e.g. `tests/Documentation.public_api_has_doc_comments.test.gd`) that walks those two folders and asserts doc-comment coverage
- **Do not:** no changes to the markdown doc pages this story

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
