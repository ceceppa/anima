### STORY-1: Cancel, complete, and revert with value policies

#### What and why
For a game developer scripting UI or gameplay animations with Anima, stopping a motion today only freezes it wherever it happens to be — there is no way to force it to its end state early, or snap it back to how the target looked before it started, without hand-writing that logic themselves. This story gives every playback three distinct, predictable endings — cancel, complete, and revert — so a developer picks the exact outcome they need instead of working around one blunt stop.

#### Done when
- [ ] Calling `complete()` on a running motion immediately applies its authored end value(s) to the target and fires its completion callback/signal exactly once, the same as if it had played to the end naturally
- [ ] A motion with its completion policy set to restore-initial ends up back at the value it had before playback started, immediately after `complete()` (or a natural finish) — while a motion left at the default policy stays at its end value
- [ ] Calling `revert()` on a running motion stops it and returns the target to the exact value it had before playback started
- [ ] Calling `cancel()` on a running motion at the default policy leaves the target at whatever value was showing the instant `cancel()` was called — unchanged from today's behaviour
- [ ] A motion with its cancellation policy set to restore-initial, or to complete, ends up respectively at its pre-playback value or its authored end value after `cancel()` — in both cases no completion callback fires, and the outcome reported is a cancellation, not a successful finish
- [ ] The same complete()/revert()/cancel() outcomes hold for a leaf property motion, a Sequence/Parallel composition, and a Group motion — not only a single property motion
- [ ] Test: `complete()`, `revert()`, and each cancellation/completion policy combination are covered by GUT unit tests on `AnimaPlayback`, plus an integration test driving them through `Anima.play()`
- [ ] Test: every new public method, field, and enum introduced by this story has an in-editor `##` doc comment, and `npm run docs:api` completes with no missing-documentation failures for them

#### Not this story
- Signal disconnection, property-ownership release, or layout-overlay cleanup on cancellation — none of those systems exist yet in this codebase; this phase's cancellation cleanup is limited to the state/value outcome above
- The target-freed auto-cancel safety net — covered by story-2
- Per-item value-policy overrides inside a group — the policy is read from the top-level motion only this phase

#### Notes
Reuses each motion-instance type's existing captured "value observed at motion start" rather than building a new snapshot system — see `tech-spec.md` §Playback lifecycle: cancel, complete, revert, reverse, `restore_initial()`.

#### Implementation Reference
- **Files:** `addons/anima/motion/runtime/anima_playback.gd` (`complete()`, `revert()`, `cancel()` policy handling); `addons/anima/motion/resources/anima_motion.gd` (`CompletionValuePolicy`, `CancellationValuePolicy` enums and fields); every motion-instance type under `addons/anima/motion/runtime/` gains `restore_initial(target)` alongside its existing `advance()`/`build_reversed()`
- **Contract:** `tech-spec.md` §Playback lifecycle: cancel, complete, revert, reverse — exact method behaviour, policy values/defaults, and the `COMPLETE` cancellation-policy signal-semantics decision; §Playback interface for the full signature list
- **Data:** `tech-spec.md` Data model — `AnimaMotion` row, new fields
- **Rules:** Naming — `project-rules.md` §Naming; Testing — `project-rules.md` §Testing (unit test per changed class plus an `Anima.integration.*` test, permanent, never a disposable smoke test); Documentation — `project-rules.md` §Documentation (`##` comment on every new public member; generation contract in `tech-spec.md` §API documentation pipeline)
- **Do not:** conflate the new `CompletionValuePolicy`/`CancellationValuePolicy` with the existing, unrelated `AnimaGroupMotion.CompletionPolicy`/`AnimaParallel.CompletionPolicy` (see `tech-spec.md` Key technical decisions)

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
