### story-9: Lightspeed, special, and text presets

#### What and why
The remaining 9 v1 presets that don't fit the fade/slide/zoom/rotate/bounce/back families: a fast skewed slide (`lightspeed`), four one-off signature motions (`specials`), and a typing reveal (`text`). This story ports them and, being the last story in the phase, confirms the whole 99-preset catalog is in place and reachable both ways.

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 behaviour end to end:
  - `light_speed_in_left` / `light_speed_in_right`: starts transparent, offset in the named direction, and visibly skewed; ends fully opaque, at its resting position, and unskewed. Targets `Sprite2D` (see Notes).
  - `light_speed_out_left` / `light_speed_out_right`: starts fully opaque, at rest, and unskewed; ends transparent, offset in the named direction, and visibly skewed. Targets `Sprite2D`.
  - `hinge`: rotates around its top-left corner in stages, then drops downward while fading out, ending well below its resting position and fully transparent.
  - `jack_in_the_box`: starts transparent, at a reduced scale, and rotated, rocks through a couple of small rotation corrections, and ends fully opaque, at normal scale, and upright.
  - `roll_in`: starts transparent, offset to the left by its own size, and rotated; ends fully opaque, at rest, and unrotated.
  - `roll_out`: starts fully opaque, at rest, and unrotated; ends transparent, offset to the right by its own size, and rotated.
  - `typewrite`: starts with none of its text visible and ends with all of it visible, revealing progressively over its playback — its duration is an explicit, fixed value like every other preset in this catalog, not automatically scaled by the text's length.
- [ ] All 9 presets above are loadable and playable by name and by asset — none are missing.
- [ ] **Full-catalog check:** across the whole phase, every one of the 99 v1 source animations (`addons/anima/animations/**/*.gd` in the v1 project) has a corresponding ported preset in this catalog, and each of the five categories (attention, entrance, exit, special, text) contains at least one preset.
- [ ] **Access-path check:** for at least one preset from each of story-1 through story-9, `Anima.animation(name)` and playing that preset's `.tres` directly produce the identical animation — confirming the by-name and by-asset paths stay consistent across the whole catalog, not just the first preset added in story-1.

#### Not this story
- No preset browser, search, tags, or favourites UI.
- No motion themes or per-preset triage/audit.
- No content-length-aware duration scaling for `typewrite` (deferred — see `tech-spec.md` §Animation catalog).

#### Notes
`light_speed_in_*`/`light_speed_out_*` target `Sprite2D` (a `Node2D`, which has a writable `transform` for the skew) and use a fixed literal pixel offset rather than a size-dependent one — `AnimaValue.custom()` (the only way to read a sprite's texture-derived size) does not survive `.tres` serialization, confirmed empirically; see `tech-spec.md` §Animation catalog.

This is the phase's closing story — its full-catalog and access-path checks are the exit-path verification for the phase's "full coverage" and "reachable two ways" Exit Criteria, not a repeat of each earlier story's own per-preset checks.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)` — `tech-spec.md` §Keyframe motions.
- **Files:** `addons/anima/presets/entrance/` (`light_speed_in_*`, `roll_in`), `addons/anima/presets/exit/` (`light_speed_out_*`, `roll_out`), `addons/anima/presets/special/` (`hinge`, `jack_in_the_box`), `addons/anima/presets/text/` (`typewrite`) — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/lightspeed/*.gd`, `addons/anima/animations/specials/*.gd`, `addons/anima/animations/text/typewrite.gd` in the v1 project.
- **Dynamic values:** `light_speed_*`'s skew writes to `transform:x:y` as a generic property path (no `skew` property exists natively) — `tech-spec.md` §Animation catalog. `roll_in`/`roll_out`'s size-dependent offset uses the canonical `AnimaValue` mapping convention — `project-rules.md` §Animation Catalog. `hinge`/`jack_in_the_box` set `default_pivot` (`TOP_LEFT` / `BOTTOM_CENTER`) — `tech-spec.md` §Keyframe motions ("Pivot").
- **Duration:** `typewrite`'s `duration` is supplied explicitly, per `tech-spec.md` §Animation catalog ("Duration is never a dynamic value") — do not attempt to scale it by the target's text length.
- **Rules:** one resolved-value unit test per preset — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field; no `skew` field added to any resource — `transform:x:y` is a plain generic property path, not a new named concept.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
