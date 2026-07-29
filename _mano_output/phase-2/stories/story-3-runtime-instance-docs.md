### STORY-3: Internal runtime-instance class docs

#### What and why
A curious developer who goes looking for what `create_runtime()` actually returns finds a documented answer for each motion type — instead of four undocumented internal classes — and the page itself makes clear these are runtime-internal, not something they construct directly.

#### Done when
- [ ] `AnimaMotionInstance` page exists at `docs/content/docs/anima/anima-motion-instance.md`, following the documentation-page convention; its Overview states plainly that it is created internally by `create_runtime()` and is not constructed directly by a developer
- [ ] `AnimaPropertyMotionInstance` page exists at `docs/content/docs/anima/anima-property-motion-instance.md`, following the documentation-page convention, with the same internal-class framing in its Overview
- [ ] `AnimaSequenceInstance` page exists at `docs/content/docs/anima/anima-sequence-instance.md`, following the documentation-page convention, with the same internal-class framing in its Overview
- [ ] `AnimaParallelInstance` page exists at `docs/content/docs/anima/anima-parallel-instance.md`, following the documentation-page convention, with the same internal-class framing in its Overview
- [ ] On each of the four pages, every Godot-specific term is defined in plain language the first time it appears

#### Not this story
- No docs for the motion resource classes or the playback/runtime entry points — covered by story-1 and story-2.
- No removal of existing v1 documentation — covered by story-4.
- No Quick example requirement — these classes aren't constructed directly, so a "quick example" would misleadingly imply direct use; each page's Overview and Methods sections are enough.

#### Notes
Depends on: story-1, story-2 (for consistent cross-references — each `*Instance` page should link back to the resource or entry-point page it's paired with, e.g. `AnimaPropertyMotionInstance` ↔ `AnimaPropertyMotion`).

Same temporary `anima_version` placeholder as story-1: `"2.x (unreleased)"`.

#### Implementation Reference
- **Build:** 4 documentation pages, one per class
- **Files:** read `addons/anima/motion/runtime/anima_motion_instance.gd`, `anima_property_motion_instance.gd`, `anima_sequence_instance.gd`, `anima_parallel_instance.gd` for the actual current implementation; write pages to `docs/content/docs/anima/`
- **Contract:** `tech-spec.md` §Platform constraints — source for the Availability section's Godot version
- **Rules:** `project-rules.md` §Documentation — page location/naming, required structure, conditional sections, beginner-friendly voice rule
- **Rules:** `project-rules.md` §Documentation's "Related API" guidance — use it for the cross-reference link back to the paired resource/entry-point page
- **Do not:** invent properties or methods not present in the source file; do not add a Quick example section

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
