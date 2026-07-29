### STORY-4: Race composition

#### What and why
A developer racing two or more competing effects — whichever finishes first "wins" — builds an `AnimaRace` from several children and lets the group resolve the moment the fastest one finishes, with the rest stopping in place rather than continuing to play out to their own end.

#### Done when
- [ ] Playing a Race of several children completes as soon as the fastest child finishes.
- [ ] With `cancel_remaining` at its default value, the moment the Race completes, the other children stop animating instead of continuing to play out to their own end.
- [ ] Querying a Race's estimated duration when every child uses a Fixed-duration motion reports kind Fixed, with a value equal to the fastest child's own duration.
- [ ] Test: a Race of a fast and a slow child completes at the fast child's finish time, not the slow one's.
- [ ] Test: after a Race completes, the slower child's target property no longer changes on subsequent frames.
- [ ] Test: a Race of Fixed-duration children reports Fixed duration equal to the shortest child's duration.

#### Not this story
- `cancel_remaining = false` has no defined effect this phase — the field exists for future extensibility only (tech spec, Out of Scope).

#### Notes
`AnimaRace` joins the worst-kind-wins duration group (`tech-spec.md` §Key technical decisions "Duration-kind combining rule") — once every child is Fixed, its `seconds` value is the minimum of the children's, matching "the fastest child decides completion."

#### Implementation Reference
- **Data:** `AnimaRace` — `tech-spec.md` §Data model row (`children`, `cancel_remaining` default `true`).
- **Rules:** "cancel" means the runtime stops calling `advance()` on losing children — never `AnimaPlayback.cancel()` — `tech-spec.md` §Key technical decisions "`AnimaRace`/`AnimaParallel` cancelling...".
- **Rules:** Fixed-case `seconds` formula — `tech-spec.md` §Key technical decisions "Duration-kind combining rule", `AnimaRace` row: minimum of children's `seconds`.
- **Files:** `addons/anima/motion/resources/anima_race.gd` + runtime instance under `addons/anima/motion/runtime/` — `project-rules.md` §Folder Structure.
- **Testing:** `tests/AnimaRace.test.gd` + `tests/Anima.integration.race.test.gd` — `project-rules.md` §Testing.
- **Do not:** route cancellation through `AnimaPlayback.cancel()`; implement `cancel_remaining = false` behaviour.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
