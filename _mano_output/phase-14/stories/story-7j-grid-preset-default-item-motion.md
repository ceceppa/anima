### STORY-7j: Distance-formula presets default to a playable motion

#### What and why
Calling a shape preset like `Anima.grid(%Grid, Vector2i(9, 5)).diagonal().play()` now works as a true one-liner — no more "requires with_item_motion()" error — because the preset itself supplies a sensible fade-and-pulse motion when nothing else has been configured, while anyone who's already set up their own item motion keeps exactly what they authored.

#### Done when
- [ ] Calling any one of the 13 distance-formula preset methods (`.radial()`, `.diamond()`, `.box()`, `.by_row()`, `.by_column()`, `.diagonal()`, `.anti_diagonal()`, `.clockwise()`, `.counter_clockwise()`, `.spiral_in()`, `.spiral_out()`, `.serpentine_row()`, `.serpentine_column()`) with nothing else configured, then `.play()`, produces a running playback instead of the "requires with_item_motion()" error.
- [ ] The motion a preset supplies by default fades each item in from invisible while its scale dips and then pulses past its own resting scale, easing in and out, over three tenths of a second.
- [ ] Configuring an item motion (`.with_item_motion(...)` or `.keyframes(...)`) *before* calling a preset method leaves that configuration exactly as authored — the preset does not replace it.
- [ ] Calling `Anima.grid(container)` with no preset method used, or using `.with_distance_formula(...)` directly instead of a named preset, still requires an explicit item motion — `.play()` still reports the existing error when none was ever set.

#### Not this story
- Any change to `AnimaKeyframeMotion.default_ease`'s own general default, or to `AnimaGridMotion`'s hand-built constructor defaults — both stay exactly as they are.
- Any change to `.with_distance_formula()` itself, or to construction-time (`_init()`) defaults — this story only touches the 13 named preset methods.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_grid_motion_factory.gd` (each of the 13 preset methods — before calling `.with_distance_formula(...)`, apply the default item motion if `motion.item_motion` is still `null`)
- **Contract:** `tech-spec.md` §Grid convenience shorthand, "Default `item_motion` — preset methods only" — exact `DEFAULT_ITEM_MOTION`/`DEFAULT_DURATION`/`DEFAULT_EASE` constant values and the `item_motion == null` guard condition
- **Do not:** apply the default from `_init()` unconditionally; apply the default when `.with_distance_formula()` is called directly instead of a named preset

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
