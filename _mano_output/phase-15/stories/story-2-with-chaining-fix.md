### STORY-2: .with() chaining plays and stops correctly

#### What and why
A developer combining two motions via `.with(...)` expects both to play together and finish or stop correctly, matching how `.then()`/`.with()` are documented to work for any motion. Today the combined chain doesn't play or stop as expected, which makes `.with()` unusable for its documented purpose.

#### Done when
- [ ] Two motions combined via `.with(...)` both start playing at the same time when the combined chain is played
- [ ] The combined chain reports finished only once both motions have completed
- [ ] Stopping/cancelling the combined chain stops both motions
- [ ] Test: `.with()` used twice in the same chain (three motions total) still plays and finishes correctly

#### Not this story
- Any change to `.then()`'s sequential behaviour
- Diagnosing or documenting a root cause beyond what's needed to satisfy the acceptance criteria above

#### Notes
The phase brief's Acknowledged Risks flags that this defect's root cause isn't diagnosed yet — the acceptance criteria define the required end behaviour without prescribing the fix; the actual fix scope may turn out larger than a single-method patch.

#### Implementation Reference
- **Build:** fix `.with(other)` composition so the resulting `AnimaParallel` plays and reports completion correctly (`tech-spec.md §Target-bound authoring contract` — "`.with(other)` folds `other` into the same `AnimaParallel` group")
- **Files:** `addons/anima/motion/resources/anima_motion.gd` (`.with()` chain method); `addons/anima/motion/resources/anima_parallel.gd` (parallel playback/completion)
- **Rules:** `project-rules.md §Testing` — integration test required (multiple classes composed through `Anima.play()`), named `Anima.integration.<name>.test.gd`; `project-rules.md §Documentation` — update the `##` doc comment for `.with()` if its documented behaviour changes

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
