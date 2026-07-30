### STORY-9b: Conditional shows one branch with a callout

#### What and why
Whoever selects Conditional now sees a brief callout naming which branch the condition picked, then watches a single card move differently depending on that branch — forward, larger, and brighter for the true branch; backward, smaller, and dimmer for the false branch — instead of today's two static "True"/"False" cards where only one silently animates.

#### Done when
- [ ] When Conditional starts playing, a brief text callout appears showing the evaluated condition ("Condition evaluated: TRUE" or "Condition evaluated: FALSE") and which branch is playing
- [ ] The callout disappears on its own after a short moment, leaving just the animating card
- [ ] Exactly one card is shown for Conditional — not two
- [ ] The card shows no "True"/"False" label on itself; which branch ran is communicated by the callout and by the card's movement/appearance, not by reading a letter on the card
- [ ] When the condition evaluates true: the card moves forward, grows slightly larger, and becomes brighter than its resting look
- [ ] When the condition evaluates false: the card moves backward, shrinks slightly smaller, and becomes dimmer than its resting look
- [ ] Test: selecting Conditional repeatedly eventually shows both the true-branch look (forward/larger/brighter) and the false-branch look (backward/smaller/dimmer) across different runs, each matching the callout shown that run

#### Not this story
- Changing `AnimaConditional`'s own runtime behaviour (`tech-spec.md` §Data model) — this story only changes how the demo presents whichever branch already ran.
- Any UI for authoring or previewing the condition callable itself.
- Any other composition type's card presentation — Sequence/Parallel/Stagger/Repeat/Race keep the multi-card model from stories 5–6.

#### Notes
Supersedes story-8's two-card "True"/"False" presentation — it shipped, but direct feedback says it's still confusing. Story-8's file stays as shipped history (it's `done` and immutable per the story index rules); this story is the current contract for Conditional's demo going forward. `design-brief.md` still documents the old two-card treatment — worth a `mano ui` pass to update it once this ships, though not required to build this story.

Exact callout wording beyond the two lines above, how long it stays visible, and precise movement/scale/brightness amounts are left to implementation. The fixed part is the qualitative direction: forward/larger/brighter vs. backward/smaller/dimmer, plus the two callout lines shown briefly at start.

#### Implementation Reference
- **Files:** `examples/composition_playground.gd` — replace `_build_conditional_demo()`'s two-card model with a single-card model; add the callout display, shown briefly when Conditional's playback starts
- **Design note:** forward/backward movement, scale, and brightness for this one card are new — not part of `StateCard`'s existing `set_progress(t)` contract (`project-rules.md` §Example Scenes covers label/progress only). Decide whether this is a new optional axis on `StateCard` or a bespoke visual for this one demo before writing the code; either way, `StateCard` still has no named state.
- **Do not:** no "True"/"False" letter shown on the card itself; no second card

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
