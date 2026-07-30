### STORY-6: Composition-specific card storytelling

#### What and why
Whoever watches Sequence, Parallel, Stagger, Repeat, or Race can tell which one is playing just from how the cards move — one after another, all together, a travelling offset, a repeating pulse, or a race to a winner — instead of every type reading the same way by the time it ends.

#### Done when
- [ ] Sequence: card B does not begin animating until card A's animation has reached full progress
- [ ] Parallel: every card begins animating at the same time
- [ ] Stagger: each card begins animating a fixed short interval after the previous card, so watching left to right shows the start visibly travelling across the cards
- [ ] Repeat: the same card visibly completes and then restarts its animation from the beginning at least twice while the demo plays
- [ ] Race: exactly one card reaches full progress; the other stops before reaching full progress once the first card finishes

#### Not this story
- Restoring Conditional's own two-card demo — story-8.
- Changing `AnimaSequence`/`AnimaParallel`/`AnimaStagger`/`AnimaRepeat`/`AnimaRace`'s own runtime timing rules — those are existing, already-specified behaviour (`tech-spec.md` §Key technical decisions); this story is only about the cards visibly exhibiting it through `StateCard` (story-5).

#### Notes
Depends on story-5 (the card's glow/progress mapping must already reflect progress correctly for any of this to be visible). Per the phase brief's Acknowledged Risks, whether each type reads as *clearly distinct* to a viewer is a perceptual judgement call these AC can't fully verify by themselves — a manual visual-inspection pass (as flagged after the previous phase) is worth doing once this story is built, even with the AC above passing.

#### Implementation Reference
- **Design:** `design-brief.md` §Screen composition — per-type card behaviour summary
- **Files:** `examples/composition_playground.gd` — confirm each composition type's existing demo builder drives its cards' `set_progress` per the timing described above, and adjust any that don't yet
- **Test file:** `tests/Anima.integration.composition_playground.test.gd` (update existing) — one assertion per composition type covering the behaviour above, per `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
