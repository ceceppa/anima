### story-2: Fading-entrance presets

#### What and why
A user building an intro animation reaches for a named fade-in preset instead of hand-composing an opacity motion. This story ports v1's 14 fading-entrance presets so every one is reachable by name or asset and reproduces v1's fade-and-optional-slide-in behaviour, including the size-dependent starting offsets several of them use.

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 behaviour end to end — starting transparent, ending fully opaque at the target's resting position and offset:
  - `fade_in`: fades in from fully transparent to fully opaque with no positional change.
  - `fade_in_left` / `fade_in_left_big`: starts offset to the left of its resting position (the `_big` variant's starting offset also depends on the parent's own width, producing a larger starting offset than the plain variant) and fades/slides in to rest.
  - `fade_in_right` / `fade_in_right_big`: same as above, offset to the right.
  - `fade_in_up` / `fade_in_up_big`: same as above, offset above (upward).
  - `fade_in_down` / `fade_in_down_big`: same as above, offset below (downward).
  - `fade_in_top_left` / `fade_in_top_right` / `fade_in_bottom_left` / `fade_in_bottom_right`: starts offset diagonally in the named direction and fades/slides in to rest.
  - `fade_in_small`: v1's own source defines this identically to `fade_in_left` (an offset-left fade, not a scale change) — port it byte-for-byte as the same behaviour, not as its name might suggest.
- [ ] The `_big` variant of a directional preset (e.g. `fade_in_left_big` vs `fade_in_left`) starts from a visibly larger offset than its non-`big` counterpart.
- [ ] All 14 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Fading exits — story-3.
- Any other style group (bouncing, sliding, zooming, rotating, back, lightspeed, specials, text, attention).

#### Notes
Depends on story-1's registry mechanism and folder scaffold; this story only adds presets to the `entrance` category.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)` — `tech-spec.md` §Keyframe motions.
- **Files:** `addons/anima/presets/fading_entrances/` — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/fading_entrances/*.gd` in the v1 project.
- **Dynamic values:** every directional preset's starting offset (and the `_big` variants' parent-width/height-dependent offset) translates through `AnimaValue.*` per `tech-spec.md` §Animation catalog and the canonical mapping convention in `project-rules.md` §Animation Catalog — reuse the same `.target()`/`.node(^"..", ...)`/arithmetic shape for every preset sharing the same v1 formula idiom.
- **Rules:** one resolved-value unit test per preset — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
