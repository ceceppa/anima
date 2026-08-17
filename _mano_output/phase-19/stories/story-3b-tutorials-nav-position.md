### story-3b: Move Tutorials to the bottom of the navigation

#### What and why
Tutorials currently sits first in the site's navigation. The site owner wants it last instead, after the reference sections, so the nav leads with Installation and the lookup-style sections before the step-by-step walkthroughs.

#### Done when
- [ ] The Tutorials section appears after every other top-level section in the site's navigation, instead of first.

#### Not this story
- No change to the order of pages within the Tutorials section itself (01 still before 02).
- No change to any other section's content.

#### Implementation Reference
- **Build:** `docs/content/docs/tutorials/_index.md` — change `weight` from `100` to `500`, placing it after Installation (100, story-3a), Features (200), Anima Addon (300), and Guides (400).
- **Do not:** don't renumber or reweight any other section's `_index.md`.

#### Notes
`tech-spec.md` §Documentation site structure (phase-19) currently documents Tutorials at weight 100 ("first... a newbie lands on Tutorials first") — now stale. Flagged for `mano spec` to update alongside story-3a's Installation addition; not edited here.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
