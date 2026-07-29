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
