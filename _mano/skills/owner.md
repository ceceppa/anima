---
name: mano-owner
description: Use to show, set, or clear the local owner slug that opts this repository clone into owner-scoped Mano phases for parallel team work.
---

# `mano owner` — Phase Ownership

Prefix every message with `[mano owner]:`.

This command configures routing; it does not create, rename, migrate, scope, or close a phase.

## Activation

- `mano owner` or `mano owner show` → run `node _mano/scripts/owner.js show`.
- `mano owner <slug>` or `mano owner set <slug>` → run `node _mano/scripts/owner.js set <slug>`.
- `mano owner clear` → run `node _mano/scripts/owner.js clear`.

Relay the script result and stop. If it fails, report the exact error; do not edit Git config or phase folders by hand.

## Contract

- Ownership is opt-in. With no configured slug, all phase-scoped commands keep using legacy `_mano_output/phase-N/` folders and `in-phase-N` backlog statuses.
- With a configured slug such as `alice`, phase-scoped commands use `_mano_output/alice-phase-N/` and `in-alice-phase-N` within that owner's independent number sequence.
- The slug is a stable team handle, not `whoami`, a machine account, or an email address.
- Configuration lives in repository-local Git config (`mano.owner`) and is not committed. Linked worktrees share that value; use `MANO_OWNER` when worktrees need different owners.
- Setting or clearing the owner requires a Git checkout. In a new directory, run `git init` first or use `MANO_OWNER` as a shell-only override. Mano never initializes Git automatically.
- Two people may configure the same slug to hand over or pair on the same phase. Different slugs select independent phase sequences.
- Clearing the slug returns this repository clone to legacy `phase-N` routing. Existing owned folders remain untouched.
- Ownership selects work; it does not provide merge isolation. Teammates still use branches/worktrees and coordinate changes to shared backlog, spec, rules, design, and review files.

## Output

```text
[mano owner]: [script result without its `[mano owner]` prefix]
```
