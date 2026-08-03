# Backlog

<!-- Future work, deferred items, and ideas. -->
<!-- `mano start` owns backlog curation during scoping. `mano review` appends, resolves phase items, or rejects items the human confirmed are no longer wanted. `mano spec` / `mano rules` may resolve only exact projected gap items through backlog.js. -->
<!-- `resolved` means shipped or fixed. `rejected` means the item is no longer wanted — its premise was invalidated. Both are closed; neither is scopeable. -->
<!-- You can edit this file directly at any time. -->

## Core Product Principles

<!-- Optional, human-editable. Keep only durable principles that should survive across phases. -->
<!-- These are not tasks. They capture product feel, experience constraints, or values that should influence future scope, stories, review, and implementation decisions. -->
<!-- Add, edit, or remove bullets directly as the product evolves. Keep the wording plain and useful. -->

<!-- Examples (delete this comment block when adding your own):
  - Must feel fast, snappy, and lightweight.
  - Prefer simple flows over advanced configuration.
  - Keyboard-first interactions matter more than visual customization.
-->

## Items

`_mano/scripts/backlog.js` owns the canonical item format. The block below shows the shape it writes — a reference for human readers and direct human edits; skills never hand-write it.

Do not create phase sections such as `Phase 1`, `Complete in Phase`, or `Deferred`.
Do not use checkbox task lists.
Do not stamp the current phase status until the human has approved that exact phase scope. Default mode uses `in-phase-N`; owner opt-in uses `in-owner-phase-N`.
Current-phase implementation work belongs in `phase-brief.md` or the phase's story files, not as checklist tasks in the backlog.
`Source` is optional provenance; omit it when there is no meaningful source.

### [Short title]
- **Type:** bug / refinement / feature / tech-debt / test / spec-gap / rule-gap
- **Source:** [PHASE_ID] / User idea / Review triage / Product brief
- **Context:**
  What it is.
  Why it matters or key detail.
- **Status:** backlog / in-phase-N / in-owner-phase-N / resolved / rejected
