### STORY-7h: `Anima.grid()` accepts a grid size directly

#### What and why
Calling `Anima.grid(container)` no longer requires a separate `.with_dimensions(...)` call just to tell it the grid's shape — a size can be passed straight into `Anima.grid()` itself, or left out entirely so it's worked out automatically from the container (or a `GridContainer`-style node), matching how naturally a caller already thinks about "here's my container, here's its shape."

#### Done when

##### Explicit size
- [ ] `Anima.grid(container, Vector2i(9, 5))` sets the grid to exactly that shape, the same as chaining `.with_dimensions(Vector2i(9, 5))` afterward — including the existing centred-start-point behaviour that comes with setting dimensions.
- [ ] `Anima.grid(container, Vector2(9.0, 5.0))` (a plain `Vector2`, not `Vector2i`) also sets the grid to `Vector2i(9, 5)` — a fractional size like `Vector2(9.7, 5.2)` rounds down to `Vector2i(9, 5)`, never up past what actually fits.

##### Inferred size
- [ ] `Anima.grid(container)` with no size argument, where `container` exposes its own `rows` and `columns` values, resolves the grid to exactly those dimensions.
- [ ] `Anima.grid(container)` with no size argument, where `container` is a `GridContainer` (or exposes a `columns` value without a matching `rows` value), resolves rows from however many children `container` actually has, given that column count.
- [ ] `Anima.grid(container)` with no size argument, where `container` exposes neither of the above, resolves to a single column tall enough to fit every one of `container`'s children.
- [ ] `Anima.grid(container, someOtherNode)` — passing a *different* node as the size argument — infers rows/columns from that other node's own exposed values (per the same three-step fallback above), while still sizing the grid to fit `container`'s own children, not the other node's.

##### Invalid input
- [ ] Passing anything else as the size argument (a `String`, an `int`, etc.) does not stop the chain — the grid still ends up with an inferred size, the same as if no size argument had been given.

#### Not this story
- Any change to `AnimaGridMotion`'s own general-purpose constructor defaults for hand-built usage — unaffected.
- The distance-formula preset methods (`.radial()`, `.box()`, etc.) — separate story (`story-7i`).

#### Notes
- Both the explicit and inferred paths resolve through the exact same dimension-setting behaviour `.with_dimensions()` already has, including its centred-`start_point` auto-derivation and the "an explicit `.with_start_point()` always wins" rule from `story-7f` — this story does not introduce a second, differently-behaved way for a grid's dimensions to get set.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima.gd` (`.grid(container, grid_size: Variant = null)` — forwards `grid_size` to the factory); `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (`_init()` — accepts and resolves `grid_size`, routing the resolved `Vector2i` through the same path `.with_dimensions()` uses)
- **Contract:** `tech-spec.md` §Grid convenience shorthand — exact `typeof()`-based dispatch per accepted type (`Vector2i`, `Vector2`, `Node`, `null`, invalid), the three-step inference order, and "child count always read from `container`, never from a separately-passed inference node"
- **Do not:** change `AnimaGridMotion`'s own constructor defaults; do not give the inferred/explicit paths different `start_point`-derivation behaviour from each other

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
