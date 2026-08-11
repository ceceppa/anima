### STORY-8a: Convenience playground demonstrates play(), fade, delay, and named-ease shorthand

#### What and why
A developer opening the convenience-motion playground after phase 15 can see `.repeat()`/`.on_started()`/`.on_completed()` (Chained) and `.with_ease()` with a full `AnimaEase` (Spring), but nothing demonstrates the phase-15 additions themselves: starting a motion via the chain's own `.play()`, `fade_in()`/`fade_out()`, `with_delay()`, or `with_ease()` accepting a bare `AnimaEase.Kind`. Adding entries for these lets the person who just implemented phase 15 see every new method actually run in the same playground every earlier capability got its own demo in, rather than only reading it in source.

#### Done when
- [ ] A new "Fade" family entry fades the card out then back in using `Anima.on(card).fade_out(...)`/`.fade_in(...)`, and its read-only example line shows that call
- [ ] A new family entry demonstrates `with_delay(...)` on an `Anima.on()` chain — the card visibly pauses before it starts moving — and its example line shows that call
- [ ] A new family entry demonstrates `with_ease(...)` passed a bare `AnimaEase.Kind` value (not a constructed `AnimaEase`), and its example line shows that call
- [ ] At least one family entry (the new Fade entry, or an existing one) starts its motion via the chain's own `.play()` instead of the playground's shared `Anima.play(motion, _card)` call in `restart()`, and its example line reflects that
- [ ] Every new family entry works correctly with Restart, Reverse, Complete, Revert, Speed, and Reduced-motion, the same as every existing family

#### Not this story
- Converting every existing family to start via `.play()` — only the new entry(ies) this story adds need to
- The grid playground (see story-8b)
- The showcase scenes under `examples/showcase/grid/`

#### Notes
None.

#### Implementation Reference
- **Build:** add entries to the existing `Family` enum, `FAMILY_ORDER`, `FAMILY_LABELS`, and `FAMILY_EXAMPLES` consts, and matching branches in `_build_motion()` — the same pattern `CHAINED`/`SPRING`/`DYNAMIC_VALUES` already follow
- **Files:** `examples/playground/convenience_motion_playground.gd`
- **Contract:** new/changed `Anima.on()` methods this story exercises — `.play()`, `.fade_in()`/`.fade_out()`, `.with_delay()`, `.with_ease()` accepting `AnimaEase.Kind` — per `_mano_output/phase-15/stories/story-1-on-chain-play.md`, `story-3-on-with-delay.md`, `story-4-with-ease-kind.md`, `story-8-fade-convenience.md`
- **Rules:** `project-rules.md §Testing` — the existing `tests/Anima.integration.convenience-playground.test.gd`'s `test_selecting_each_family_produces_a_visible_card_run_matching_the_shown_example` already iterates every family generically; a family whose motion is an `AnimaPropertyMotion` and whose example line contains `"Anima.on(card)"` needs no special-case branch there (see how `Keyframes`/`Dynamic Values` are special-cased for comparison). Add one dedicated test per new family for its distinguishing behaviour (delay visibly pausing playback, fade ending at 0/1 opacity), following the shape of `test_spring_family_visibly_overshoots_its_target_before_settling`/`test_chained_family_demonstrates_callbacks_repeat_and_reverse_together`
- **Do not:** do not add a `Test:` AC to the story itself beyond what's above — this project's testing convention lives in `project-rules.md §Testing`, already covered by the pointer above

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
