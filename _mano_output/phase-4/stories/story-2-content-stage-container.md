### STORY-2: Content stage container replaces flat layout

#### What and why
Instead of the description, cards, and selector floating loosely on the scene background, whoever runs the example now sees them held inside one bordered, shadowed stage panel that stays put while the demo changes — matching the shared header above it. The previous standalone duration-kind badge and restart button are gone from this demo for now.

#### Done when
- [ ] Below the header, one bordered, rounded panel (the stage) contains the type description, the card row, and the selector dock
- [ ] The stage's position and size stay the same no matter which composition type is selected
- [ ] The duration-kind badge and the restart button, both present in the previous version of this scene, are no longer visible anywhere in the scene
- [ ] Test: switching composition type does not change the stage panel's reported position or size

#### Not this story
- The per-type title/description content and its transition — story-3.
- The selector dock's own visuals and behaviour — story-4.
- Re-adding the duration badge or restart control, or removing the underlying `AnimaPlayback`/duration-reporting code paths that back them — out of scope this phase (`design-brief.md` §Component guide notes both as removed from the demo "for now", not deleted from the addon).

#### Notes
Depends on story-1 (the header sits above the stage). The duration badge and restart button were part of the previously shipped scene; this story only removes them from the visible layout.

#### Implementation Reference
- **Design:** `design-brief.md` §Component guide "Content stage (container)", §Border radius (`radius-lg`), §Spacing scale (stage internal padding), §Colour palette (`stage-bg`)
- **Files:** `examples/composition_playground.tscn`, `examples/composition_playground.gd` — restructure the existing scene tree so the description/cards/selector sit inside the new stage container
- **Do not:** no duration badge, no restart button visible in this scene (`design-brief.md` §Component guide)
- **Test file:** `tests/Anima.integration.composition_playground.test.gd` (update existing) — remove assertions tied to the old badge/restart UI; add a stage-position/size-stability assertion

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
