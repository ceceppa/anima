### STORY-7b: Flat fill and border on playback buttons

#### What and why
Anyone using the shared restart/reverse playback controls sees each button's own fill switch from the gradient story-7a introduced to a flat colour with a visible border, so the button reads with clean definition — a gradient fill can't carry a border, which is why this changes.

#### Done when
- [ ] The Restart button's circular fill is a flat `accent` colour instead of the gradient — no gradient texture remains as the button's own fill.
- [ ] The Restart button shows a 2px `accent-soft` border around its circular edge.
- [ ] The Reverse button uses the identical flat-fill-plus-border treatment — neither button is styled as more prominent than the other.
- [ ] The soft glow behind each button is unchanged — same colour, opacity, and spread as before.
- [ ] Both buttons keep their existing 44px size and current icon glyphs (⟲ / ↶).
- [ ] Test: the button's applied style is a flat-colour `StyleBox` with a border, not a `StyleBoxTexture`/gradient.

#### Not this story
- Any change to the glow treatment behind the buttons.
- Replacing the placeholder glyphs with real icon artwork.
- Any new transport control (timeline, rank, speed, reduced-motion).

#### Notes
Reverses part of story-7a's own fill treatment (gradient → flat + border) per direct user request; the glow story-7a added stays as-is. Depends on: story-7a.

#### Implementation Reference
- **Files:** `examples/playground/shared/components/playback_controls.gd`; `examples/playground/shared/components/playback_controls.tscn`; `tests/PlaybackControls.test.gd`
- **Design:** `_mano_output/design-brief.md §Component guide` "Playback controls" — flat `accent` #7C3AED fill, 2px `accent-soft` #A78BFA border, icon colour `text-primary` (6.4:1 verified against `accent`)
- **Rules:** `_mano_output/project-rules.md §Example Scenes` — the glow stays built via `GradientTexture2D`/`FILL_RADIAL`, unchanged; `§Naming`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
