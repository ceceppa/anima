### STORY-2: Stagger composition

#### What and why
A developer animating a list of nodes — buttons appearing one after another, list rows fading in in sequence — builds a single `AnimaStagger` from one template motion and a list of target nodes, instead of hand-building a separate motion per node with manually-computed offsets. The stagger's order (forward, reverse, from the middle out, from both ends in, or an explicit custom order) controls which target starts first.

#### Done when
- [ ] Playing a Stagger built from a template motion and several target nodes starts each target's copy of the motion the configured interval after the previous one.
- [ ] Setting the Stagger's order controls which target starts first and the sequence after: forward starts in list order, reverse starts in the opposite order, from-center starts outward from the middle of the list, from-edges starts inward from both ends, and a custom order starts in the exact index sequence given.
- [ ] Querying a Stagger's estimated duration when its template and all targets use a Fixed-duration motion reports kind Fixed, with a value equal to the last target's start offset plus the template's own duration — not a per-target sum.
- [ ] Letting a Stagger run to completion — every target's copy of the template motion finishes.
- [ ] Test: each ordering (forward, reverse, from-center, from-edges, custom) produces its expected target start sequence for a small fixed target list.
- [ ] Test: a Stagger built from several Fixed-duration targets reports Fixed duration equal to `(target count - 1) × interval + the template's own duration`, end-to-end via `Anima.play()`.

#### Not this story
- No target-collection/selector system — `targets` is a plain `Array[Node]` this phase; resolving targets from a group, grid, or other dynamic source is a separate, later backlog item (tech spec, Out of Scope).
- Random order's exact resulting sequence is not asserted — it's non-deterministic by design; this story only verifies it runs every target to completion without erroring.
- No editor visual distinction for duration kinds (phase brief, Not This Phase).

#### Notes
Stagger's reported Fixed `seconds` value follows its own dedicated formula — `tech-spec.md` §Key technical decisions "Duration-kind combining rule" — distinct from `AnimaSequence`'s sum and `AnimaParallel`'s max, since Stagger's per-target copies start staggered/concurrently rather than serially.

#### Implementation Reference
- **Data:** `AnimaStagger` — `tech-spec.md` §Data model row (`template`, `targets`, `interval` default `0.05`, `order` enum default `FORWARD`, `custom_order`).
- **Rules:** Stagger ignores the `target` argument its own `advance()` receives, driving each `targets` entry through its own `template.create_runtime()` instance instead — `tech-spec.md` §Key technical decisions "`AnimaStagger` ignores the `target` argument..."; contract methods per `project-rules.md` §Patterns.
- **Rules:** `Anima.play()`'s `target` parameter is optional for a top-level Stagger — `tech-spec.md` §Data model `Anima` row.
- **Files:** `addons/anima/motion/resources/anima_stagger.gd`; runtime instance under `addons/anima/motion/runtime/` (mirrors the existing `anima_sequence_instance.gd` pattern) — `project-rules.md` §Folder Structure.
- **Rules:** Fixed-case `seconds` formula — `tech-spec.md` §Key technical decisions "Duration-kind combining rule", `AnimaStagger` row: `(targets.size() - 1) × interval + template.seconds`.
- **Testing:** `tests/AnimaStagger.test.gd` + `tests/Anima.integration.stagger.test.gd` — `project-rules.md` §Testing.
- **Do not:** build a target-collection/selector system; sum per-target durations for the Fixed `seconds` value (see Rules above).

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
