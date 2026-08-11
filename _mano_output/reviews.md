# Phase Review — Anima

<!-- Always append new phase entries at the bottom of the file. Never insert between existing entries. -->
<!-- For follow-up fix work on an already-reviewed phase, append an ### Addendum subsection to the existing phase entry — do not create a new ## heading. -->

---

## Phase 14 Review — 2026-08-11

### Evidence

- **Status:** partial
- **Method:** Not recorded
- **Observed:** Several `Anima.on`/`Anima.grid` API calls behave unexpectedly or are missing when used directly in code (chaining, `with_ease`, delay/lifecycle hooks, pivot naming, `.play()`)

### Assumption results

| Assumption | Outcome | Evidence / consequence |
|-----------|---------|------------------------|
| Dynamic values resolve once, implicitly, at motion start. | confirmed | |
| Combining dynamic values arithmetically is distinct from reuse-on-reversal (deferred). | confirmed | |

### Backlog changes

- [bug] Anima.on() chain does not expose .play() — added
- [bug] Chained motions via .with() do not play correctly — added
- [refinement] Simplify pivot API naming — added
- [refinement] Anima.on missing with_delay — added
- [refinement] Anima.grid missing on_started/on_completed callbacks — added
- [refinement] Anima.grid missing with_delay — added
- [refinement] with_ease should accept AnimaEase.Kind directly on Anima.on — added
- [feature] Convenience fade_out on Anima.on — added
- [feature] Convenience fade_in on Anima.on — added
