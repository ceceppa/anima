### STORY-2: Add lifecycle callbacks

#### What and why
Motion authors can attach code to run exactly when a motion begins and exactly when it finishes successfully, directly on the motion they authored, instead of having to hold onto the object `Anima.play()` returns just to react to it.

#### Done when
- [ ] Chaining `.on_started(callback)` on any motion (a single property motion, a composed Sequence/Parallel, a Group, or a Repeat) runs `callback` exactly once, at the moment that motion begins playing.
- [ ] Chaining `.on_completed(callback)` runs `callback` exactly once, only when that playback finishes successfully — not when it is cancelled.
- [ ] Both callbacks can be chained on the same motion together, and each still fires independently.
- [ ] Reversing an in-progress playback that already fired `on_started` fires it again for the new reversed run.
- [ ] Test: `on_completed` does not fire when playback is cancelled before finishing.
- [ ] Test: both callbacks fire in the expected order — `on_started` before any visible change, `on_completed` after the last one — across at least one leaf and one composite motion.

#### Not this story
- Any change to the existing `AnimaPlayback.finished` signal.
- The still-open "callback reversal mechanism" spec gap (the mid-timeline Callback leaf type) — unrelated, see `tech-spec.md §Key technical decisions`.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_motion.gd`; `addons/anima/motion/runtime/anima_playback.gd`; `tests/AnimaMotion.test.gd`; `tests/AnimaPlayback.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract` (lifecycle callbacks paragraph); `§Convenience method interface`; `§Data model` (`AnimaMotion` row)
- **Rules:** `_mano_output/project-rules.md §Naming`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
