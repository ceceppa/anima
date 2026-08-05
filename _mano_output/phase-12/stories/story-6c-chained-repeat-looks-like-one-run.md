### STORY-6c: Chained repeat looks like a single run, not two

#### What and why
A developer selecting the Chained family expects to see two separate `move_by` legs the way its shown `.repeat(2)` example line implies — but the two identical, non-eased legs concatenate into one seamless glide across the full distance, so the run reads as a single motion, not a visibly repeated one, even though `on_started`/`on_completed` still fire once for the whole run as designed.

#### Done when
- [ ] Selecting the Chained family shows a run with a visible break between its two repetitions (e.g. a pause, or a direction/pace change), instead of one uninterrupted glide across the full combined distance
- [ ] Test: an integration test confirms a measurable discontinuity exists between the two repetitions — for example, the card's motion pauses or its direction changes momentarily between legs — rather than the position advancing at one constant, unbroken rate for the whole run

#### Not this story
- Any change to `AnimaRepeat` itself — the runtime already replays each iteration correctly, confirmed by this phase's own `test_chained_family_demonstrates_callbacks_repeat_and_reverse_together` (the card ends up 100px from base after two 50px legs); this is purely about how the demo makes that visible
- Any change to the Chained family's `on_started`/`on_completed` callback behaviour — that already works as intended

#### Notes
Two identical linear `move_by` legs back-to-back are visually indistinguishable from one linear motion of twice the distance — not a functional repeat failure. `AnimaRepeat` already exposes `delay_between` (a pause between iterations) and `.repeat(count, alternate)`'s `alternate` flag (reverses odd iterations) as existing, undocumented-in-the-demo mechanisms that could make the repeat visible; which one to use is an implementation choice, not decided here.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.gd` (`_build_chained_motion()`)
- **Contract:** `addons/anima/motion/resources/anima_repeat.gd` — `delay_between`, `alternate` (existing exported fields); `addons/anima/motion/resources/anima_motion.gd` — `repeat(count, alternate)` chain signature
- **Rules:** Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
