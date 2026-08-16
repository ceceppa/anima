### story-3: Fading-exit presets

#### What and why
The exit-side counterpart to story-2: a user dismissing an element reaches for a named fade-out preset. This story ports v1's 13 fading-exit presets, including the size-dependent formula (`fade_out_left_big`'s translate offset reading both the target's own size and its parent's) that is this phase's worked example for translating v1's dynamic-value strings.

#### Done when
- [ ] Each of the following presets, played on a target, reproduces its v1 behaviour end to end — starting fully opaque at the target's resting position, ending fully transparent at the named offset:
  - `fade_out`: fades out from fully opaque to fully transparent with no positional change.
  - `fade_out_left` / `fade_out_left_big`: fades out while moving to an offset left of its resting position (the `_big` variant's ending offset also depends on the parent's own width, producing a larger offset than the plain variant).
  - `fade_out_right` / `fade_out_right_big`: same as above, offset to the right.
  - `fade_out_up` / `fade_out_up_big`: same as above, offset above (upward).
  - `fade_out_down` / `fade_out_down_big`: same as above, offset below (downward).
  - `fade_out_top_left` / `fade_out_top_right` / `fade_out_bottom_left` / `fade_out_bottom_right`: fades out while moving diagonally to the named offset.
- [ ] `fade_out_left_big`'s resolved ending offset changes when the parent's own size changes, with the target's own size held constant — proving its offset is computed live from both, not a fixed literal.
- [ ] All 13 presets above are loadable and playable by name and by asset — none are missing.

#### Not this story
- Fading entrances — story-2 (already shipped).
- Any other style group.

#### Notes
Depends on story-1. `fade_out_left_big` is this phase's reference case for the dynamic-formula translation convention (`project-rules.md` §Animation Catalog) — get this one right first; every other `_big`/directional preset across the remaining batches reuses the same mapping shape.

#### Implementation Reference
- **Build:** each preset an `AnimaKeyframeMotion` via `Motion.keyframes(initial)` — `tech-spec.md` §Keyframe motions.
- **Files:** `addons/anima/presets/fading_exits/` — `project-rules.md` §Animation Catalog.
- **Data:** behavioural reference `addons/anima/animations/fading_exits/*.gd` in the v1 project.
- **Dynamic values:** `fade_out_left_big`'s exact translation is worked in `tech-spec.md` §Animation catalog (`AnimaValue.target(^"size:x").negative().subtract(AnimaValue.node(^"..", ^"size:x"))`); apply the equivalent shape (mirrored per axis/direction) to every other `_big`/directional preset in this batch.
- **Rules:** one resolved-value unit test per preset, and for `fade_out_left_big` specifically a test that varies the parent's size and asserts the resolved offset changes accordingly — `project-rules.md` §Animation Catalog.
- **Do not:** no new `AnimaMotion` subtype or field.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
