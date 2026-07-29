### STORY-6: Functional builder API

#### What and why
A developer authoring a composition writes fluent, chainable GDScript (`Motion.sequence(...)`, `Motion.to(...).duration(...).ease(...)`) instead of constructing and wiring `AnimaMotion` resources by hand — the same structures, a lighter-weight way to write them.

#### Done when
- [ ] Building a Sequence, Parallel, Stagger, Repeat, Race, or Conditional through the `Motion` builder's static factories produces the same playback behaviour as building the equivalent structure by hand with direct resource construction.
- [ ] Building a property motion through `Motion.to(...)` and chaining `.duration(...)`/`.ease(...)` configures the same leaf motion direct construction would.
- [ ] Test: a builder-built Sequence of two property motions plays identically (same start times, same finish time) to the same Sequence built by direct resource construction.
- [ ] Test: a builder-built Stagger, Repeat, Race, and Conditional each play identically to their direct-construction equivalent, one representative case per type.

#### Not this story
- No named presets (`fade_in`, `tada`, etc.) in the builder — only generic factories this phase (tech spec, Out of Scope).
- No variadic call syntax — multi-child factories take an explicit `Array[AnimaMotion]` argument (tech spec's deliberate divergence from the PRD's illustrative comma-separated syntax), not comma-separated arguments.

#### Notes
Depends on stories 1-5 in this phase (all composite types the builder wraps) plus Phase 1's existing `AnimaSequence`/`AnimaParallel`/`AnimaPropertyMotion`.

#### Implementation Reference
- **Data:** `Motion` builder — `tech-spec.md` §Data model row (static factories: `sequence`, `parallel`, `stagger`, `repeat`, `race`, `conditional`, `to`, with exact signatures).
- **Files:** `addons/anima/motion/resources/anima_motion_builder.gd`, `class_name Motion` — `project-rules.md` §Folder Structure.
- **Naming:** `Motion` is the sanctioned, explicit exception to the `Anima`-prefix naming rule — `project-rules.md` §Naming.
- **Testing:** `tests/Motion.test.gd` — `project-rules.md` §Testing.
- **Do not:** add named presets; accept variadic arguments instead of an `Array[AnimaMotion]`.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
