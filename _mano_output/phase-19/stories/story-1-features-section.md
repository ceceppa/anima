### story-1: Built-in Animations and Easings feature pages

#### What and why
A developer wanting to know what ships out of the box currently has to browse folders or read source. This story gives them two scannable reference pages — every built-in animation, and every built-in easing curve — each showing how to actually use an entry, not just naming it.

#### Done when
- [ ] The Features section contains a "Built-in Animations" page:
  - It lists the catalog by category (the 16 categories the animation catalog ships under).
  - It contains at least one runnable `gdscript` code block showing how to play a named catalog animation.
- [ ] The Features section contains a "Built-in Easings" page:
  - It lists every named easing curve the addon ships.
  - It contains at least one runnable `gdscript` code block showing how to apply a named easing curve to an animation.

#### Not this story
- No catalogue of every dynamic-value operator, keyframe option, or other non-Feature concept — those are Guides (story-2).
- No image assets — plain text/code pages only, per this phase's Hugo-only scope.

#### Implementation Reference
- **Build:** `docs/content/docs/features/built-in-animations.md`, `docs/content/docs/features/built-in-easings.md` — plain `.md` pages (no leaf bundle, no images) — `tech-spec.md` §Documentation site structure (phase-19).
- **Data:** the full animation catalog (99 presets across 16 categories) — `tech-spec.md` §Animation catalog and `project-rules.md` §Animation Catalog own the category list and folder layout; play a catalog preset via `Anima.animation(name)` — `tech-spec.md` §Animation catalog interface. The full named easing-curve set — `tech-spec.md` §Easing curve library owns the complete `AnimaEase.Kind` list; apply a named curve via `.with_ease(AnimaEase.Kind....)` — `tech-spec.md` §Convenience method interface / §Keyframe interface.
- **Rules:** runnable-example requirement — `project-rules.md` §Documentation ("Every Feature, Guide, and Tutorial page contains at least one fenced `gdscript` code block...").
- **Do not:** don't invent categories or curves not already named in `tech-spec.md`; don't duplicate the generated per-class reference under `docs/content/docs/anima/` — link to it instead of restating member lists.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
