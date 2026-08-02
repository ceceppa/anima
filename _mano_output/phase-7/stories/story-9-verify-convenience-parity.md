### STORY-9: Verify convenience parity

#### What and why
Motion authors can rely on concise authoring without accepting hidden behavioural or performance trade-offs. The public APIs are exercised against their canonical equivalents across the ways authors actually use them.

#### Done when
- [ ] Every supported convenience motion has an automated equivalence check against its canonical property motion.
- [ ] Automated public-surface runs cover target removal, resource serialization, composition, reverse playback, interruption, Composer editing, and native compilation.
- [ ] The benchmark records the defined creation comparison for every supported semantic motion and passes the performance budget.
- [ ] Test output identifies the motion family when an equivalence or budget check fails.

#### Not this story
- Adding new convenience methods or Grid formulas.
- Manual performance tuning unrelated to a failed budget.

#### Notes
Depends on: stories 1 through 8.

#### Implementation Reference
- **Files:** `tests/Anima.integration.convenience-parity.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Convenience performance budget`; `§Target-bound authoring contract`; `§Convenience method interface`; `§Key technical decisions`
- **Rules:** `_mano_output/project-rules.md §Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
