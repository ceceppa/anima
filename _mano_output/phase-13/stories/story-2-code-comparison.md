### STORY-2: Code Comparison cut (Scene 2)

#### What and why
Immediately after the inventory hook, the showcase hard-cuts to a full-screen code comparison — 25 dense lines of hand-written Godot looping code beside Anima's single `Anima.grid()` call — making the pitch visual before a single formula has even played.

#### Done when
- [ ] After Scene 1's window ends, the scene hard-cuts to a full-screen two-panel code comparison: a red-tinted "Vanilla Godot" panel and a green-tinted "Anima" panel, both fully readable at once
- [ ] The header text above the comparison reads "From 25 lines of math to 1 line."
- [ ] The cut happens within the storyboard's 0:02–0:05 window and the inventory frame from Scene 1 is fully hidden during it
- [ ] Test: an integration test advances the scene into Scene 2's window and asserts the code-comparison panels are visible while the inventory frame is not

#### Not this story
- The exact final wording of either code sample — the vanilla-Godot snippet is illustrative placeholder content the user will revise later, not production copy
- Scenes 3 and 4

#### Notes
Extends story 1's scene shell with the second beat and its own hard-cut transition. Placeholder code content should be easy to edit as plain text later (see Editor-Authored Content rule) — do not hardcode it deep inside animation logic.

Depends on: story 1.

#### Implementation Reference
- **Files:** `examples/showcase/grid/grid_showcase.tscn`, `examples/showcase/grid/grid_showcase.gd`
- **Design:** `design-brief.md` §Showcase: Grid — visual direction (Code comparison card spec, palette tokens `code-vanilla-*`/`code-anima-*`); §Screen composition — phase-13 — Grid Showcase, Scene 2
- **Rules:** Editor-Authored Content — `project-rules.md` §Example Scenes; Testing — `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
