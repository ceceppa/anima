### STORY-4: Start playback already reversed, with delay and speed

#### What and why
Motion authors can start a motion playing backward from the first frame — or choose the direction from a condition at the moment they play it — instead of only being able to reverse a motion that has already run forward. They can also delay or speed up a motion played on its own, not only one nested inside a Sequence.

#### Done when
- [ ] Playing a motion through the new backward-start entry point plays it in reverse from the first frame, with no prior forward run required.
- [ ] Choosing forward or backward playback from a condition is possible by branching between the normal and backward-start entry points, with no dedicated third method needed.
- [ ] A motion's own delay is honoured when played on its own, not only when nested inside a Sequence — playback visibly waits that long before the target changes.
- [ ] Chaining `.with_speed(value)` changes how fast a motion plays, for a motion played forward or backward.
- [ ] Test: starting a Group Motion or Grid Motion already reversed produces the same end state as playing it forward and then reversing it.
- [ ] Test: a zero delay behaves the same as no delay at all.

#### Not this story
- A dedicated conditional-direction method — covered by ordinary branching over the two entry points.
- Interrupting or retargeting a playback already in progress (existing behaviour, unchanged).

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima.gd`; `addons/anima/motion/runtime/anima_playback.gd`; `addons/anima/motion/resources/anima_motion.gd`; `tests/AnimaPlayback.test.gd`; `tests/Anima.integration.playback.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract` (immediate backward playback, root-level delay paragraphs); `§Convenience method interface` (`Anima` static facade row; `.with_speed`); `§Key technical decisions` (`play_backwards()` vs `reverse()`)
- **Rules:** `_mano_output/project-rules.md §Architecture`; `§Naming`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
