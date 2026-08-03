### STORY-2: Add motion pivot control

#### What and why
A developer scaling or rotating a `Control` or a `Sprite2D`-like node can choose which point the transform originates from — Anima v1's 9 anchor positions — instead of always the node's default origin.

#### Done when
- [ ] Setting `pivot` (via `.with_pivot(...)`) on a scale or rotation motion targeting a `Control` changes where the transform visibly originates from, matching the chosen anchor position (e.g. `BOTTOM_RIGHT` transforms from the control's bottom-right corner, `CENTER` from its middle).
- [ ] The same pivot control works on a node exposing both `offset` and `texture` (e.g. `Sprite2D`), without the node's on-screen position visibly jumping when the motion starts.
- [ ] Leaving `pivot` at its default, or setting it on a motion where it doesn't apply (any property other than scale/rotation, or a target with neither `Control` nor `offset`+`texture`), changes nothing observable — no error, no different transform behaviour.
- [ ] Test: for each of the 9 anchor positions, the resolved pivot point on a `Control` matches that position within its bounds (`TOP_LEFT` is the origin corner, `CENTER` is the midpoint, `BOTTOM_RIGHT` is the full-size corner, and so on).

#### Not this story
- A plain `Node2D` with neither `offset` nor `texture` (e.g. an empty container node) — pivot stays a no-op there; there's no inherent size to resolve a named anchor against.
- 3D pivot control.
- The easing curve library and the Motion Composer entry point — separate stories.

#### Implementation Reference
- **Files:** `addons/anima/motion/resources/anima_property_motion.gd` (`Pivot` enum, `pivot` field, `.with_pivot()` modifier alongside `with_duration`/`with_ease`/`with_delay`); `addons/anima/motion/runtime/anima_property_motion_instance.gd` (resolve and apply `pivot` once, in the same place `advance()` already resolves the start value); `tests/AnimaPropertyMotion.test.gd`
- **Contract:** `_mano_output/tech-spec.md §Motion pivot control` — the `Pivot` enum values, the two supported target categories and their exact mechanisms (`Control.pivot_offset`; `offset` + `global_position` compensation for `Sprite2D`-like nodes), and the resolved-once-at-start timing
- **Rules:** `_mano_output/project-rules.md §Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
