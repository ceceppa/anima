### story-1e: SelectorDock indicator animates via Anima, not Tween

#### What and why
`SelectorDock`'s sliding selection indicator — the shared chrome every category sidebar, animation grid, and target-mode dock in this playground uses — currently animates itself with Godot's built-in `Tween`, even though it lives inside an Anima example app whose whole purpose is showcasing Anima. This story switches the indicator to animate through `Anima.on()` instead, so the app that demonstrates Anima also uses Anima for its own motion, with no visible change to how the indicator behaves.

#### Done when
- [ ] Selecting an item in any `SelectorDock` (horizontal or vertical orientation) still animates the shared indicator from its previous rect to the newly selected item's rect, arriving with the same brief overshoot-and-settle motion feel it already has.
- [ ] Selecting a new item while the indicator is still mid-animation from a previous selection retargets smoothly toward the new item's rect, instead of jumping instantly or restarting from its very first position.
- [ ] The very first selection on a freshly populated dock still snaps the indicator directly into place with no animation, exactly as today.

#### Not this story
- No change to the indicator's timing or easing feel (`MOVE_DURATION`, the back-out overshoot) — same values, same visual result, only the animation mechanism underneath changes.
- No change to `_rect_for_index()`'s layout-reading logic, `clear_items()`'s reset behaviour, or the orientation-agnostic geometry (`project-rules.md` §Selector Orientation).
- No change to any other shared component (`Card`, `PlaybackControls`, `ExampleHeader`, `ToggleSwitch`) — scoped to `SelectorDock`'s indicator only.

#### Notes
User-directed dogfooding request: `SelectorDock` is the first `examples/playground/shared/` component to animate its own chrome through `Anima.on()` rather than the engine's raw `Tween`. If this should become a standing convention for every shared component, that's a `project-rules.md` addition via `mano rules` once this ships — not assumed here.

#### Implementation Reference
- **Build:** `_move_indicator_to()` replaces `create_tween()`/`tween_property()` with `Anima.on(self)` property motions targeting `_indicator_position` and `_indicator_size` (both plain script `var`s, readable/writable by `Anima.on()`'s generic `.property(path, to, duration)` the same as any other property — `tech-spec.md` §Convenience method interface). Leave `from` unset so each motion captures the indicator's actual current position/size at motion start (`.from_current()`'s default, `CURRENT_AT_MOTION_START` — `tech-spec.md` §Convenience method interface), matching the old Tween's own "animate from wherever it currently is" behaviour. Combine the two parallel property motions with `.with()` and `.play()` them together as one `AnimaPlayback`, matching the old `set_parallel(true)` pair.
- **Easing:** `AnimaEase.Kind.EASE_OUT_BACK` (`.with_ease(...)`) is the direct equivalent of the current `Tween.TRANS_BACK`/`Tween.EASE_OUT` pair — `tech-spec.md` §Easing curve library. `.with_duration(MOVE_DURATION)` keeps the existing constant.
- **Files:** `examples/playground/shared/components/selector_dock.gd` — replace the `Tween`-typed `_indicator_tween` field with an `AnimaPlayback`-typed one, so a mid-flight retarget calls `.cancel()` on it the same way the old code called `.kill()`.
- **Do not:** don't touch `MOVE_DURATION`'s value, the first-selection snap branch (`_indicator_size == Vector2.ZERO`), or any file outside `selector_dock.gd`.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
