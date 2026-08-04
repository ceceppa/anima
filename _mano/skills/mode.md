---
name: mano-mode
description: Use to show or set whether finished Mano actions chain automatically through to implementation (auto) or hand back after each command (manual, the default).
---

# `mano mode` — Run Mode

Prefix every message with `[mano mode]:`.

This command configures how commands hand off; it does not create, scope, implement, or close anything.

## Activation

- `mano mode` or `mano mode show` → run `node _mano/scripts/mode.js show`.
- `mano mode auto` / `mano mode manual` (or the `set` form) → run `node _mano/scripts/mode.js set <mode>`.
- `mano mode clear` → run `node _mano/scripts/mode.js clear`.

Relay the script result and stop. If it fails, report the exact error; do not edit Git config by hand.

## Contract

- `manual` is the default. Every existing project keeps its current behaviour, and a missing or unreadable setting is never an opt-in.
- `auto` chains actions after an explicit human approval of a phase scope, ending at implementation. It pauses for any question and never runs `mano review`.
- The mode changes *who types the next command*. It never changes what a skill produces, what it may write, or which decisions belong to the human.
- Configuration lives in repository-local Git config (`mano.mode`) and is not committed — it records how much this person reviews, not a property of the project. Never commit it to a shared file, and never infer it from the project's contents or history.
- `MANO_MODE` overrides Git config for a shell or worktree.
- The full contract — arming, the pause rule, hook behaviour, and the closing block — lives in `_mano/workflow.md` → **Run Mode: manual and auto**. That is authoritative; this file only sets the value.

## Output

```text
[mano mode]: [script result without its `[mano mode]` prefix]
```
