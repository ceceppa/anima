### story-1c: Card artwork on the Sprite2D slot, dual playback in Both mode

#### What and why
Two rough edges in the split-view stage from story-1b: the `Sprite2D` slot shows a flat placeholder colour instead of real artwork, and picking `Both` only actually animates whichever target the current preset is compatible with — the other one just sits idle. This story fixes both, so `Both` mode is a genuine side-by-side comparison of the same motion.

#### Done when
- [ ] The `Sprite2D` slot's artwork visually matches the `Card` component's own artwork treatment (the same source image/atlas), not a flat generated placeholder colour.
- [ ] With `Both` selected, choosing any preset plays it simultaneously on the Control label and the `Sprite2D` slot — not just on whichever target that preset happens to be compatible with.
- [ ] With `Control` or `Sprite2D` selected (not `Both`), only the visible target's own copy of the animation plays — matching story-1b's existing single-target behaviour.

#### Not this story
- No change to which 4 presets are the `lightspeed` ones, or to the underlying reason they need a `Sprite2D`-family target (Control has no writable `transform` for their skew).
- No new playback control.

#### Notes
Investigated the flagged technical question directly: `Control.size` reads resolve to `null` on a plain `Sprite2D` (confirmed empirically — `get_indexed` returns `null` for an undefined property rather than erroring), which then breaks `AnimaValue` arithmetic once a size-dependent preset's secondary copy plays there. Writing an undefined property (e.g. `transform:x:y` on `Control`) turned out to be a silent no-op, not a hard error — only the read side needed a fix. Resolved with a small scene-local `AnimationCatalogSprite` subclass (`extends Sprite2D`) exposing a synthetic, read-only `size` property (from its own texture size), so `AnimaValue.target(^"size:x")` resolves correctly there too — no core runtime change, no per-preset filtering.

#### Implementation Reference
- **Assets:** `Card`'s artwork source is `res://examples/playground/images/cards.jpg`, an `AtlasTexture`-based region pick (`Card.atlas_index`, `project-rules.md` §Example Scenes "Card atlas"). The `Sprite2D` slot uses the same atlas/region via an `AtlasTexture`, not the runtime-generated flat placeholder the scene shipped with before this story.
- **Build:** `examples/playground/animation_catalog_sprite.gd` (`class_name AnimationCatalogSprite extends Sprite2D`) — synthetic read-only `size` property so cross-target preset reads resolve. Dual playback in `Both` mode uses a second `AnimaPlayback` (`_secondary_playback`) alongside the existing `_active_playback`; `restart()`, `reverse()`, and the `PlaybackControls` signal handlers in `animation_catalog_playground.gd` now address both when present via a shared `_for_each_playback()` helper.
- **Do not:** don't change `SPRITE2D_PRESETS`/`preset_name_uses_sprite()`'s meaning — it still names which target a preset is *authored* for (the "primary" copy); `Both` mode's secondary copy is additive, not a replacement for that routing.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
