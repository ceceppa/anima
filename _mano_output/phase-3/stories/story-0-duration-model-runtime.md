### STORY-0: Duration model runtime

#### What and why
A developer inspecting how long a motion will take — before or without playing it — gets back a duration *kind* (Fixed, Estimated, Dynamic, or Infinite) instead of a bare number, so callers can tell "this takes exactly 2.4s" apart from "this can't be known yet." Every existing Phase 1 motion type (`AnimaSequence`, `AnimaParallel`, `AnimaPropertyMotion`) is retrofitted onto this contract so later composite types in this phase have a consistent duration model to plug into.

#### Done when
- [ ] Querying an `AnimaPropertyMotion`'s estimated duration reports kind Fixed together with its configured duration value.
- [ ] Querying an `AnimaSequence` made only of Fixed-duration children reports kind Fixed with the sum of the children's durations.
- [ ] Querying an `AnimaParallel` (default completion policy) made only of Fixed-duration children reports kind Fixed with the longest child's duration.
- [ ] Test: an `AnimaPropertyMotion` instance reports kind Fixed with its configured duration.
- [ ] Test: an `AnimaSequence` of only-Fixed children reports Fixed with the summed duration.
- [ ] Test: an `AnimaParallel` (default policy) of only-Fixed children reports Fixed with the longest child's duration.

#### Not this story
- No motion type in this story ever reports Estimated, Dynamic, or Infinite — no leaf or composite that produces those kinds exists until later stories in this phase (`AnimaConditional`, story-5, is the first to report Dynamic).
- No editor visual distinction for duration kinds — that's a separate, later backlog item (Not This Phase in the phase brief).

#### Notes
This story is foundational groundwork every other composite story in this phase builds on — `AnimaStagger`, `AnimaRepeat`, `AnimaRace`, and `AnimaConditional` (stories 2-5) all implement `estimate_duration()` against the `AnimaDuration` contract this story establishes, and the worst-kind-wins combining rule this story implements for `AnimaSequence`/`AnimaParallel` only becomes observable with a non-Fixed kind once story-5 (Conditional) exists — that combining behaviour is tested there, not here.

#### Implementation Reference
- **Data:** `AnimaDuration` — `tech-spec.md` §Data model `AnimaDuration` row (`kind: FIXED | ESTIMATED | DYNAMIC | INFINITE`, `seconds: float`).
- **Contract:** every `AnimaMotion` subtype's `estimate_duration()` return type changes to `AnimaDuration` — `tech-spec.md` ⚠️ Note (replaces Phase 1's plain-`float` contract). Retrofit `AnimaMotion` (base), `AnimaSequence`, `AnimaParallel`, `AnimaPropertyMotion`.
- **Rules:** combining rule — `tech-spec.md` §Key technical decisions "Duration-kind combining rule" (worst kind wins; `AnimaSequence` sums Fixed `seconds`, `AnimaParallel` takes the max).
- **Patterns:** every subtype implements `estimate_duration()` explicitly, no inherited default — `project-rules.md` §Patterns.
- **Files:** new `addons/anima/motion/resources/anima_duration.gd`; edits to `addons/anima/motion/resources/anima_motion.gd`, `anima_sequence.gd`, `anima_parallel.gd`, `anima_property_motion.gd` — `project-rules.md` §Folder Structure.
- **Testing:** `tests/AnimaDuration.test.gd`; extend existing `tests/AnimaSequence.test.gd`, `tests/AnimaParallel.test.gd`, `tests/AnimaPropertyMotion.test.gd` — `project-rules.md` §Testing.
- **Do not:** invent a synthetic Estimated/Dynamic/Infinite-producing leaf just to test the combining rule's non-Fixed branch in this story — code the general rule now (later stories rely on it), but its non-Fixed path is exercised in story-5.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
