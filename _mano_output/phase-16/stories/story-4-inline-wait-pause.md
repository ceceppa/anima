### STORY-4: Inline pauses between chained steps with .wait()

#### What and why
Instead of setting the same delay on every sibling one at a time, an author can call `.wait(seconds)` mid-chain to push back the start of whatever gets combined next via `.then()`/`.with()` — including through `Anima.grid()`/`Anima.group()` factory chains, not just plain `Anima.on()` motions.

#### Done when
- [ ] `Anima.on(a).move_by(...).wait(1.0).then(Anima.on(b).fade_in())` starts `b`'s motion 1 second later than it would without the `.wait(1.0)` call, without changing when `a`'s own motion starts
- [ ] The same chain, but the next step already has its own `.with_delay(0.5)`, starts that step 1.5 seconds later — the two delays add, neither replaces the other
- [ ] Calling `.wait(seconds)` between two factory calls being chained together (e.g. `Anima.grid(a).radial().wait(1.0).with(Anima.grid(b).diagonal())`, and the equivalent with `Anima.group(...)`) delays the second one's start the same way
- [ ] Test: ending a chain, or calling `.play()`, without ever consuming a pending `.wait()` call does not error and does not affect anything else in the chain

#### Not this story
- Delaying an entire already-composed chain in one call — separate story (whole-chain delay)
- Any change to `AnimaGroupMotion`/`AnimaGridMotion`'s own stagger/distribution timing

#### Notes
Depends on: story-1 (`AnimaGroupMotionFactory` must exist for the group-factory delegation AC). Additive-delay example relies on the existing per-leaf `.with_delay()` (phase-15), not on story-3's base-class promotion.

#### Implementation Reference
- **Build:** `.wait(seconds: float) -> AnimaMotion` per `tech-spec.md` §Key technical decisions (the `.wait()` bullet) — sets a transient `_pending_chain_wait`, consumed and added to the next `.then()`/`.with()` target's `delay`; `AnimaGridMotionFactory.wait()`/`AnimaGroupMotionFactory.wait()` delegate to the internal motion per the same section
- **Files:** `addons/anima/motion/resources/anima_motion.gd`; `addons/anima/motion/runtime/anima_grid_motion_factory.gd`; `addons/anima/motion/runtime/anima_group_motion_factory.gd`; `tests/AnimaMotion.test.gd`; `tests/Anima.integration.convenience-composition.test.gd`
- **Rules:** `project-rules.md` §Testing; §Documentation (doc comments on the three new `.wait()` methods)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
