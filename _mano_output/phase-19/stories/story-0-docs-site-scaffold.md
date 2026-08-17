### story-0: Documentation site scaffold

#### What and why
Before any Feature, Guide, or Tutorial page can be written, the documentation site needs the two new top-level sections (`Features`, `Tutorials`) and the existing `Guides` section needs its stated scope widened to also cover runtime concepts, not just editor tooling. This story lays that structure down so every later story in this phase drops content into an already-navigable place.

#### Done when
- [ ] The documentation site's left navigation shows four top-level sections in order: Tutorials, Features, Anima Addon, Guides.
- [ ] Opening the Features section shows its own landing text (no pages yet).
- [ ] Opening the Tutorials section shows its own landing text (no pages yet).
- [ ] Opening the Guides section's landing text no longer says its scope is limited to editor tooling.

#### Not this story
- No actual Feature, Guide, or Tutorial content page — those are later stories in this phase.
- No change to the existing `motion-composer` guide or its images.

#### Implementation Reference
- **Build:** `docs/content/docs/features/_index.md` and `docs/content/docs/tutorials/_index.md` — new, `weight`/`title`/`description`/`icon`/`draft: false` front matter matching `docs/content/docs/anima/_index.md`'s existing shape — `tech-spec.md` §Documentation site structure (phase-19) owns the exact weight values (Tutorials 100, Features 200, Anima Addon 300 unchanged, Guides 400 unchanged) and section list.
- **Files:** `docs/content/docs/guides/_index.md` — edit its `description` and body so the section covers runtime-concept guides as well as editor-tool guides; exact wording is this story's own call, not specified elsewhere. `docs/content/docs/guides/motion-composer/` is untouched.
- **Rules:** section/page placement and front-matter convention — `project-rules.md` §Documentation ("A hand-written page about a *runtime* concept...").
- **Do not:** no Feature/Guide/Tutorial content pages yet; don't touch `docs/content/docs/anima/` (generated reference, untouched by this phase).

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
