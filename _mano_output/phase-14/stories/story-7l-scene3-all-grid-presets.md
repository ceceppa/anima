### STORY-7l: Scene 3 demos every grid distance-formula preset

#### What and why
Playing the showcase's Scene 3 now cycles through all 13 `Anima.grid()` distance-formula presets one after another, each one shown on screen as the exact one-line call that produced it — a complete visual catalogue of every shape the convenience API offers, not just the three examples currently sketched in.

#### Done when
- [ ] Playing the scene runs through all 13 distance-formula preset methods in sequence: the three already sketched (`diamond` with an explicit centre start point, `diagonal`, `spiral_in`), followed by `radial`, `box`, `by_row`, `by_column`, `anti_diagonal`, `clockwise`, `counter_clockwise`, `spiral_out`, `serpentine_row`, `serpentine_column`, in that order.
- [ ] Immediately before each example plays, the on-screen label shows the exact `Anima.grid(...)` one-liner that example demonstrates, in the same style as the existing three (`Anima.grid(%tile, Vector2i(8, 5)).diamond().with_start_point(Vector2.ZERO).play()` and so on) — with the existing `diamond` label's typo (`diamong`) and missing closing parenthesis corrected.
- [ ] Every example except the very last one (`serpentine_column`) finishes playing, pauses briefly, then resets the grid before the next example's label appears — the same three-step rhythm the existing `diamond`/`diagonal` examples already follow. `serpentine_column`, as the final example, ends the sequence without that trailing pause-and-reset.
- [ ] Only the `diamond` example passes an explicit start point (`Vector2.ZERO`); every other example plays with its preset's own default start point.
- [ ] While the third example (`spiral_in`) is playing, `%OverlayBg` simultaneously fades in to 70% opacity — starting alongside `spiral_in`'s own grid animation, not waiting for it to finish first and not delaying it.

#### Not this story
- Tests — explicitly not wanted for this story; the scene will be checked manually.
- Fading `%OverlayBg` back down after the third example — not requested; it stays at 70% opacity for the rest of the sequence.
- `_next_method()` (the existing unused stub in `scene_3.gd`) — unrelated leftover, out of scope here.
- `Anima.begin()`/`.with()`/`.then()` chaining — separate, already-backlogged item.

#### Notes
- ⚠ Verify: `%OverlayBg`'s fade-in duration wasn't specified — a reasonable default (e.g. matching the grid example's own animation length) is fine unless a specific value was intended.

#### Implementation Reference
- **Files:** `examples/showcase/grid/scene_3.gd` (`play()`) — reuse the existing `_anima_grid()`/`_reset_grid()`/`_wait_for_next()` helpers exactly as already defined; no changes needed to them
- **Contract:** each preset method already supplies its own default item motion when none is set (`tech-spec.md` §Grid convenience shorthand, "Default `item_motion` — preset methods only"), so no `.keyframes()`/`.with_item_motion()` call is needed anywhere in this story — every example is just `_anima_grid().<preset>().play()` (or `.with_start_point(...)` first, for `diamond` only)
- **Do not:** add test files for this story; change `_anima_grid()`'s own container/dimension wiring

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
