### STORY-7i: Named presets for every grid distance formula

#### What and why
Starting a grid animation with a particular spread pattern — radiating outward, sweeping row by row, spiralling in — no longer requires knowing `AnimaGridMotion.DistanceFormula`'s exact enum member name: `Anima.grid(container).radial().play()` reads the same way the pattern is already described in conversation, one dedicated method per pattern.

#### Done when
- [ ] Every `AnimaGridMotion.DistanceFormula` value has exactly one matching preset method on the grid factory (`.radial()`, `.diamond()`, `.box()`, `.by_row()`, `.by_column()`, `.diagonal()`, `.anti_diagonal()`, `.clockwise()`, `.counter_clockwise()`, `.spiral_in()`, `.spiral_out()`, `.serpentine_row()`, `.serpentine_column()`).
- [ ] Calling a preset method produces a grid motion that plays identically to calling `.with_distance_formula(...)` directly with the matching formula.
- [ ] A preset method stays chainable — `.play()`, `.with_dimensions(...)`, `.with_start_point(...)`, and every other existing chain method all still work after calling one.
- [ ] Test: every preset method name from `tech-spec.md`'s preset table exists and sets the expected `DistanceFormula` on the underlying motion.

#### Not this story
- The `grid_size` constructor parameter — separate story (`story-7h`).
- Any new distance formula, or any change to an existing formula's own rank/traversal semantics (`tech-spec.md` §Grid motion contract) — this story only names existing formulas, it does not add or change one.
- Method aliases — one name per formula, no second synonym method (`tech-spec.md` §Grid convenience shorthand, "one name per formula, no aliases").

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (add the 13 preset methods; each is a one-line call into the factory's own existing `.with_distance_formula(...)`)
- **Contract:** `tech-spec.md` §Grid convenience shorthand — exact preset-to-formula naming table, and "pure sugar for `.with_distance_formula()`, no independent state"
- **Do not:** add a second name for any formula; add a preset method for a formula that doesn't exist in `AnimaGridMotion.DistanceFormula`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
