### STORY-6: Nested composition with easing

#### What and why
A Godot developer builds the shape Anima exists for: something that runs alongside other things, then moves on to what's next, feeling like more than a straight line. This story proves the whole Phase 1 runtime holds together — Sequence, Parallel, property motions, and real easing, composed and played as one motion.

#### Done when
- [ ] A Sequence containing a Parallel of two property motions, followed by a third property motion, plays so that the parallel pair runs simultaneously and the third motion's property does not begin changing until both finish.
- [ ] The same structure, built once with a linear curve and once with a non-linear curve on its property motions, produces visibly different value-over-time behaviour between the two runs.
- [ ] Test: an integration test plays the full nested structure across simulated frames and asserts the ordering, concurrency, and easing behaviour above, end to end.

#### Not this story
- No new motion types or runtime behaviour — this story only composes and verifies what stories 0-5 already built.

#### Notes
Depends on: story-1, story-2, story-3, story-4, story-5. Owns the phase's end-to-end verification — Exit Criteria 1 ("Compose and play") and 2 ("Easing") in `phase-brief.md`.

#### Implementation Reference
- **Build:** none new — composition only, using story-0 through story-5's types
- **Test:** `project-rules.md` §Testing — `Anima.integration.<name>.test.gd` naming
- **Reference:** `_mano_output/phase-1/phase-brief.md` §Exit Criteria, items 1-2

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
