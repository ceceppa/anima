# Backlog Ownership Boundary

`mano start` and `mano review` own backlog content and long-lived project continuity.

An item's `Status` says where it stands: `backlog` (open), `in-phase-N` / `in-owner-phase-N` (scoped into a phase), `resolved` (shipped or fixed), `rejected` (no longer wanted — its premise was invalidated). `resolved` and `rejected` are both closed states and neither is scopeable, but they are not interchangeable: recording a rejection as `resolved` claims work was done that never was. Only `mano review` sets `rejected`, only on items the human confirmed, via `backlog.js reject --title "..."`.

Other skills should not edit the backlog except for narrow gap-resolution status updates:
- `mano spec` must run `node _mano/scripts/state.js --spec`; its current-phase item plus spec-gap projection is its only backlog read. After updating the technical specification, it may mark only a fully addressed projected spec-gap item resolved via `backlog.js resolve-gap --type spec-gap --title "..."`.
- `mano rules` must run `node _mano/scripts/state.js --gaps rule-gap`; that projection is its only backlog read. After updating project rules, it may mark only a fully addressed projected item resolved via `backlog.js resolve-gap --type rule-gap --title "..."`.

Neither skill opens `backlog.md`, even when the user asks it to handle backlog gaps; the read-only projection and targeted writer are the complete interface. Skills should not inspect the backlog for general project memory unless their role explicitly owns that context.

## Mid-phase additions

One more narrow exception, for work the human pulls into a phase that is already open and being built:

- `mano stories` may assign an **exact backlog item the user named** to the **already-approved active** phase, via `backlog.js assign --phase [N] --title "..."`, and then write its story. It never chooses items itself, never scopes, and never assigns to a phase that does not already exist and hold approved scope.

This is not a second scoping skill. `mano start` owns assignment because assignment is normally part of *selecting* what a phase contains — a judgement needing approval. When the human names one exact item to add to a phase already in flight, that judgement has been made and stated directly; only the mechanical step remains. `mano start`'s `DECISION: STOP` blocks *advancing to a new phase*, which is a different operation and stays blocked.

Two hard limits:

- **If the addition changes the phase goal, it is not an addition — it is the next phase.** Say so and stop; do not assign, do not write the story. Small phases are what make the review gate meaningful, and quietly growing one to fit new work is how that gate stops meaning anything.
- **Never edit the phase brief to record the change.** The brief belongs to `mano start`. Flag it instead: the phase now contains work its brief does not describe, and `mano review` reads that brief for the phase goal and Assumption Log. Surface it with `⚠ Verify:` so the human can add a line themselves if they want it recorded — use and flag, never edit another skill's artifact.
