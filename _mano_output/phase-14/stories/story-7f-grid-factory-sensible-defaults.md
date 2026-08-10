### STORY-7f: Sensible defaults for `Anima.grid()` — radiate from the middle

#### What and why
A developer calling `Anima.grid(container).with_dimensions(...)` gets a grid that radiates outward from the middle cell by default, instead of having to spell out `.with_distance_formula(EUCLIDEAN)` and `.with_start_point(...)` every time just to get the shorthand's own obvious common case.

#### Done when
- [ ] `Anima.grid(container).with_dimensions(...)` with no explicit distance formula radiates outward from a point (Euclidean) rather than sweeping row by row.
- [ ] `Anima.grid(container).with_dimensions(...)` with no explicit start point automatically starts from the middle of the grid.
- [ ] An odd-sized dimension (e.g. 5×5) still resolves to a single, sensible middle cell, not a fractional or rounded-up one.
- [ ] Explicitly calling `.with_start_point(...)` — whether before or after `.with_dimensions(...)` in the chain — always wins; the automatic middle is never applied over it.
- [ ] Hand-building an `AnimaGridMotion` directly (not through `Anima.grid()`) is completely unaffected — its own existing defaults stay exactly as they are.
- [ ] The generated API reference reflects the new defaults on `AnimaGridMotionFactory`'s constructor and `.with_dimensions()`.

#### Not this story
- Any change to `AnimaGridMotion`'s own general-purpose constructor defaults — those stay as they are for hand-built usage.
- `AnimaGroupDistribution.stagger_interval` — it already defaults to `0.05` on the resource itself; nothing to change there.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`_init()` — also set `motion.distance_formula = AnimaGridMotion.DistanceFormula.EUCLIDEAN`; new private `_start_point_explicit: bool = false` field; `with_dimensions(value)` — after setting `grid_dimensions`, auto-derive `start_point = Vector2i(floori(value.x / 2.0), floori(value.y / 2.0))` unless `_start_point_explicit` is already `true`; `with_start_point(value)` — set `start_point` and also set `_start_point_explicit = true`)
- **Contract:** `tech-spec.md` §Grid convenience shorthand — exact centring formula, the explicit-flag (not chain-order) tracking rule, and the factory-vs-resource default distinction
- **Tests:** `tests/AnimaGridMotionFactory.test.gd` (extend — constructor defaults to `EUCLIDEAN`; `.with_dimensions()` auto-derives the centre; an odd dimension floors correctly; an explicit `.with_start_point()` wins whether called before or after `.with_dimensions()`)
- **Do not:** change `AnimaGridMotion`'s own constructor defaults

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
