# Phase Review — Anima

<!-- Always append new phase entries at the bottom of the file. Never insert between existing entries. -->
<!-- For follow-up fix work on an already-reviewed phase, append an ### Addendum subsection to the existing phase entry — do not create a new ## heading. -->

---

## Phase 1 Review — 2026-07-30

### What worked

- Sequence, Parallel, property motion, and real easing all compose through one polymorphic runtime contract (`estimate_duration()` / `create_runtime()` / `advance()`), verified end-to-end by the nested Sequence-inside-Parallel + easing test.
- Zero-setup playback holds: `Anima.play()` works on the first call with no autoload or scene wiring, matching the phase's core principle.

### What didn't

- No developer documentation was produced for any of Phase 1's new classes.
- Legacy v1 documentation was left in place after the v1 source was deleted mid-phase, so it now describes code that no longer exists.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| Phase 1's duration reporting is a single number; the deferred Duration model (Fixed/Estimated/Dynamic/Infinite) later generalises this to a duration kind. | Rework needed once Dynamic/Infinite leaves ship. | Held as assumed this phase — no rework needed yet, since Property motion is the only leaf and its duration is always Fixed. | confirmed |
| Phase 1's evaluation loop runs on one implicit tick source; the deferred Clock modes item later makes this configurable (Idle/Physics/Manual). | Restructuring risk if the loop hardcodes tick-source assumptions. | Held as assumed — the central per-frame loop doesn't hardcode anything that would block adding Idle/Physics/Manual modes later. | confirmed |

### Feedback that changes future scope

- Every new Anima class needs a beginner-friendly documentation page going forward — not a one-off Phase 1 cleanup. See the new "Documentation page convention for new classes" backlog item for the required template.

### What we learned

- Documentation wasn't part of any story's Definition of Done in Phase 1. Future phase briefs/stories should decide explicitly whether doc pages ship in-phase or as a separate pass, rather than defaulting to forgotten.

---

## Phase 2 Review — 2026-07-30

### What worked

- All 12 Phase 1 classes got a documentation page, and the docs site's stale v1 content — the old class-reference pages, guides, tutorials, and features — was fully removed.
- Verifying the docs site's build surfaced a real, unrelated Hugo/theme version incompatibility (several removed/renamed Hugo APIs) and got it fixed, rather than shipping docs nobody could actually build.

### What didn't

- The docs site had never been verified against the currently-installed Hugo version before this phase — the build-check acceptance criterion couldn't even be assessed until several theme templates were patched first.
- Removing the v1-specific guides/tutorials/features left the docs site with no top-level overview or quickstart page until a future phase writes new ones for the v2 API.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| The documentation-page convention is stable enough to write all 12 pages against as-is. | Reformatting risk if the convention changed materially after pages were written. | Held — the convention didn't change during the phase; all 12 pages were written against it once. | confirmed |

### Feedback that changes future scope

No feedback logged.

### What we learned

- The docs site's build had drifted out of sync with its own theme's Hugo-version assumptions before this phase touched it. A build-verification step earlier in the pipeline — not just at doc-writing time — would catch this kind of drift sooner.

---

## Phase 3 Review — 2026-07-30

### What worked

- All four remaining composite types (Stagger, Repeat, Race, Conditional) compose correctly through the same polymorphic `estimate_duration()`/`create_runtime()`/`advance()` contract Sequence and Parallel already proved — no type-specific branching needed in the runtime.
- The Motion builder produces behaviour identical to direct resource construction across all six composite types, verified with side-by-side playback tests for each.
- Relationship timing modifiers (overlap, start-offset, start-after-start) work via a precomputed schedule (`AnimaSequence.compute_schedule()`), which turned out reusable well beyond its original duration-estimation purpose — the example scene's whole card-timing visualization is built on it.

### What didn't

- The Race vs. Parallel example-scene demos looked visually identical (both just showed two cards animating and completing together) until manually inspected — nothing in the automated suite could have caught this, since it's a perceptual/legibility issue, not a functional one.
- Same story for Repeat: three separate cards each pulsing once read as three unrelated one-time events, not as "the same thing repeating" — again invisible to functional tests, only caught by watching it run.
- `AnimaRuntime.get_singleton()` had a latent bug since Phase 1 (a direct `add_child()` on the scene tree root, which Godot rejects if the root is still mid-`add_child()` for the scene itself) that no test in three phases had exercised, because GUT tests never call `Anima.play()` from inside a node's own `_ready()` during genuine initial scene load. The example scene's own startup was the first real caller to hit it.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| A Conditional with a runtime-only condition can report Dynamic duration using only the sliced, editor-free Duration model from this phase. | Rework needed once the Motion Composer exists, if Dynamic-duration reporting needs more than the runtime concept. | Held — implemented exactly as assumed (`RUNTIME` resolution returns `Kind.DYNAMIC` without evaluating the condition; branch selected once in `create_runtime()`), no Motion Composer dependency needed, verified by tests including a Conditional nested inside a Sequence propagating Dynamic correctly. | confirmed |

### Feedback that changes future scope

- Example/demo scenes need a real visual-inspection pass after implementation, not just passing tests — a story's AC and GUT coverage can be fully green while the demo is still confusing or visually misleading (Race indistinguishable from Parallel, Repeat's repetition unreadable). Future phases with a demo-scene deliverable should expect and budget for this as a distinct follow-up step, not assume story completion closes the loop.
- A shared button component (`SelectorButton`) and a canonical button-padding value were extracted reactively, after an inline `StyleBoxFlat` silently diverged from the shared theme's own Button style. Worth watching for the same drift pattern (a value duplicated inline instead of homed once) as more example-scene UI accumulates.

### What we learned

- GUT's automated coverage verifies functional correctness (durations, completion, state transitions) but has no way to catch visual/perceptual problems — two different composition types looking identical, or an animation reading as "happened once" when it structurally happened three times. That class of bug only surfaces by actually watching the scene run, which is a fundamentally different verification channel than story ACs and test suites provide.
- A latent runtime bug can survive multiple phases of green tests if nothing in the suite exercises the exact real-world call pattern that triggers it (here: `Anima.play()` invoked from a node's own `_ready()` during real initial scene load, not from a test harness that never reproduces engine startup timing).
