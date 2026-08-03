### STORY-5: Showcase 3D motion

#### What and why
A developer evaluating Anima on a 3D node can run one playground and see `Anima.on()` drive a 3D Icosahedron Card, the same way the 2D convenience playground demonstrates it on a flat card.

#### Done when
- [ ] Running the 3D playground shows the same shared header and playback controls as the 2D playground, a `Card3D` in place of the 2D `Card`, a motion-family selector, and a short read-only `Anima.on()` example line for the selected family.
- [ ] The family selector lists only the `Anima.on()` families valid for a `Node3D` target.
- [ ] Choosing a family updates the example line and replays the matching motion on `Card3D`.
- [ ] Restart and reverse replay the selected family's actually recorded run, the same behaviour the 2D playground's controls already have.
- [ ] Test: selecting each listed family produces a visible run on `Card3D` that finishes, and replay controls return it through that family's recorded run.

#### Not this story
- Any family requiring a `Control`/`Node2D`/`CanvasItem` target (rotation, opacity, colour, size) — not valid for a `Node3D` target.
- Retrofitting any other existing playground into 3D.
- `Card3D` itself — built in the previous story.

#### Notes
Depends on: story-4 (`Card3D` must exist first).

#### Implementation Reference
- **Files:** `examples/playground/3d_motion_playground.tscn` (new); `examples/playground/3d_motion_playground.gd` (new); `tests/Anima.integration.3d-motion-playground.test.gd` (new)
- **Contract:** `_mano_output/tech-spec.md §Convenience method interface` — the `Node3D`-valid family set (`.position()`, `.position_x()`/`.position_y()`/`.position_z()`, `.move_by()`, `.scale()`/`.scale_by()`); `Node3D` rotation is explicitly unsupported there
- **UX:** `_mano_output/ux-flow.md §3D Motion Example Scene`
- **Design:** `_mano_output/design-brief.md §Screen composition — Phase 8 — 3D Motion Example Scene`
- **Rules:** `_mano_output/project-rules.md §Example Scenes`; `§Testing`

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
