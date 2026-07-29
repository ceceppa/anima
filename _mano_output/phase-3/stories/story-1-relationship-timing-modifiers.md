### STORY-1: Relationship timing modifiers

#### What and why
A developer chaining motions in an `AnimaSequence` can make a child start before its predecessor finishes (an overlap) or a fixed offset after the predecessor *begins* rather than after it *ends* — instead of every child being strictly back-to-back. This is the relative-timing vocabulary ("with a slight overlap", "starting shortly after this one begins") the product's relationships-before-timestamps principle promises.

#### Done when
- [ ] A Sequence child with a negative delay (relative to the previous child's end) starts before the previous child finishes, overlapping it by that amount.
- [ ] A Sequence child with a positive delay relative to the previous child's end still starts that many seconds after the previous child finishes, unchanged from existing behaviour.
- [ ] A Sequence child configured to start relative to the previous child's start begins that many seconds after the previous child began, regardless of how long the previous child itself takes.
- [ ] The first child in a Sequence starts at its own delay relative to the Sequence's own start — there is no predecessor for it to overlap or offset against.
- [ ] Test: an overlapping child (negative delay, relative to the previous child's end) starts before the predecessor's end by the configured amount.
- [ ] Test: a child configured relative to the previous child's start begins at the offset from that start, independent of the predecessor's own duration.
- [ ] Test: the first child's effective start ignores predecessor-relative semantics and uses only its own delay from the Sequence's start.

#### Not this story
- `AnimaParallel` does not consume delay/delay-basis this phase — only `AnimaSequence` does (tech spec, Out of Scope).
- No new completion-threshold kinds — timing modifiers use exact-end completion only, per the phase brief's scope line.
- No stagger-style, per-target interval timing — that's `AnimaStagger` (story-2).

#### Implementation Reference
- **Contract:** `AnimaMotion.delay: float` (may now be negative), `delay_basis: AFTER_PREVIOUS_ENDS | AFTER_PREVIOUS_STARTS` (default `AFTER_PREVIOUS_ENDS`) — `tech-spec.md` §Data model `AnimaMotion` row.
- **Rules:** child effective-start formula — `tech-spec.md` §Key technical decisions "`AnimaSequence` child timing" (first child has no predecessor; both bases resolve to "relative to the sequence's own start" for it).
- **Files:** `addons/anima/motion/resources/anima_sequence.gd` (child-start scheduling); `addons/anima/motion/resources/anima_motion.gd` (`delay_basis` enum + negative-delay support on the base type) — `project-rules.md` §Folder Structure.
- **Testing:** extend `tests/AnimaSequence.test.gd` — `project-rules.md` §Testing.
- **Do not:** apply delay/delay-basis consumption inside `AnimaParallel` — `tech-spec.md` §Out of Scope reserves this to `AnimaSequence` only.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
