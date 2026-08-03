### STORY-4: Build the shared 3D Card component

#### What and why
Anyone building a 3D example scene gets a reusable Icosahedron card — the 3D counterpart of the shared 2D `Card` — instead of every 3D scene constructing its own mesh and shader inline.

#### Done when
- [ ] `Card3D` renders the Icosahedron mesh with translucent faceted faces, a bright rim along each facet edge, and a soft glow from the core — no text or letter on any face.
- [ ] Calling `set_progress(t)` on `Card3D` visibly changes its appearance continuously across `t = 0` to `t = 1`, the same single-driver contract `Card.set_progress(t)` already has (no separate named state to jump between).
- [ ] Test: `Card3D` can be instantiated and added to a scene tree without error, and its mesh uses the provided Icosahedron model.
- [ ] Test: calling `set_progress(t)` at different values of `t` produces different, non-identical visual output (e.g. differing emissive or fresnel shader parameters).

#### Not this story
- The 3D playground scene that composes `Card3D` with the shared header, selector, and playback controls — the next story.
- Any 2D `Card` change.

#### Implementation Reference
- **Files:** `examples/playground/shared/components/card_3d.tscn`; `examples/playground/shared/components/card_3d.gd`; `examples/playground/shared/materials/card_3d.gdshader`; `examples/playground/models/card.obj` (existing); `tests/Card3D.test.gd` (new)
- **Design:** `_mano_output/design-brief.md §Component guide` — "3D Card" and "3D stage" entries: faceted-glass look, `accent`/`accent-soft` recolouring (not the reference image's green), fresnel rim + emissive core via `ShaderMaterial`
- **Rules:** `_mano_output/project-rules.md §Example Scenes` — `Card3D` shared-component rule (plain descriptive name, file locations, `set_progress(t)` contract); `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
