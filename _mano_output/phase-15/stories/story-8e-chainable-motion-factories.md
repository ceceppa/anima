### STORY-8e: .then()/.with() accept any motion factory, not just AnimaMotion

#### What and why
A developer combining two `Anima.grid(...)` chains — or an `Anima.on()` chain with a grid chain — previously had to reach into `.motion`/`.play()` manually before `.then()`/`.with()` would accept the other side, since those methods only accepted an already-built `AnimaMotion`. Widening them to accept any convenience factory directly (anything exposing a `motion: AnimaMotion` property) lets `Anima.grid(a).radial().with(Anima.grid(b).diagonal())` compile and play with no manual unwrapping — and establishes the contract any future factory (a later `Anima.group()` included) can rely on for the same ergonomics.

#### Done when
- [ ] `Anima.grid(a).radial().with(Anima.grid(b).diagonal()).play()` plays both grids, each against its own captured target
- [ ] `Anima.on(node).move_by(...).with(Anima.grid(container).radial())` still works the same way, on the `AnimaMotion` side accepting a grid factory as `other`
- [ ] `Anima.grid(container).radial().then(Anima.on(other_node).fade_out(0.3))` — the existing story-8d scenario — still works unchanged
- [ ] Test: passing an unsupported type (not an `AnimaMotion`, not an object with a `motion` property) to `.then()`/`.with()` reports an error and returns the original motion unchanged, without crashing on any input type (including a `String`, `Array`, or other non-`Object` `Variant`)

#### Not this story
- Adding an `Anima.group()` convenience factory — still tracked separately in the backlog
- Propagating `on_started`/`on_completed` callbacks set on an individual child motion through `.then()`/`.with()` composition — a separate, newly-discovered gap (see the backlog item this story adds)

#### Notes
Discovered while verifying this story: a callback set via `.on_started(...)`/`.on_completed(...)` on a motion *before* combining it into a `.then()`/`.with()` composite is never invoked — only the composite's own `on_started_callback`/`on_completed_callback` (set directly on the composite itself) fires, since `AnimaPlayback` only calls back on the root motion. This is pre-existing behaviour, not something this story's change caused, but it's easy to trip over now that combining separately-configured factories is a supported pattern — added to the backlog as a bug, not fixed here.

#### Implementation Reference
- **Build:** `AnimaMotion._resolve_chainable(value: Variant, caller: String) -> AnimaMotion` — returns `value` when it's already an `AnimaMotion`; when `value is Object and "motion" in value and value.motion is AnimaMotion`, returns `value.motion`; otherwise reports an error naming `caller` and `value`'s type and returns `null`. `.then(other: Variant)`/`.with(other: Variant)` resolve `other` through this first; on `null` (unresolvable), `.then()` returns a sequence of `self`'s own existing steps unchanged, `.with()` returns `self` unchanged — no crash, no broken composite either way
- **Files:** `addons/anima/motion/resources/anima_motion.gd` (`_resolve_chainable`, `.then()`, `.with()`); `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`.then()`/`.with()` parameter type widened to `Variant`, unchanged delegation)
- **Contract:** `tech-spec.md` §Target-bound authoring contract, "Chaining a motion factory directly (phase-15)" — exact resolution rule and the `motion: AnimaMotion` property convention every factory must follow
- **Rules:** `project-rules.md §Testing` — GUT unit tests on `AnimaMotion`/`AnimaGridMotionFactory` for factory-to-factory chaining and the unsupported-type error path; `project-rules.md §Documentation` — update the `##` doc comments for `.then()`/`.with()` to describe the widened `other` type

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
