### STORY-3: Formula Showcase (Scene 3)

#### What and why
The scene cuts back to the inventory frame and plays three visibly different grid propagation formulas back-to-back, each with the exact line of code that triggered it shown live at the bottom of the screen — proving the "one line, many looks" pitch instead of just claiming it.

#### Done when
- [ ] After Scene 2's window ends, the scene hard-cuts back to the inventory frame, reset and ready to replay from
- [ ] Three visibly different grid formulas play back-to-back, roughly 2 seconds each, together spanning the storyboard's 0:05–0:12 window
- [ ] A caption bar at the bottom of the screen shows the single line of code for whichever formula is currently playing, and updates when the next formula starts
- [ ] Test: an integration test advances through Scene 3's window and asserts at least two different caption-bar code lines appear in sequence

#### Not this story
- Which three specific formulas are used — any three visibly distinct ones from the existing formula set satisfy this story
- Scenes 1, 2, and 4

#### Notes
Reuses the same inventory-frame component story 1 built; only its animation and the caption bar are new here.

Depends on: story 1.

#### Implementation Reference
- **Files:** `examples/showcase/grid/grid_showcase.tscn`, `examples/showcase/grid/grid_showcase.gd`
- **Design:** `design-brief.md` §Showcase: Grid — visual direction (Formula caption bar spec); §Screen composition — phase-13 — Grid Showcase, Scene 3
- **Contract:** `tech-spec.md` §Grid motion contract for the available formulas
- **Rules:** Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
