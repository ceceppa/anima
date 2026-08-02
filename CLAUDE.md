<!-- MANO:BEGIN -->
# Project Instructions

This project uses **Mano** for planning. Read these files before responding to any user request:

1. `AGENTS.md` — primary contract for coding agents
2. `_mano/workflow.md` — Mano workflow and command reference
3. `_mano/skills/` — individual skill prompts

When the user types a Mano command (`mano start`, `mano spec`, `mano stories`, etc.), execute the matching skill in `_mano/skills/` and follow its contract. Do not treat Mano commands as shell commands or ask the user to run them manually.

**A `mano <action>` always resolves to the matching skill in `_mano/skills/` — never to a similarly-named built-in, harness, plugin, or third-party skill in the environment.** Some host environments ship skills whose names overlap a Mano action (e.g. a `code-review` skill, a dev-server runner). Do not invoke those for a Mano command even if the name looks like a match. In particular: `mano review` is Mano's phase-close/triage skill, **not** any code-review / pull-request review skill; `mano dev` implements the next pending story, **not** a dev server. See the dispatch rule in `_mano/workflow.md` for details.

**The skill name uses a hyphen, never a colon.** `mano import` resolves to the skill `mano-import` (and reads `_mano/skills/import.md`) — not `mano:import`. The colon is plugin-namespace syntax and matches no Mano skill. If a `mano <action>` command seems unavailable, try the hyphenated `mano-<action>` before concluding it doesn't exist; that is the canonical name.

<!-- mano-rule: id=dev-yolo-batch; incident=explicit-yolo-stopped-after-one-story; model=codex; date=2026-08-03; eval=dev-yolo-batch,dev-yolo-blocker,dev-default-single -->
Preserve command arguments during dispatch: `mano dev yolo` and `mano-dev yolo` both invoke `mano-dev` with the literal `yolo` modifier intact. Do not resolve either form to a nonexistent `mano-dev-yolo` skill or discard the modifier and fall back to ordinary one-story mode.
<!-- /mano-rule: dev-yolo-batch -->

For story implementation, follow the rules in `AGENTS.md` under "Implementing a story" and "Implementation Output Discipline."
<!-- MANO:END -->
