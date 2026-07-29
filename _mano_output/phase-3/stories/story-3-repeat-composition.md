### STORY-3: Repeat composition

#### What and why
A developer repeating a pulse, blink, or bounce a fixed number of times builds a single `AnimaRepeat` wrapping one child motion, instead of manually chaining copies of it in a Sequence. An optional alternate mode ping-pongs a wrapped property motion back and forth on every other repetition, so a bounce looks like it reverses instead of always snapping back to its start.

#### Done when
- [ ] Playing a Repeat of a child motion for a configured count runs the child that many times in a row before the overall Repeat completes.
- [ ] Setting a delay-between value waits that long between each repetition before the next one starts.
- [ ] Setting alternate to true on a Repeat wrapping a single property motion reverses the from/to values on every other repetition, so the animated value visibly moves back and forth instead of always animating in the same direction.
- [ ] Querying a Repeat's estimated duration reports kind Fixed when its child uses a Fixed-duration motion.
- [ ] Test: a Repeat with count 3 and no alternate runs the child motion three times and finishes.
- [ ] Test: an alternating Repeat wrapping a property motion animates forward on odd repetitions and backward on even ones.

#### Not this story
- No infinite repeat counts — `count` is always finite this phase (phase brief, Not This Phase).
- Alternate is undefined for a composite (non-`AnimaPropertyMotion`) child — reversing a `Sequence`/`Parallel` under alternate is deferred to the separate reversibility epic (tech spec, Out of Scope).

#### Implementation Reference
- **Data:** `AnimaRepeat` — `tech-spec.md` §Data model row (`child`, `count` default `1`, `delay_between` default `0.0`, `alternate` default `false`).
- **Rules:** alternate swaps `from_value`/`to_value` on an `AnimaPropertyMotion` child only, on odd iterations — `tech-spec.md` §Data model `AnimaRepeat` row + §Out of Scope.
- **Files:** `addons/anima/motion/resources/anima_repeat.gd` + runtime instance under `addons/anima/motion/runtime/` — `project-rules.md` §Folder Structure.
- **Testing:** `tests/AnimaRepeat.test.gd` + `tests/Anima.integration.repeat.test.gd` — `project-rules.md` §Testing.
- **Do not:** support infinite repeat counts; define alternate behaviour for a non-`AnimaPropertyMotion` child.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
