---
name: mano-track
description: Use to show, set, or clear an optional local work track that groups a person's parallel experiments without replacing Source provenance or phase ownership.
---

# `mano track` — Work Track

Prefix every message with `[mano track]:`.

This optional setting groups a person's related experiments. It does not create an epic, change phase ownership, move existing work, or bypass scope/conflict checks.

## Activation

- `mano track` or `mano track show` → run `node _mano/scripts/track.js show`.
- `mano track "[name]"` or `mano track set "[name]"` → run `node _mano/scripts/track.js set "[name]"`.
- `mano track clear` → run `node _mano/scripts/track.js clear`.

Relay the script result and stop. If it fails, report the exact error; do not edit Git config, backlog items, or phase folders by hand.

## Contract

- Track is opt-in and repository-local (`mano.track`); it is not committed. `MANO_TRACK` overrides it for one shell/worktree.
- Setting or clearing Track requires a Git checkout. In a new directory, run `git init` first or use `MANO_TRACK` as a shell-only override. Mano never initializes Git automatically.
- `Source` remains provenance (document, review, or phase); `Track` is the direction or experiment (for example, `Option B`). Never replace one with the other.
- An active track tags newly imported backlog items and new items from `mano start`'s conversational intake. `mano start` considers only matching-track backlog items and records the track in its approved phase brief. Every review-created item copies that recorded phase track, even if the local setting changes later.
- Track is a candidate filter, not scope authority. Start still requires approval, and stories/dev still stop on phase, artifact, or contract conflicts.
- `mano track clear` affects future commands only. It never removes tracks already recorded in backlog items or phase briefs.

## Output

```text
[mano track]: [script result without its `[mano track]` prefix]
```
