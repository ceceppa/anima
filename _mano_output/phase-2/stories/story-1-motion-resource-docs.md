### STORY-1: Motion resource class docs

#### What and why
A developer opens the docs site wanting to know what building blocks Anima gives them to describe an animation, and finds a complete reference page for every motion resource type — the base motion contract, the property-animation leaf, the two composition types, and the easing resource — instead of having to read GDScript source to find out what fields and methods each one has.

#### Done when
- [ ] `AnimaMotion` page exists at `docs/content/docs/anima/anima-motion.md`, following the documentation-page convention, documenting every property and method from `tech-spec.md`'s `AnimaMotion` row
- [ ] `AnimaPropertyMotion` page exists at `docs/content/docs/anima/anima-property-motion.md`, following the documentation-page convention, documenting every property from `tech-spec.md`'s `AnimaPropertyMotion` row, with a runnable Quick example
- [ ] `AnimaSequence` page exists at `docs/content/docs/anima/anima-sequence.md`, following the documentation-page convention, documenting every property from `tech-spec.md`'s `AnimaSequence` row, with a runnable Quick example
- [ ] `AnimaParallel` page exists at `docs/content/docs/anima/anima-parallel.md`, following the documentation-page convention, documenting every property from `tech-spec.md`'s `AnimaParallel` row (including the `CompletionPolicy` enum's three values), with a runnable Quick example
- [ ] `AnimaEase` page exists at `docs/content/docs/anima/anima-ease.md`, following the documentation-page convention, documenting every property and method from `tech-spec.md`'s `AnimaEase` row (including the `Kind` enum's five values), with a runnable Quick example
- [ ] On each of the five pages, every Godot-specific term (`Resource`, `NodePath`, `signal`, `class_name`, and similar) is defined in plain language the first time it appears, and the Quick example runs standalone using nothing not already explained earlier on that same page

#### Not this story
- No docs for `Anima`, `AnimaPlayback`, or `AnimaRuntime` — covered by story-2.
- No docs for the internal `*Instance` runtime classes — covered by story-3.
- No removal of existing v1 documentation — covered by story-4.

#### Notes
The `anima_version` front-matter field has no resolved value yet (final version numbering is an open, deliberately-deferred product decision). Use `"2.x (unreleased)"` as an explicit temporary placeholder on all five pages until that decision lands.

#### Implementation Reference
- **Build:** 5 documentation pages, one per class
- **Files:** read `addons/anima/motion/resources/anima_motion.gd`, `anima_property_motion.gd`, `anima_sequence.gd`, `anima_parallel.gd`, `anima_ease.gd` for the actual current implementation; write pages to `docs/content/docs/anima/`
- **Contract:** `tech-spec.md` §Data model — one row per class, the canonical source for properties/methods/defaults
- **Contract:** `tech-spec.md` §Platform constraints — source for the Availability section's Godot version; do not restate a version number that isn't there
- **Rules:** `project-rules.md` §Documentation — page location/naming, required structure, conditional sections, beginner-friendly voice rule
- **Do not:** invent properties, methods, or defaults not present in the source file or `tech-spec.md`'s row

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
