### STORY-2: Playback and runtime entry-point docs

#### What and why
A developer who has built a motion out of the resource types from story-1 now needs to know how to actually play it, pause it, or cancel it — and finds a page for the `Anima` entry point, the playback handle it returns, and the runtime that drives it, instead of guessing at the API from the Quick examples on other pages.

#### Done when
- [ ] `Anima` page exists at `docs/content/docs/anima/anima.md`, following the documentation-page convention, documenting the `play()` method from `tech-spec.md`'s `Anima` row, with a runnable Quick example
- [ ] `AnimaPlayback` page exists at `docs/content/docs/anima/anima-playback.md`, following the documentation-page convention, documenting every property, method, and signal from `tech-spec.md`'s `AnimaPlayback` row (including the `State` enum's four values)
- [ ] `AnimaRuntime` page exists at `docs/content/docs/anima/anima-runtime.md`, following the documentation-page convention, documenting the `active_playbacks` property from `tech-spec.md`'s `AnimaRuntime` row, and its Overview plainly states that it is created automatically on first use and is not something a developer instantiates directly
- [ ] On each of the three pages, every Godot-specific term is defined in plain language the first time it appears, and the Quick example runs standalone using nothing not already explained earlier on that same page

#### Not this story
- No docs for the motion resource classes (`AnimaMotion`, `AnimaSequence`, `AnimaParallel`, `AnimaPropertyMotion`, `AnimaEase`) — covered by story-1.
- No docs for the internal `*Instance` runtime classes — covered by story-3.
- No removal of existing v1 documentation — covered by story-4. Note: a v1-era `anima.md` already exists at this same path; this story's write replaces its content rather than being blocked by it.

#### Notes
Depends on: story-1 (for consistent cross-references to the motion resource types used in these pages' examples).

Same temporary `anima_version` placeholder as story-1: `"2.x (unreleased)"`.

#### Implementation Reference
- **Build:** 3 documentation pages, one per class
- **Files:** read `addons/anima/motion/runtime/anima.gd`, `anima_playback.gd`, `anima_runtime.gd` for the actual current implementation; write pages to `docs/content/docs/anima/`
- **Contract:** `tech-spec.md` §Data model — `Anima`, `AnimaPlayback`, `AnimaRuntime` rows
- **Contract:** `tech-spec.md` §Platform constraints — source for the Availability section's Godot version
- **Rules:** `project-rules.md` §Documentation — page location/naming, required structure, conditional sections, beginner-friendly voice rule
- **Do not:** invent properties, methods, or signals not present in the source file or `tech-spec.md`'s row

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
