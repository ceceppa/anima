### STORY-8h: AnimaParallel respects each child's own delay

#### What and why
A developer who calls `.with_delay(N)` on a motion *before* combining it into a `.with(...)` group currently sees the delay silently do nothing — `AnimaParallel` never consulted a child's `delay` field at all, so every child always started together regardless of what delay was authored on it. Making `AnimaParallel` honor per-child delay (as an offset from the group's own start) lets a developer stagger motions within a `.with()` group the same way they'd expect from having set `.with_delay()` on each one.

#### Done when
- [ ] In a `.with(a, b)` group where `b` has `.with_delay(N)` set and `a` doesn't, `a` starts immediately when the group starts and `b` starts `N` seconds later
- [ ] Two children with different delays inside the same group each start at their own offset from the group's start, not relative to each other
- [ ] A child with no delay (or `delay <= 0.0`, the default) still starts immediately, exactly as before this story
- [ ] Combined with an existing `.then(...)` step whose own delay is unset, a `.then(group_with_delayed_children)` step starts the instant the previous step ends, and each child inside it then stages from that same instant per its own delay — i.e. `.then(spiral.with_delay(3).with(overlay.with_delay(3.5)))` starts `spiral` 3s after the previous step and `overlay` 0.5s after `spiral`
- [ ] Test: `.complete()`/force-completing a parallel with a not-yet-started (still delayed) child still starts and completes that child before applying its forced end value

#### Not this story
- Any change to `AnimaSequence`'s own step-level delay scheduling — already correct
- Consulting `delay_basis` for a parallel child — a parallel has no "previous" child for `AFTER_PREVIOUS_STARTS`/`AFTER_PREVIOUS_ENDS` to mean anything; every child's delay is always relative to the group's own start

#### Notes
Discovered from a real authored chain (`_anima_grid().spiral_in().with_delay(3).with(Anima.on(%OverlayBg)...with_delay(3.5))`) that visibly didn't stagger as authored — the grid and overlay motions started together instead of 3s/3.5s after the previous step.

#### Implementation Reference
- **Build:** `AnimaParallelInstance` restructured around a per-child `_ChildState` (child, instance, started, finished) instead of parallel arrays. `_init()` starts any child with `delay <= 0.0` immediately (unchanged default case); `advance()` tracks its own elapsed clock and starts a not-yet-started child once elapsed reaches that child's own `delay`, firing its `on_started_callback` at that point (not before)
- **Files:** `addons/anima/motion/runtime/anima_parallel_instance.gd`
- **Contract:** `tech-spec.md` §Target-bound authoring contract, "Per-child delay inside `.with()` (phase-15)"
- **Rules:** `project-rules.md §Testing` — GUT unit tests on `AnimaParallel` exercising staggered starts, the zero-delay default, and `complete()`/`force_complete()` starting a still-delayed child; `project-rules.md §Documentation` — update the `##` doc comments on the touched methods

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
