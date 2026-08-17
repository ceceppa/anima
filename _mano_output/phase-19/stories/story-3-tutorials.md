### story-3: Basic and Popup Animation tutorials

#### What and why
Guides and Features let a developer look things up, but a complete newcomer needs a step-by-step path that ends at a working result. This story adds two numbered tutorials — a first animation, then a sequential one building on it — so someone brand new to Anima has a concrete starting point, and closes out the phase by confirming the whole new documentation tree builds cleanly.

#### Done when
- [ ] The Tutorials section contains "01: Basic Animation", a numbered step-by-step walkthrough ending at a working animation, with at least one runnable `gdscript` code block.
- [ ] The Tutorials section contains "02: Popup Animation", ordered after "01", that:
  - States in its own text which result from "01" it continues from.
  - Builds on that result using sequential composition (`.then()`), reaching a distinct working end result of its own.
- [ ] Running the documentation site's existing build produces no broken links or missing pages across every page added in this phase (Features, Guides, Tutorials, and the widened Guides landing page).

#### Not this story
- No image assets in either tutorial this phase — plain leaf-bundle pages with no screenshots yet.
- No third tutorial or any tutorial beyond "02".

#### Implementation Reference
- **Build:** `docs/content/docs/tutorials/01-basic-animation/index.md` (`weight: 1`), `docs/content/docs/tutorials/02-popup-animation/index.md` (`weight: 2`) — Lotus Docs leaf-bundle form, matching `docs/content/docs/guides/motion-composer/index.md`'s front-matter shape minus images — `tech-spec.md` §Documentation site structure (phase-19).
- **Data — 01: Basic Animation:** a first `Anima.on(target)` call — `tech-spec.md` §Convenience method interface, and the existing worked example in `docs/content/docs/anima/_index.md`'s "Getting started" section (use as a starting point, not a copy-paste).
- **Data — 02: Popup Animation:** sequential composition via `.then()`, building on 01's target/result — `tech-spec.md` §Convenience method interface and §Key technical decisions.
- **Build:** run the existing documentation build command (`tech-spec.md` §API documentation pipeline, `npm run build`) after every page in this phase exists, to satisfy the no-broken-links AC.
- **Rules:** runnable-example and tutorial-continuity convention — `project-rules.md` §Documentation.
- **Do not:** don't introduce a mechanism not already defined in `tech-spec.md`; don't add a `Depends on` Hugo front-matter field — the continuation is stated in prose, not a site mechanism.

#### Notes
Depends on: story-0 (site scaffold must exist first). Runs independently of story-1/story-2 otherwise. This story's final AC is this phase's closing integration check — it's the only AC that exercises the whole new documentation tree at once (Exit Criterion 4, phase-19 brief).

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
