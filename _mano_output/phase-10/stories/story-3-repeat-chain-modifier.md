### STORY-3: Add repeat as a chain modifier

#### What and why
Motion authors can make any motion repeat — including one built through `Anima.on()` — by chaining a single call, instead of constructing a separate wrapper resource by hand. Alternating each repeat between forward and backward is available the same way.

#### Done when
- [ ] Chaining `.repeat(count)` on any motion plays it that many times in a row.
- [ ] Omitting `count` repeats the motion indefinitely.
- [ ] Chaining `.repeat(count, alternate = true)` plays every other iteration in reverse, alternating forward and backward each time.
- [ ] A repeating motion built through `Anima.on()` (e.g. `.move_by(...).repeat(3)`) produces the same visible result as the same repeat built with `Motion.repeat(child, count)`.
- [ ] Reversing a repeating motion in progress restarts it, playing the reversed motion the same number of times, continuing to alternate if `alternate` was set.
- [ ] Test: an indefinitely repeating motion (`count` omitted) can still be reversed without error.
- [ ] Test: reversing an alternating repeat produces the same visible pattern as reversing a non-alternating one, applied to the reversed child.

#### Not this story
- A separate "loop direction mode" beyond `alternate` — v1's `loop_in_circle` maps directly onto `alternate`, per `tech-spec.md`.
- Per-iteration delay or speed changes beyond the existing `delay_between` field.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_motion.gd`; `addons/anima/motion/resources/anima_repeat.gd`; `addons/anima/motion/runtime/anima_repeat_instance.gd`; `tests/AnimaMotion.test.gd`; `tests/AnimaRepeat.test.gd`; `tests/Anima.integration.repeat.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Target-bound authoring contract` (repeat paragraph); `§Convenience method interface`; `§Key technical decisions` (repeat reversal rule); `§Data model` (`AnimaRepeat` row)
- **Rules:** `_mano_output/project-rules.md §Naming`; `§Documentation`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
