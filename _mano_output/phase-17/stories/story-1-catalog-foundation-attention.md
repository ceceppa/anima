### story-1: Catalog foundation + attention presets

#### What and why
An Anima 2 user picking an animation off the shelf — rather than hand-authoring one — can call `Anima.animation("tada")` (or drag the matching `.tres`) and get a working motion immediately. This story stands up the catalog mechanism itself and proves it end-to-end with the 12 attention-seeker presets (`bounce`, `flash`, `headshake`, `heartbeat`, `jello`, `pulse`, `rubber_band`, `shake_x`, `shake_y`, `swing`, `tada`, `wobble`) — short, in-place motions that draw the eye without moving the target on or off screen, matching Anima v1's own attention-seeker set.

#### Done when
- [ ] `Anima.animation(name: String)` is callable and returns a motion for any name registered this story; an unregistered name reports an error and returns nothing playable.
- [ ] The same preset reached two ways — calling `Anima.animation(name)` and playing the matching `.tres` asset directly — produces the identical animation.
- [ ] Each of the following presets, played on a target, reproduces its v1 attention-seeker behaviour end to end:
  - `bounce`: the target bounces vertically in place and returns to its resting position.
  - `flash`: the target's visibility flickers (fades out and back in) more than once, ending fully visible.
  - `headshake`: the target shifts side to side with a slight tilt, ending back at its resting position and rotation.
  - `heartbeat`: the target pulses larger twice in quick succession, like two heartbeats, ending at its normal size.
  - `jello`: the target wobbles with a skewing rotation that settles back to upright.
  - `pulse`: the target grows slightly larger once and returns to its normal size.
  - `rubber_band`: the target stretches wider then narrower before settling back to its normal shape.
  - `shake_x`: the target shakes repeatedly along the horizontal axis and returns to its resting position.
  - `shake_y`: the target shakes repeatedly along the vertical axis and returns to its resting position.
  - `swing`: the target rotates back and forth from a fixed point like a swinging pendulum, ending upright.
  - `tada`: the target grows slightly, rocks side to side with a small rotation, and settles at normal size and rotation.
  - `wobble`: the target shifts side to side with a rotation, offset by both its own and its parent's width, and settles back at rest — this preset's motion depends on the live target/parent size, not a fixed literal.
- [ ] Every one of the 12 presets above lives under its category folder and is loadable and playable — none are missing.

#### Not this story
- No entrance/exit presets (fading, sliding, zooming, rotating, bouncing, back, lightspeed, specials, text) — later stories in this phase.
- No preset browser, search, tags, or favourites UI.
- No motion themes or per-preset triage/audit.

#### Notes
This story owns the shared mechanism (registry, folder scaffold) every later batch story in this phase depends on — later stories add presets to the same mechanism, they don't rebuild it.

#### Implementation Reference
- **Build:** `Anima.animation(name) -> AnimaMotion` static facade method; lazy-load-and-cache-by-name registry — `tech-spec.md` §Animation catalog (exact signature, caching contract, canonical mapping).
- **Files:** category folder scaffold `addons/anima/presets/{attention,entrance,exit,special,text}/` — `project-rules.md` §Animation Catalog (folder/naming convention: filename = registry name).
- **Data:** each preset is an `AnimaKeyframeMotion` built via `Motion.keyframes(initial)` — `tech-spec.md` §Keyframe motions, §Keyframe interface. Behavioural reference: `addons/anima/animations/attention_seeker/*.gd` in the v1 project (percentage-offset `KEYFRAMES` dict format already maps onto `Motion.keyframes()` per `tech-spec.md` §Animation catalog).
- **Dynamic values:** `wobble`'s size-dependent offset translates through `AnimaValue.*` per `tech-spec.md` §Animation catalog / §Dynamic values — no string-formula parser.
- **Rules:** `project-rules.md` §Animation Catalog — canonical `AnimaValue` mapping convention (apply consistently if the same v1 idiom recurs in later batches); one resolved-value unit test per preset, not just a load check.
- **Documentation:** `Anima.animation()` is a new public method — give it a full `##` doc comment per `project-rules.md` §Documentation (author-visible outcome, what `name` means, failure behaviour for an unknown name).
- **Do not:** no `AnimaMotion` field or subtype changes — every preset is built from the existing `AnimaKeyframeMotion`/`AnimaPropertyMotion`/`AnimaValue` types.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
