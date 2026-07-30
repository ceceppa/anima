### STORY-9: Spacing, hierarchy, and end-to-end playground

#### What and why
Whoever opens the composition example now sees consistent, deliberate spacing between the header, stage, cards, and dock instead of loosely scattered gaps — and the whole redesigned scene (header, stage, dock, cards) works together end to end exactly as scoped this phase.

#### Done when
- [ ] The gap between the header and the stage, between the type description and the cards, between the cards and the dock, and between individual cards all match the values in `design-brief.md`'s Spacing scale
- [ ] Opening the scene shows the header, the bordered stage, the type title/description, the cards, and the selector dock all visible together with no overlapping elements
- [ ] Selecting each of the six composition types in turn updates only the stage's contents (title/description, cards, dock selection) while the header, stage, and dock positions never move

#### Not this story
- Introducing any new component — this story only applies the already-specified spacing values across the components built in stories 1–8.

#### Notes
This is the phase's closing story. Its last AC is the end-to-end check that the phase goal — a shared header, one bordered stage, and a floating selector dock reading as one polished playground — actually holds once every earlier story lands. Depends on stories 1–8 all being complete.

#### Implementation Reference
- **Design:** `design-brief.md` §Spacing scale — exact gap values for every pairing listed above
- **Files:** `examples/composition_playground.tscn` — adjust container margins/separations to match
- **Test file:** `tests/Anima.integration.composition_playground.test.gd` (update existing) — add an end-to-end assertion covering header/stage/dock position stability across a full type switch through all six types

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
