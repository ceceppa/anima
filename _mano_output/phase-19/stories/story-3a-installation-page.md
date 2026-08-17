### story-3a: Installation page and a working "Get Started" link

#### What and why
The site's "Get Started" button currently opens a 404 — it points at a page that was never created. A developer landing on the site has no installation instructions at all. This story adds a real Installation page and points the button at it, so "Get Started" actually starts someone.

#### Done when
- [ ] Clicking "Get Started" on the site's landing page opens a real page — not a 404.
- [ ] That page is a numbered, step-by-step walkthrough that ends with the addon installed and enabled in a Godot project.
- [ ] Any step whose result is clearer with a screenshot has a placeholder image and a note stating exactly what to capture, in place of a real screenshot.

#### Not this story
- No change to the landing page's other button ("Demo") or any other link.
- No actual screenshots captured — placeholders only; the user captures and replaces them separately.
- No change to Tutorials' position in the navigation — that's story-3b.

#### Implementation Reference
- **Build:** `docs/content/docs/installation/_index.md` — a branch bundle serving as both the section's nav entry and the walkthrough content itself (front matter `weight`/`title`/`description`/`icon`/`draft: false`, body prose directly in the file — the same shape `docs/content/docs/anima/_index.md` already uses for its own "Getting started" section), with screenshot images co-located in the same folder as page resources. `weight: 100` — first in the nav, ahead of every other section, since it's the literal landing target for "Get Started".
- **Files:** `docs/data/landing.toml`'s `[hero.ctaButton]` — change `url` from `/docs/overview/` (a page that was never created) to the new Installation page's path.
- **Screenshots:** placeholder convention — `![alt](placeholder.png)` plus an HTML comment directly below stating exactly what must be visible (panel name, editor state) — `project-rules.md` §Documentation ("If a step is clearer with a screenshot...").
- **Rules:** runnable-example convention does not apply here (an install walkthrough has no `gdscript` to run) — `project-rules.md` §Documentation's screenshot-placeholder pattern is the relevant one instead.
- **Do not:** don't touch `docs/content/docs/anima/`, `guides/`, `features/`, or `tutorials/`; don't capture real screenshots.

#### Notes
`tech-spec.md` §Documentation site structure (phase-19) doesn't yet name an Installation section or this weight ordering — it's now stale on this point. Flagged for `mano spec` to update; not edited here.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
