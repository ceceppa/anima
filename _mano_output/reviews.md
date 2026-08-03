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

---

## Phase 4 Review — 2026-07-31

### What worked

- The continuous `set_progress(t)` card model held up exactly as assumed: it absorbed resting/waiting/active/completed visuals, and later Conditional's forward/backward/grow-shrink/brighten-dim treatment, without becoming a discrete state machine again.
- The new shared components (`ExampleHeader`, the content stage container, `SelectorDock`/`SelectorButton`) were built once and reused correctly inside `composition_playground` — no retrofitting of an older ad-hoc pattern was needed.
- 107 GUT tests (unit + integration) stayed green across repeated runs despite two randomised demos (Race, Conditional), giving real confidence in the functional behaviour underneath the visual redesign.

### What didn't

- Conditional's first shipped presentation (story-8: two static "True"/"False" cards, only one animating) had to be redesigned after shipping (story-9b: one card, forward/backward + grow/shrink + brighten/dim, plus a brief callout) — direct feedback said it was "still confusing," even though story-8 met its own AC and passed its tests.
- Two small planning gaps surfaced only during implementation: `ExampleHeader`'s rule briefly documented a `set_counter()` method that was never actually needed (the counter lives on the stage's type-title row, not the header), and the per-type stage copy text was never captured in `design-brief.md`, so it had to be inlined directly into stories instead of referencing an owning artifact.
- A new project rule (editor-authored static content via `@export`, not code-set imperative calls) was added mid-phase and needed its own same-day follow-up story (9a) to actually reach already-shipped code — the rule didn't retroactively apply itself.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| The existing continuous progress-driven card model (`set_progress(t)`) can be re-skinned into resting/waiting/active/completed visuals without becoming a discrete state machine again. | Rework needed if the states required genuinely discrete transitions. | Held — the same single driver absorbed every visual need this phase, including Conditional's later direction/scale/dim treatment, with no state field added anywhere. | confirmed |
| "Shared component used by every example" is scoped this phase as reusable-and-applied-to-`composition_playground`, not retrofitted onto other scenes, since none exist yet. | The reuse claim couldn't be verified until a second example scene existed. | Held as scoped — no second example scene was built this phase; the components were built with reuse in mind but the claim itself stays unverified until one exists. | confirmed |

### Feedback that changes future scope

- In-editor GDScript help (`##` doc comments on the public API) is missing — hovering an Anima function in the Godot editor shows "no description available." Logged as a new backlog item for a future phase.
- Conditional needed a second design pass after shipping once. Watch for the same "passes its own AC, still confusing in practice" pattern on any future composition-type-specific storytelling work — it's the same class of gap Phase 3's review already flagged, just recurring on a different composition type.

### What we learned

- Phase 3's review lesson repeated exactly: automated tests can't catch "this is still confusing" — only a person actually running the demo caught Conditional's usability problem, and only after it had already shipped once.
- A project rule introduced mid-phase needs its own tracked follow-up story to reach code that shipped before the rule existed — a new rule doesn't retroactively apply itself to already-written code.

---

## Phase 5 Review — 2026-07-31

### What worked

- Every new curve kind (back/bounce/elastic/cubic-Bezier/curve-resource/callable-evaluator/decay/custom-sampled) and the spring kind landed as additions to the existing `AnimaEase` resource, with no new easing class introduced — matching the phase's design principle that a spring is "just another `AnimaEase` kind."
- `Anima.of($Node)` shipped as a thin proxy over `Anima.play()`, exactly as scoped — no parallel authoring system.
- `AnimaBehaviour` attaches to and is discoverable from an ordinary node (via metadata + a private group) with zero subclassing, resolving the phase's open spec question on storage mechanism in the source document's recommended direction.
- The in-editor hover-help gap flagged in Phase 4's review was closed across the entire public API, old and new, in one sweep (story-6) — not just this phase's additions.

### What didn't

