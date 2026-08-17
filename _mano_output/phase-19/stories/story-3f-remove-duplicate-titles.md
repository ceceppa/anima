### story-3f: Remove the duplicated title on every page

#### What and why
Every Feature, Guide, Tutorial, and the Installation page shows its title twice — once as the page's own rendered heading (from its front matter), and again as a hand-written `# Title` line repeating the exact same text at the top of the body. This story removes the redundant one so each page shows its title once.

#### Done when
- [ ] None of the Features, Guides, Tutorials, or Installation pages show their title twice on the rendered page.
- [ ] Each affected page's content still reads naturally starting from its first heading below the (now single) title — no page starts mid-sentence or with a dangling heading level.

#### Not this story
- No change to any page's actual title text, front matter, or body content beyond removing the duplicated heading line.
- No change to the theme's own title rendering (`docs/themes/lotusdocs/layouts/docs/baseof.html`'s `<h1 class="content-title">{{ $currentPage.Title }}</h1>`) — that's the one rendering of the title that stays.

#### Implementation Reference
- **Cause:** `docs/themes/lotusdocs/layouts/docs/baseof.html` already renders `.Title` (from front matter) as the page's `<h1>` — every page in this phase additionally opened its body with a matching `# Title` Markdown heading, duplicating it.
- **Files — remove the leading `# Title` line (and the blank line after it) from each:** `docs/content/docs/features/built-in-animations.md`, `built-in-easings.md`; `docs/content/docs/guides/animating-relative-values.md`, `dynamic-values.md`, `keyframes.md`, `multiple-animations.md`, `reusable-vs-single-shot.md`, `motion-composer/index.md`; `docs/content/docs/tutorials/01-basic-animation/index.md`, `02-popup-animation/index.md`; `docs/content/docs/installation/_index.md`.
- **Do not:** don't touch `docs/content/docs/features/_index.md` or `docs/content/docs/guides/_index.md` — neither has a duplicated heading (section index pages don't repeat their title in the body). Don't touch any generated page under `docs/content/docs/anima/`.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
