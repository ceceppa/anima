### story-1: Animation Catalog Playground scene

#### What and why
A developer wanting to see whether a ported preset actually looks right currently has to write a scratch scene and call `Anima.animation(name)` by hand. This story adds a playground scene — a category sidebar, a live preview stage, and a grid of preset buttons — so any of the 99 ported presets can be browsed and watched in seconds.

#### Done when
- [ ] Opening the playground scene shows: the category sidebar with all 5 categories listed, one selected by default (`attention`, the alphabetically-first category), and the stage already playing a preset from that category.
- [ ] Selecting a different category in the sidebar:
  - The grid below the stage updates to that category's preset names.
  - The first preset in the new category (alphabetically) starts playing in the stage immediately, with no extra click needed.
- [ ] Selecting a preset from the grid replays that exact preset in the stage from its start.
- [ ] The existing shared playback controls all visibly act on whichever preset is currently playing in the stage:
  - Restart replays it from the beginning.
  - Reverse plays it backward.
  - Complete jumps it to its end state.
  - Revert snaps it back to its starting state.
  - Changing speed changes how fast it plays.
  - Toggling reduced motion changes its playback accordingly.
- [ ] Every one of the 99 ported presets is reachable this way — selecting through every category's grid reaches all of them, with none missing from any category's list.

#### Not this story
- No search, tags, favourites, or "duplicate into project" — this is browse-and-preview only (the full Preset Browser is a separate, deferred backlog item).
- No hand-authored or example motions from other playgrounds shown here — only the 99 catalog presets.
- No dedicated launcher or menu entry — the scene is opened like any other `examples/playground/` scene, by name.
- No public `Anima.*` enumeration API — listing categories/presets is useful only to this scene, so it stays a scene-local helper, not an addon-wide addition (see Implementation Reference).

#### Implementation Reference
- **Build:** category sidebar is `SelectorDock`/`SelectorButton` with `%Items` as a `VBoxContainer` (a second `.tscn`, same `selector_dock.gd` script, no new script) — `project-rules.md` §Selector Orientation. Animation grid is the existing horizontal `SelectorDock` unchanged. Playback via `Anima.animation(name)` — `tech-spec.md` §Animation catalog.
- **Data source:** a scene-local helper (owned by this scene, not the addon) lists categories and preset names by scanning `res://addons/anima/presets/` directly on every call, no caching — exact scan targets and casing in `tech-spec.md` §Animation catalog ("Catalog enumeration is not part of Anima's public API"). This is not a public API; keep it private to the playground.
- **UI:** layout, palette tokens, and component treatment — `design-brief.md` §Component guide ("Category sidebar", "Animation grid") and §Screen composition — phase-18 — Animation Catalog Playground.
- **Flow:** exact interaction/selection behaviour, defaults, and availability — `ux-flow.md` §Animation Catalog Playground.
- **Files:** shared components under `examples/playground/shared/components/`; the playground scene itself under `examples/playground/` — `project-rules.md` §Example Scenes, §Folder Structure.
- **Rules:** a unit test for the scene-local enumeration helper (category list, per-category name list, unknown-category behaviour) — `project-rules.md` §Testing.
- **Do not:** no new playback control — the existing shared bar is reused exactly as every other playground uses it; no new `AnimaMotion`/registry mechanism; no addition to `anima.gd`'s public surface.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
