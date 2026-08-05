### STORY-1: Scene shell and Inventory Hook (Scene 1)

#### What and why
A developer opens the new Grid Showcase scene and immediately sees the dark-fantasy inventory hook — the RPG-styled backdrop, a 5×5 inventory frame, and its items rippling into their slots as the opening banner text reads. This is the first beat of the storyboard and establishes the shared scene shell (background, scrim, banner text treatment) every later beat builds on.

#### Done when
- [ ] Opening the showcase scene and pressing play immediately shows the dark, scrimmed background with the centred 5×5 inventory frame and the opening banner text ("Grid animations in Godot without nested math loops.") visible together
- [ ] The inventory frame starts with all 25 slots empty (border only, no item art) and each slot's item art ripples into place using a grid-driven animation, finishing within the storyboard's 0:00–0:02 window
- [ ] If the background image or an item-icon asset under `examples/showcase/grid/assets/` is missing, the scene shows an obvious placeholder in its place instead of an invisible gap, a crash, or a silent error
- [ ] Test: an integration test opens the showcase scene, advances it through Scene 1's window, and asserts the inventory frame's slots visibly fill

#### Not this story
- Scenes 2, 3, and 4 — this story ends once Scene 1's own content is playing and verified; the cut into Scene 2 is story 2's job
- Sourcing or creating the actual background/item-icon artwork — the user supplies it separately; this story consumes whatever is present

#### Notes
Establishes the shared scene shell (background + scrim, banner-text component) every later scene in this phase reuses. `examples/showcase/grid/assets/background.jpg` already exists; item-icon assets may not exist yet — build against the missing-asset placeholder behaviour above so later stories aren't blocked waiting for final art.

#### Implementation Reference
- **Files:** `examples/showcase/grid/grid_showcase.tscn`, `examples/showcase/grid/grid_showcase.gd`
- **Design:** `design-brief.md` §Showcase: Grid — visual direction (canvas, palette, Inventory frame + Scene banner component specs); §Screen composition — phase-13 — Grid Showcase, Scene 1
- **Contract:** `tech-spec.md` §Grid motion contract for the grid-driven ripple-in propagation
- **Rules:** Example Scenes — `project-rules.md` §Example Scenes (new `examples/showcase/` category: self-contained, own `assets/`, no shared playground Theme/components); Editor-Authored Content — `project-rules.md` §Example Scenes (static per-scene text as `@export`, set via the Inspector); Naming — `project-rules.md` §Naming (plain descriptive script/class names, no `Anima` prefix); Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
