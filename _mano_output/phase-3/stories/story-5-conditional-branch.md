### STORY-5: Conditional branch

#### What and why
A developer picking between two motions based on a condition — a success animation versus a failure one, a branch that depends on game state — builds a single `AnimaConditional` instead of hand-writing an if/else around two separate `Anima.play()` calls. The condition can resolve immediately (compile-time) when it's already known, or be deferred until the motion actually starts playing (runtime, the default and safer choice).

#### Done when
- [ ] Building a Conditional with a compile-time-resolved condition and playing it runs whichever branch the condition selected, immediately.
- [ ] Building a Conditional with the default runtime-resolved condition — before it plays, querying its estimated duration reports kind Dynamic.
- [ ] Once a runtime-resolved Conditional starts playing, it runs the branch the condition selected at that point, and that branch's own motion is what visibly plays out.
- [ ] Test: a compile-time Conditional whose condition is true plays the `when_true` branch; whose condition is false plays `when_false`.
- [ ] Test: a runtime-resolved Conditional reports Dynamic duration before playing, then completes exactly when its selected branch completes.
- [ ] Test: a Sequence containing a runtime-resolved Conditional as one of its children reports Dynamic duration overall, rather than a computed Fixed number.

#### Not this story
- No node-lifecycle authoring surface (`enter()`/`exit()`) — depends on `AnimaBehaviour`, not built yet (phase brief, Not This Phase).
- The condition is evaluated at most once per play — no continuous re-checking while the Conditional is playing.

#### Implementation Reference
- **Data:** `AnimaConditional` — `tech-spec.md` §Data model row (`when_true`, `when_false`, `condition: Callable`, `resolution_timing` default `RUNTIME`).
- **Rules:** `COMPILE_TIME` vs `RUNTIME` resolution behaviour — `tech-spec.md` §Data model `AnimaConditional` row (exact behaviour per mode: `COMPILE_TIME` calls `condition` inside `estimate_duration()`; `RUNTIME` returns `Kind.DYNAMIC` without calling it, then selects the branch once inside `create_runtime()`).
- **Rules:** Dynamic-kind combining when nested inside another composite — `tech-spec.md` §Key technical decisions "Duration-kind combining rule"; `phase-brief.md` §Assumption Log (Conditional/Dynamic-duration risk this satisfies).
- **Files:** `addons/anima/motion/resources/anima_conditional.gd` + runtime instance under `addons/anima/motion/runtime/` — `project-rules.md` §Folder Structure.
- **Testing:** `tests/AnimaConditional.test.gd` + `tests/Anima.integration.conditional.test.gd` — `project-rules.md` §Testing.
- **Do not:** re-evaluate `condition` after the branch is selected inside `create_runtime()`.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
