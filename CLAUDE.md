<!-- MANO:BEGIN -->
# Project Instructions

This project uses **Mano** for planning. Read `AGENTS.md` (the primary contract for coding agents) before responding to any user request.

When the user types a Mano command (`mano owner`, `mano track`, `mano start`, `mano spec`, `mano stories`, etc.), dispatch straight to the matching skill in `_mano/skills/` and follow its contract: read the skill file plus exactly the `_mano/rules/` files its front-matter requires, and nothing else. Read `_mano/workflow.md` only for the bare `mano`, `mano help`, `mano status`, and `mano continue` commands. Do not treat Mano commands as shell commands or ask the user to run them manually.

**A `mano <action>` always resolves to the matching skill in `_mano/skills/` — never to a similarly-named built-in, harness, plugin, or third-party skill in the environment.** Some host environments ship skills whose names overlap a Mano action (e.g. a `code-review` skill, a dev-server runner). Do not invoke those for a Mano command even if the name looks like a match. In particular: `mano review` is Mano's phase-close/triage skill, **not** any code-review / pull-request review skill; `mano dev` implements the next pending story, **not** a dev server. See the dispatch rule in `_mano/workflow.md` for details.

**The skill name uses a hyphen, never a colon.** `mano import` resolves to the skill `mano-import` (and reads `_mano/skills/import.md`) — not `mano:import`. The colon is plugin-namespace syntax and matches no Mano skill. If a `mano <action>` command seems unavailable, try the hyphenated `mano-<action>` before concluding it doesn't exist; that is the canonical name.

Preserve command arguments during dispatch: `mano dev yolo` and `mano-dev yolo` both invoke `mano-dev` with the literal `yolo` modifier intact. Do not resolve either form to a nonexistent `mano-dev-yolo` skill or discard the modifier and fall back to ordinary one-story mode.

The same holds for `mano build "[what changed]"`: the quoted text is a mid-phase correction the skill classifies itself, and its exact wording is the human's contract. Pass it through verbatim — never paraphrase it, tidy it, or drop it.

For implementation, follow the rules in `AGENTS.md` under "Implementing a story" (`mano dev`) or "Building a phase" (`mano build`). Both read the shared `_mano/rules/implement.md`, which owns the gap gates, the acceptance-evidence gate, Repair Mode, the read budget, and Implementation Output Discipline.
<!-- MANO:END -->