- No defects or refinements were reported during this review — all three assumptions held and no follow-up feedback was logged.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| The spring completion/retargeting model built this phase is the foundation the later reversibility epic (`playback.reverse()`, `retarget_to_start()`) will build on — this phase implements forward spring behaviour only, not reversal. | If reversal needs a different underlying spring representation than what ships here, the spring model may need reworking once the reversibility epic starts. | Held as assumed — confirmed by user review. | confirmed |
| The standalone `Anima.of` proxy shipped this phase is a deliberately narrowed version of the PRD's full proxy, which also covers `AnimaBehaviour`-bound nodes — that integration is separate follow-on work, not this phase. | If `Anima.of`'s standalone shape doesn't accommodate reading an attached `AnimaBehaviour` cleanly, the follow-on integration may need to rework this phase's proxy shape. | Held as assumed — confirmed by user review. | confirmed |
| `AnimaBehaviour`'s state-bindings field is scoped this phase as a reserved, non-functional slot — the deferred "State bindings for common control states" item is what actually makes it do anything. | If the field's shape doesn't match what the binding behaviour needs later, that later item may need to change the field instead of just building on it. | Held as assumed — confirmed by user review. | confirmed |

### Feedback that changes future scope

No feedback logged.

### What we learned

- No new lessons surfaced this review — the phase closed cleanly against its own goal and assumptions.

---

## Phase 6 Review — 2026-08-03

### What worked

- The phase delivered the complete group-motion workflow across runtime playback, compilation, authoring, inspection, reduced-motion handling, tests, benchmarking, and a showcase.
- A single item motion applied across a resolved target collection remained the right core model for this phase.

### What didn't

- The shared `ExamplePlayground` base exists but has not yet been adopted by every existing runnable playground, leaving HiDPI scaling inconsistent across demos.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| Core groups apply one shared item motion to every resolved target. | Heterogeneous target-to-motion mapping would require a separate model and must not be smuggled into this resource. | Confirmed by user review. | confirmed |

### Feedback that changes future scope

- Retrofit every existing runnable playground example to extend `ExamplePlayground`, so the shared HiDPI scaling behaviour applies consistently.

### What we learned

- A shared playground foundation only provides a consistent experience after existing demos are deliberately migrated to it.

---

## Phase 7 Review — 2026-08-04

### What worked

- The convenience layer (`Anima.on()` / `Anima.item()`) shipped with full parity to canonical motions across Composer editing, native compilation, reversal, and interruption, confirmed by dedicated parity tests.
- Grid motion propagation covers all 13 planned distance formulas, including a reworked boundary-peel spiral that matches the grid's own rectangle shape after user feedback during hands-on testing.
- Both playground showcases (target-bound and grid) plus a written Motion Composer guide give a developer more than one way to see the new API working.

### What didn't

- The Motion Composer editor dock, while functional and now documented, still wasn't discoverable enough on its own — the user needed a written guide plus, per this review, a hands-on `examples/editor/` showcase before feeling oriented in it.
- The formula/order selectors and the Card recentering behaviour needed several rounds of live UI fixes (selector wrapping, spiral shape, sliding-indicator parity, `CenterContainer`-vs-motion conflict) that only surfaced once the user actually ran the playgrounds in the editor.

### Assumption results

| Assumption | Predicted | Actual | Action |
|-----------|-----------|--------|--------|
| Grid motion defaults to `FROM_TOP`; clockwise and anticlockwise start at 12 o'clock and use the chosen point as their centre. | Existing expectations may require a different default or angular origin. | Confirmed by user review. | confirmed |
| The selected Grid formulas are sufficient for the first Grid motion release. | Further traversal types could require a change to the public Grid authoring surface. | Confirmed by user review. | confirmed |

### Feedback that changes future scope

- Anima v1's easing curve set (34 kinds) is significantly larger than what `AnimaEase.Kind` covers today — restoring parity is now backlogged.
- Anima v1 supported a motion pivot point (`ANIMA.PIVOT`, 9 anchor positions) for scale/rotation transforms; Anima 2 has no equivalent yet — now backlogged as a new capability.
- A hands-on `examples/editor/` showcase for the `addons/anima/editor/` tooling is backlogged; the written guide alone hasn't been enough for the user to feel oriented in the Motion Composer dock.

### What we learned

- A written usage guide for an editor tool is necessary but not sufficient — the user still wanted a runnable, hands-on example after reading it, suggesting editor-tooling discoverability needs both a guide and something to click through.
- Comparing the v2 rebuild against the original v1 feature set surfaces real gaps (easing curves, pivot control) that a phase scoped purely around "convenience API + grid motion" wouldn't otherwise catch.
