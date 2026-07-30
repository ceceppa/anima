# Backlog

<!-- Future work, deferred items, and ideas. -->
<!-- `mano start` owns backlog curation during scoping. `mano review` appends or resolves phase items. `mano spec` / `mano rules` may resolve only exact projected gap items through backlog.js. -->
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
Do not mark items as `in-phase-[N]` until the human has approved that phase scope.
Current-phase implementation work belongs in `phase-brief.md` or the phase's story files, not as checklist tasks in the backlog.
`Source` is optional provenance; omit it when there is no meaningful source.

### [Short title]
- **Type:** bug / refinement / feature / tech-debt / test / spec-gap / rule-gap
- **Source:** Phase [N] / User idea / Review triage / Product brief
- **Context:**
  What it is.
  Why it matters or key detail.
- **Status:** backlog / in-phase-[N] / resolved
