### STORY-8g: Child on_started/on_completed fire inside .then()/.with() composites

#### What and why
A developer setting `.on_started()`/`.on_completed()` on a motion — including an `Anima.grid(...)` chain — *before* combining it into a `.then()`/`.with()` composite (e.g. `Anima.grid(a).radial().on_started(cb).with(Anima.grid(b).diagonal().on_started(cb2))`) currently sees neither callback ever fire, since only the composite's own top-level callback is invoked by `AnimaPlayback`. Firing each child's own callback as it starts/finishes lets a developer configure feedback per-motion before composing, matching how every other per-motion setting (delay, ease, target) already survives composition.

#### Done when
- [ ] In a `.then(...)` chain, each step's own `on_started` fires the instant that step actually starts (not before), and its own `on_completed` fires the instant that step finishes — each exactly once
- [ ] In a `.with(...)` group, every child's own `on_started` fires immediately when the group starts (all children start together), and each child's own `on_completed` fires the instant that specific child finishes — each exactly once, independently of its siblings
- [ ] `Anima.grid(a).radial().on_started(cb).with(Anima.grid(b).diagonal().on_started(cb2)).play()` fires both `cb` and `cb2`
- [ ] Setting `.on_started()`/`.on_completed()` on the composite itself (after `.then()`/`.with()`, not on an individual child) still fires exactly as before this story — unaffected
- [ ] Test: `.complete()`/force-completing a playback still fires each not-yet-finished child's own `on_completed` exactly once, and each not-yet-started sequence child's own `on_started` once, before its forced end value is applied

#### Not this story
- Firing callbacks for `AnimaRepeat`'s own child on each iteration — out of scope, not reported
- Any change to the root motion's own `on_started_callback`/`on_completed_callback` handling in `AnimaPlayback`

#### Notes
None.

#### Implementation Reference
- **Build:** `AnimaParallelInstance._init()` fires each enabled child's `on_started_callback` immediately (all children start together); `AnimaParallelInstance.advance()`/`force_complete()` fire each child's `on_completed_callback` the instant that child individually finishes, tracked per-index so it never double-fires. `AnimaSequenceInstance.advance()` fires a child's `on_started_callback` the moment `state.started` flips true (its scheduled start arrives) and `on_completed_callback` the moment `state.instance.advance()` first reports finished; `force_complete()` mirrors both for any not-yet-started/not-yet-finished child.
- **Files:** `addons/anima/motion/runtime/anima_parallel_instance.gd`; `addons/anima/motion/runtime/anima_sequence_instance.gd`
- **Contract:** `tech-spec.md` §Target-bound authoring contract, "Child callbacks inside a composite (phase-15)" — exact firing rules and the "independent of the root's own callbacks" guarantee
- **Rules:** `project-rules.md §Testing` — GUT unit tests on `AnimaSequence`/`AnimaParallel` (via their runtime instances) exercising the exact scenarios above; `project-rules.md §Documentation` — update the `##` doc comments on the touched methods

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
