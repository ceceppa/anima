### STORY-4: Finale Matrix, adjustable wave delay, and full sequence integration (Scene 4)

#### What and why
The showcase closes on its biggest visual beat — a 4×4 wall of 16 miniature inventory grids animating outward from the centre one at a time before dimming behind the Anima logo and call-to-action — and this story is also where the whole ~15-second sequence is proven to run start-to-finish automatically, the exact capability the phase exists to deliver.

#### Done when
- [ ] After Scene 3's window ends, the scene hard-cuts to a 4×4 matrix of 16 miniature 5×5 inventory grids
- [ ] The centre-most grid's animation starts first; the remaining grids then start one at a time, spiralling outward from the centre, each one starting a fixed delay after the previous
- [ ] That delay is an editable value on the scene (not a hardcoded literal); changing it and replaying the scene visibly changes how fast the spiral spreads across the 16 grids
- [ ] Not all 16 grids play the identical formula — at least two visibly different propagation patterns are visible across the matrix
- [ ] At 13.5 seconds into the scene, a dark overlay dims the matrix and the Anima logo fades in at the centre with the closing text ("ANIMA FOR GODOT 4", "15+ Built-in Formulas • Open Source", "Link in Comments")
- [ ] Test: an integration test opens the showcase scene, presses play once, and advances it through the full ~15-second run, asserting each of the four scenes' distinguishing content appears in order and the closing logo/CTA is visible at the end — proving the whole sequence runs automatically with no manual triggering between beats

#### Not this story
- Exporting or rendering a video file — the user does that separately via Godot's own Movie Writer once satisfied with the scene
- Any change to which grid formulas exist — this story only composes existing ones

#### Notes
⚠ Verify: the "centre first, then outward" wave here is written as a strict one-at-a-time spiral (matching the existing `SPIRAL_OUTWARD` grid formula) rather than simultaneous concentric waves (`GRID` order with a centre origin) — both are existing, valid formulas, but only the one-at-a-time reading fits the 12.0–13.5s window at a 0.1s-per-step pace without the matrix visibly finishing early and sitting idle. Confirm before implementing if a different pacing was intended.

Depends on: stories 1, 2, 3 — this story owns the end-to-end integration AC across all four scenes.

#### Implementation Reference
- **Files:** `examples/showcase/grid/grid_showcase.tscn`, `examples/showcase/grid/grid_showcase.gd`
- **Design:** `design-brief.md` §Showcase: Grid — visual direction (Finale matrix + Logo/CTA block spec); §Screen composition — phase-13 — Grid Showcase, Scene 4
- **Contract:** `tech-spec.md` §Grid motion contract's nested-group paragraph (`item_motion` may itself be a group/grid; `CHILDREN`/`DESCENDANTS` resolve against whichever target the resolving motion currently receives) — the mechanism this scene's grid-of-grids composition depends on; `AnimaGroupDistribution.stagger_interval` for the adjustable delay
- **Rules:** Editor-Authored Content — `project-rules.md` §Example Scenes (the wave delay as an `@export` value); Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
