### STORY-5: Parallel composition

#### What and why
A Godot developer wants to say "run these together" — two or three motions starting at once, finishing on a rule they choose. This story lets them compose property motions into a Parallel group.

#### Done when
- [ ] Playing a Parallel of two property motions starts both immediately and runs them at the same time.
- [ ] With no completion policy specified, a Parallel finishes only once every child has finished.
- [ ] A Parallel can be configured to finish as soon as its first child finishes, or as soon as one specific named child finishes, instead of waiting for all of them.
- [ ] Test: a unit test plays a Parallel of property motions across simulated frames and asserts the concurrent start and each completion-policy behaviour above.

#### Not this story
- No Sequence composition — covered by story-4.
- No nested Sequence-inside-Parallel end-to-end test — that's story-6.

#### Notes
Depends on: story-0, story-3. Default completion-policy value: `tech-spec.md` §Data model (`AnimaParallel` row).

#### Implementation Reference
- **Build:** `AnimaParallel`, extends `AnimaMotion`
- **Data:** `tech-spec.md` §Data model (`AnimaParallel` row) — completion-policy values and default
- **Rules:** `project-rules.md` §Patterns — implement the full base contract explicitly
- **Test:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
