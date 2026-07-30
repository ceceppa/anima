### STORY-3: Per-type title, description, and counter inside the stage

#### What and why
Whoever selects a composition type sees that type's name and a one-line description appear inside the stage, alongside a running counter ("01 / 05"), fading in over the previous type's text instead of the new text snapping into place the instant the old text disappears.

#### Done when
- [ ] Selecting a composition type shows its name and matching one-line description in the top-left of the stage
- [ ] An example counter ("01 / 05" style) sits in the top-right of the stage, showing the selected type's position out of the five types currently offered (Sequence, Parallel, Stagger, Repeat, Race)
- [ ] Switching type replaces the previous title/description with a brief fade transition instead of the new text appearing in the same instant the old text disappears
- [ ] Test: selecting each of the five types shows the matching title/description pair listed in Implementation Reference
- [ ] Test: selecting the same type twice in a row shows the same counter value both times

#### Not this story
- The header or stage container structure — stories 1–2.
- The composition-specific behaviour the cards themselves demonstrate — story-6.
- Conditional's title/description/counter slot — added in story-8 alongside restoring Conditional, which also updates the counter total from five to six.

#### Notes
Depends on story-2 (the stage exists to hold this content).

#### Implementation Reference
- **Design:** `design-brief.md` §Component guide "Stage type title + description", §Typography (stage type title/description, caption)
- **Data — per-type copy** (not yet captured in any Mano artifact; verbatim from the phase's originating UI-recommendations request, inlined here since no other artifact owns it):
  - Sequence: "Runs each animation one after another."
  - Parallel: "Starts all animations at the same time."
  - Stagger: "Starts each animation after a short offset."
  - Repeat: "Replays the composition multiple times."
  - Race: "Completes when the first animation finishes."
- **Files:** `examples/composition_playground.gd` — drive the stage's title/description/counter labels from the selected type
- **Do not:** no large enter/exit animation on the title/description — a brief crossfade only (`design-brief.md` §Component guide)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
