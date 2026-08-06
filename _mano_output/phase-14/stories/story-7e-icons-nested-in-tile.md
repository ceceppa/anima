### STORY-7e: Icons nested under their own tile, centered

#### What and why
A developer watching the RPG showcase sees each inventory icon sitting directly inside its own tile frame, centered, instead of positioned as a separate sibling layer — a simpler structure the user found reads better visually than the current independent icon layer.

#### Done when
- [ ] Each icon is a child of its own tile (not a sibling under a separate icon layer), positioned at the tile's own centre.
- [ ] Each icon's size is still capped at `max_icon_ratio` (80% by default) of its own tile's size, preserving its own aspect ratio — unchanged from today.
- [ ] Playing the showcase still reveals every icon (fade in) and pulses its scale, the same beats as today, now targeting the icons in their new nested position.
- [ ] Adjusting `min_gap` or `max_icon_ratio` from the Inspector still rebuilds the whole grid live, with icons still correctly nested and centred after a rebuild.

#### Not this story
- Test coverage for this change — explicitly deferred at the user's request until the new layout is confirmed. This story is not complete until tests are added in a follow-up; "no tests" is a temporary state, not the final one.
- Any change to the pulse animation's own timing, easing, or per-icon scale math (the additive `+0.15` bump) — only where the icons live and how they're targeted changes, not what the animation itself does.

#### Notes
The current `%Icons` sibling layer exists specifically so `Anima.grid()`'s `CHILDREN`-based targeting has something uniform to resolve. With icons nested under their own tile instead, `play()` needs to target the already-tracked `_icon_nodes` array directly (`AnimaTargetCollection.Kind.EXPLICIT`, overriding `Anima.grid()`'s own `CHILDREN` default via its exposed `.motion` property) instead of resolving `%Icons`'s children — the same override pattern `examples/playground/grid_motion_playground.gd` already uses for its own tap-to-select card collection. `%Icons` becomes unused once this lands and should be removed, along with the class-level doc comment explaining why it existed as a separate layer.

#### Implementation Reference
- **Files:** `examples/showcase/grid/inventory_grid.gd` (`_build_icon()` — parent the icon to its own `tile`, position at `Vector2.ZERO` relative to it instead of the tracked `center`; `play()` — target `_icon_nodes` via an `EXPLICIT` collection instead of relying on `Anima.grid()`'s `CHILDREN` default; remove the `_icons`/`%Icons` reference and its now-stale doc comments); `examples/showcase/grid/inventory_grid.tscn` (remove the now-unused `%Icons` node)
- **Contract:** `tech-spec.md` §Grid convenience shorthand — the `.motion` getter is the documented override escape hatch for exactly this kind of case
- **Do not:** touch the pulse animation's own keyframe values, duration, or easing
- **Tests:** none this story — see Not this story

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
