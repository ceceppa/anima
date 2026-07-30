### STORY-9a: ExampleHeader content via editor exports

#### What and why
Whoever opens `composition_playground.tscn` to author or tweak the header now sees its title, subtitle, and icon set directly on the Header node in the editor Inspector, instead of those values being hidden inside `composition_playground.gd`'s code.

#### Done when
- [ ] `ExampleHeader` exposes its title, subtitle, and icon as properties editable in the Inspector, with no code required to set them
- [ ] Opening `composition_playground.tscn` in the editor shows "Composition", "Combine simple animations into expressive flows.", and "✦" set directly on the Header node's Inspector — not inside `composition_playground.gd`
- [ ] The running composition example scene still shows the exact same header content as before this story — no visible change to the demo
- [ ] Test: setting `ExampleHeader`'s exported title/subtitle/icon properties updates the rendered label/icon text

#### Not this story
- Changing `StateCard`, `SelectorDock`, or `SelectorButton`'s runtime-driven setters (`set_progress`, `select`, `set_selected`) — those stay code-driven per `project-rules.md` §Example Scenes, since their values don't exist until the scene runs.
- Any other example scene — only `composition_playground.tscn` and `ExampleHeader` exist today.

#### Notes
Follow-up from `project-rules.md`'s new "Editor-Authored Content" rule (§Example Scenes), captured via `mano rules` after Phase 4's stories were already done. Attached as `9a` since story-9 was the last completed story in Phase 4.

#### Implementation Reference
- **Contract:** `project-rules.md` §Example Scenes — "Editor-Authored Content" rule; the `ExampleHeader` pattern shown there (`@export var title/subtitle/icon`)
- **Files:** `examples/shared/components/example_header.gd` (convert `set_title`/`set_subtitle`/`set_icon` methods to `@export` properties with setters); `examples/composition_playground.tscn` (set `title`/`subtitle`/`icon` directly on the Header instance node); `examples/composition_playground.gd` (remove the now-redundant `_header.set_title(...)`/`set_subtitle(...)`/`set_icon(...)` calls in `_ready()`)
- **Test file:** `tests/ExampleHeader.test.gd` (update existing tests to set the exported properties directly rather than calling setter methods)
- **Do not:** no change to the header's actual displayed content (title text, subtitle text, icon glyph) — this is a mechanism change only

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
