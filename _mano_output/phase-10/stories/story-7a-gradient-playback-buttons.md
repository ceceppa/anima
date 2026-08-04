### STORY-7a: Gradient and glow on playback buttons

#### What and why
Anyone using the shared restart/reverse playback controls across every example scene sees a more polished, elevated look — a violet radial gradient fill and matching glow on each button — replacing today's flat, unstyled default buttons, following the transport-bar language `v2_stuff/ex2.jpg` establishes.

#### Done when
- [ ] The Restart button's circular fill shows a radial gradient from a lighter violet centre to a deeper violet edge, with a soft matching glow extending beyond its edge.
- [ ] The Reverse button uses the identical gradient and glow treatment — neither button is styled as more prominent than the other.
- [ ] Both buttons keep their existing 44px size and current icon glyphs (⟲ / ↶); no new controls (timeline, rank, speed, reduced-motion) are added.
- [ ] The icon glyph's colour still meets the 6.4:1 contrast ratio already verified against the gradient's darkest point, in every playground scene that uses these controls.
- [ ] Test: the button's applied texture is a radial-fill gradient using the two colours `design-brief.md` specifies, not a flat colour or a different fill mode.

#### Not this story
- Replacing the placeholder ⟲/↶ glyphs with real icon artwork — deferred until icon graphics are supplied (see `design-brief.md §Component guide`).
- Any new transport control (skip, speed, scrubber, reduced-motion) — explicitly out of scope per `design-brief.md`.
- Giving one button (e.g. restart) a visually different or more-primary treatment than the other.

#### Notes
This story sits outside Phase 10's own Phase Goal (the `Anima.on()` API) — added as an explicit user-requested exception; it does not contribute to Phase 10's phase-goal coverage.

#### Implementation Reference
- **Files:** `examples/playground/shared/components/playback_controls.gd`; `examples/playground/shared/components/playback_controls.tscn`; `tests/PlaybackControls.test.gd`
- **Design:** `_mano_output/design-brief.md §Component guide` "Playback controls" — exact colours (`accent-soft` #A78BFA centre, `accent` #7C3AED edge), glow (`accent` at 24% opacity, ~8px spread), icon colour (`text-primary`, 6.4:1 verified against `accent`)
- **Rules:** `_mano_output/project-rules.md §Example Scenes` — build the gradient via `GradientTexture2D` with `fill = GradientTexture2D.FILL_RADIAL`, the same technique `_style_glow()` already uses; `§Naming`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
