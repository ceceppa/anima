### STORY-5: Playground demos — Keyframes and Spring families

#### What and why
A developer evaluating Anima has no way to see a keyframe motion or a spring-eased motion actually running without writing their own script. This story adds both as new families in the existing convenience motion playground, alongside Position/Scale/Rotation/etc., so both are visible and interactive like everything else there — closing the exact gap Phase 11's review flagged for springs, and giving keyframes a demo from day one instead of waiting for a future phase to notice the same gap again.

#### Done when
- [ ] The convenience motion playground's family selector includes a "Keyframes" option; selecting it plays a multi-stop, multi-property keyframe motion on the card (at least fade, move, and scale through more than two stops) and shows its matching `Anima.on(card).keyframes(...)` example line
- [ ] The convenience motion playground's family selector includes a "Spring" option; selecting it plays a spring-eased motion on the card and shows its matching example line
- [ ] Restart, Reverse, Complete, Revert, Speed, and Reduced-motion all work correctly for both new families, the same as every existing family in that playground — no family-specific exceptions
- [ ] Reversing the Keyframes family visibly eases the opposite way it eased forward (story 4's mirroring), not the same shape played backward
- [ ] Test: an integration test selects each new family and asserts a real `AnimaPlayback` starts, matching the pattern already used for every other family in that playground's test file

#### Not this story
- A dedicated spring or keyframe showcase scene — this is the same shared convenience playground every other family already lives in, not a new scene
- Any new shared component — `SelectorButton`/`SelectorDock`/`Card`/`PlaybackControls` are reused exactly as they already are

#### Notes
Depends on stories 1-4 (needs authoring, playback, and reversal all working first). Springs have no dependency on the keyframe stories — could be built independently, but is sequenced last here since it's a small, self-contained addition to the same file the keyframe family also touches.

#### Implementation Reference
- **Files:** `examples/playground/convenience_motion_playground.gd` — extend the `Family` enum, `FAMILY_LABELS`, `FAMILY_EXAMPLES`, and `_build_motion()`'s match statement with `KEYFRAMES` and `SPRING` cases
- **Contract:** `tech-spec.md` §Keyframe motions for the exact authoring call; `AnimaEase.Kind.SPRING` (existing) for the spring case — build via the existing `.with_ease(value)` modifier (`tech-spec.md` §Convenience method interface), not a new spring-specific convenience method
- **Rules:** Example Scenes — `project-rules.md` §Example Scenes (reuse the established family-selector pattern exactly: `SelectorButton` per family, `_selector.add_item()`, no ad-hoc UI); Testing — same section as story 1

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
