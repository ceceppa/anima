# post-start hook

## Mode
check

## Inputs
- `_mano_output/backlog.md`
- the exact `BRIEF` path from the state projection — the brief this run just wrote; absent only when the run stopped before the phase-approval gate
- `_mano_output/reviews.md`, if it exists

## Checklist

- Backlog structure and item statuses are accurate after this run.
- The phase scope carries no obvious risk the brief leaves unstated.
- No backlog item is missing or over-broad for the approved scope.
- Core Product Principles survived unchanged unless the user changed them.
- The brief does not contradict the source conversation or document.
- Every added or modified piece of code has an explicit documentation plan appropriate to it, such as public API comments and reference documentation or developer-facing implementation notes. This may be deferred only when the phase's explicit outcome is to determine whether a high-risk API or function can be implemented; code using an API or function already known to work is not exempt.
- The phase scope includes the right demo coverage for the work it introduces.
- Runtime-facing work includes a playground demo under `examples/playground/` when that is the appropriate way to exercise it.
- Editor-facing work includes an editor demo under `examples/editor/` when that is the appropriate way to exercise it.
- Any phase that introduces a new or changed runtime or editor capability has a matching example or demo plan.
- Every example or demo containing code for an API or function already known to work is paired with a tutorial that explains how to build or use it, rather than leaving the example unexplained. A feasibility example or demo may defer its tutorial only when the phase's explicit outcome is to determine whether a high-risk API or function can be implemented.
