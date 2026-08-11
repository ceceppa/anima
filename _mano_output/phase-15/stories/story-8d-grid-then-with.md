### STORY-8d: Anima.grid() supports .then()/.with()

#### What and why
A developer combining a grid motion with another `Anima.on()`/`Anima.grid()` motion currently has no way to do it through `Anima.grid(...)`'s own chain — only the underlying `.motion` escape hatch reaches `.then()`/`.with()`. Adding them directly to the factory lets a grid motion compose into a sequence or parallel group the same fluent way any `Anima.on()` motion already can, including calling `.play()` at the end of the combined chain.

#### Done when
- [ ] `Anima.grid(container).radial().then(Anima.on(other_node).fade_out(0.3)).play()` plays the grid motion, then fades `other_node`, each against its own correct target
- [ ] `Anima.grid(container).radial().with(Anima.on(other_node).move_by(...))` plays the grid motion and the other motion together, each against its own correct target
- [ ] A grid motion built through `Anima.grid(...)` alone (no `.then()`/`.with()`) still plays via the factory's own `.play()` exactly as before this story
- [ ] Test: `.then()`/`.with()` called on the factory before any `item_motion` is set does not error immediately; the resulting composite's own eventual `.play()` (once an item motion exists) still surfaces the existing "no item_motion" error if one still doesn't

#### Not this story
- Adding an `Anima.group()` convenience factory — tracked separately in the backlog, not decided or built here
- Any change to `Anima.item()` or per-group-item target resolution

#### Notes
None.

#### Implementation Reference
- **Build:** `AnimaGridMotionFactory._init()` sets `motion.convenience_target = container`; add `.then(other: AnimaMotion) -> AnimaMotion` and `.with(other: AnimaMotion) -> AnimaMotion`, each delegating to `motion.then(other)` / `motion.with(other)` and returning the resulting composite (not the factory)
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd`
- **Contract:** `tech-spec.md` §Grid convenience shorthand, "`.then()`/`.with()` (phase-15)" — exact delegation and target-propagation behaviour
- **Rules:** `project-rules.md §Testing` — GUT unit test on `AnimaGridMotionFactory`; extend an existing grid integration test (or add one) exercising the combined-chain `.play()` scenario above; `project-rules.md §Documentation` — add the `##` doc comments for the two new methods

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
