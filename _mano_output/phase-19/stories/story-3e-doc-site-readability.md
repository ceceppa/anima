### story-3e: Restore default code colours, improve list spacing

#### What and why
Two readability rough edges on the documentation site: code blocks currently render in a "solarized-light" Prism theme instead of the LotusDocs theme's own default (a more legible blue-toned look the theme ships with), and bulleted/numbered lists in page content have no space between items, making multi-item lists feel cramped. This story fixes both.

#### Done when
- [ ] Code blocks across the documentation site render using the LotusDocs theme's own default colour scheme, not "solarized-light".
- [ ] A bulleted or numbered list with more than one item shows visible spacing between items, instead of items sitting flush against each other.

#### Not this story
- No other visual/typography change — font choices, heading sizes, spacing elsewhere are untouched.
- No change to the Godot addon's own example-scene design system (`_mano_output/design-brief.md`) — this is the separate Hugo documentation site.

#### Implementation Reference
- **Code colour:** `docs/hugo.toml`'s `[params.docs]` block currently sets `prismTheme = "solarized-light"`. The theme's own comment on that line names `"lotusdocs"` as its default option — change the value to `"lotusdocs"`.
- **List spacing:** the theme's own `docs/themes/lotusdocs/assets/docs/scss/custom/structure/_content.scss` sets `.docs-content .main-content ul, .docs-content .main-content ol { line-height: 26px; }` and has its own per-item `margin-bottom` commented out — this is a theme default, not a site override, so there's nothing to revert. Add a small site-owned stylesheet instead of copying/shadowing the theme's file (full-copy would drift from future theme updates): a new `docs/assets/docs/scss/site-overrides.scss` adding `margin-bottom` between `.docs-content .main-content ul > li` / `ol > li`.
- **Wiring:** `docs/themes/lotusdocs/layouts/partials/docs/head.html` compiles and links only the theme's own `docs.scss` bundle. Copy that file to `docs/layouts/partials/docs/head.html` (the site-level override path, same mechanism this project already uses for `docs/layouts/partials/head.html` and `docs/layouts/shortcodes/`) and add one additional block compiling and linking `site-overrides.scss` after the existing stylesheet link, so its rules win in cascade order. Do not restructure or duplicate any of the file's existing content beyond that one addition.
- **Do not:** don't copy or fork `_content.scss` itself; don't change any other theme partial or SCSS file.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
