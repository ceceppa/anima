<!-- MANO:BEGIN -->
# AGENTS.md

**Languages.** Before responding or writing project content, run `node _mano/scripts/settings.js language` from the project root and use the returned `language.chat`, `language.build`, and `language.artefacts` values. The script resolves the selected owner, environment override, defaults, and validation. Never read settings JSON files directly or infer these values yourself. Re-run after changing owners or language settings. If the command fails, report the error and stop instead of guessing. `language.chat` controls conversation only: explanations, questions, progress updates, and hand-backs. `language.artefacts` controls new planning prose: briefs, specs, rules, UX flows, design briefs, stories, backlog entries, reviews, and ledger prose. `language.build` controls new implementation content: product documentation, code identifiers and comments, tests, and product/UI text, including preview copy. Values may be language names or locale tags, e.g. `{"chat":"it","build":"en-GB","artefacts":"it"}` means Italian conversation and planning artifacts, with UK English implementation content. For missing or `null` `artefacts`, the command falls back to `build`, then `chat`, then `null`; use that resolved value. Missing or `null` `chat` and `build` preserve existing language behaviour independently. If all three are unset, planning artifacts also keep existing behaviour. Keep commands, paths, schema keys, required headings/status labels, external API names, and exact human quotations unchanged. Do not translate existing files or completed stories merely because the language setting changed. These preferences apply to every Mano action, including configuration and implementation. Run the language command at every skill activation, auto-chain handoff, and resumption after interruption or compaction, before the first user-facing message or project write. Before sending each message, check its prose against `language.chat`; before each write, check planning prose against `language.artefacts` and implementation content against `language.build`. English output examples, even “exact” one-line responses, specify structure and meaning; translate their prose into `language.chat` while retaining required labels, commands, paths, status tokens, and verbatim diagnostics. Do not let the build or artefacts language determine the conversation language.

This project uses **Mano** for planning. Mano is a structured thinking tool: almost every command produces planning artifacts rather than code. The exceptions are deliberate — `mano dev` and `mano build` implement what a phase's planning already decided, and `mano task` implements one backlog item outside any phase.

## For coding agents

### Running Mano commands

Mano commands are repo-local workflow instructions, not installed OpenCode skills.

If the user types a Mano command in chat, do **not** try to load an external skill named `mano`.

Instead, execute the corresponding Mano planning flow by reading the local files in this repository:

- `_mano/skills/[command].md` — the skill file for that command; its front-matter names the `_mano/rules/` files it requires
- any referenced templates or current `_mano_output/` artifacts
- `_mano/workflow.md` — only for the bare `mano`, `mano help`, `mano status`, and `mano continue` commands; skills name their own rule files and never need the whole workflow

Examples:

- `mano import` → read `_mano/skills/import.md` and follow that flow (PRD/document → backlog)
- `mano start` → read `_mano/skills/start.md` and follow that flow
- `mano spec` → read `_mano/skills/spec.md` and follow that flow
- `mano rules` → read `_mano/skills/rules.md` and follow that flow
- `mano stories` → read `_mano/skills/stories.md` and follow that flow
- `mano review` → read `_mano/skills/review.md` and follow that flow
- `mano dev` → implement the next pending story; read `_mano/skills/dev.md` plus `_mano/rules/implement.md` and follow the complete contract in those files
- `mano build` → build the active phase straight from its brief, with no story files; read `_mano/skills/build.md` plus `_mano/rules/implement.md` and follow the complete contract in those files
- `mano task "[item title or what you want]"` → implement one item with no phase; read `_mano/skills/task.md` and follow its complete contract. It writes or clarifies the backlog item before any code, and is refused while a phase is open
- `mano continue` → read `_mano/workflow.md`; it dispatches the projection's `CONTINUE_ACTION:`, preserving the approved `CHAIN_REMAINING` order in auto before implementation; outside an armed chain it runs `mano build`, `mano dev` for one story, or one unambiguous planning action — it never prints a card telling the human to type the command they just typed
- `mano mode [auto|manual]` → read `_mano/skills/mode.md`; show or set whether finished actions chain automatically
- `mano track [name]` → read `_mano/skills/track.md`; show, set, or clear the optional local experiment/work track
- `mano language [chat|build|artefacts] [language] ...` → read `_mano/skills/language.md`; show, set, or clear the conversation, implementation, and planning-artifact languages

Note: `mano dev`, `mano build`, and `mano task` are the Mano commands that produce code. Every other command above is planning only. `mano task` is self-contained in `_mano/skills/task.md`, works one backlog item when no phase is open, and is never started by auto mode or `mano continue`. Once the human has typed it in auto mode, it may run the owner of a missing value or flow and resume the item. Their contracts live in `_mano/skills/dev.md` and `_mano/skills/build.md`, both of which require the shared `_mano/rules/implement.md`. A phase uses one of the two, never both: `mano dev` implements stories from `stories/README.md`, `mano build` works the Scope rows of `PHASE_DIR/progress.md`.

**Run mode.** Every `state.js` projection prints `MODE: manual|auto`. In `manual` (the default) each command hands back when it finishes. In `auto`, after the human has approved a phase scope, each finished action runs the next one automatically through to `mano build` (or `mano dev yolo` only when the phase already has a stories index) — but it pauses for **any** question (a `❓ Decide:`, a clarifying question, an ambiguous next action, hook findings, a gate or blocker) and **never runs `mano review` or scopes a new phase**. Auto mode changes who types the next command; it never changes what a skill may write or which decisions are the human's. The narrative contract is `_mano/workflow.md` → **Run Mode: manual and auto**; the mid-chain execution rules are `_mano/rules/auto.md`, loaded only when the projection reports `MODE: auto`.

**Continuing the chain means invoking the next action in the same turn — never announcing it.** Ending a turn on "Continuing — running `mano ui` next" stops the chain while claiming to continue it. Mid-chain, omit the `Next:` block (nobody is typing a command); it returns only in the closing block, on the action that actually ends the chain. Every hand-back names its pause condition; a chain that stops without naming one is a bug.

**`mano build` runs to completion, in both modes.** It is `mano dev yolo` with no opt-in word: one invocation goes from wherever the ledger stands to the phase's terminal line. Creating the ledger, passing pre-flight, and closing a pass are things that happen inside that run — never things the run is finished having done. A build that reports its new ledger and hands back has written a file and built nothing.

If a platform skill named `mano` is not available, that is not an error. Continue by using the local `_mano/` files.

**Write for humans.** Every Mano skill follows `_mano/rules/artifact.md` → **Plain-language contract**. Apply it to chat and artifact prose. Assume a teammate has no prior context.

The skill name uses a **hyphen, never a colon**: `mano import` → `mano-import` (read `_mano/skills/import.md`), not `mano:import`. The colon form is plugin-namespace syntax and matches no Mano skill. If a `mano <action>` seems unavailable, try the hyphenated `mano-<action>` before concluding it doesn't exist.

Only use external/platform skills when the user explicitly invokes them or an active Mano hook authorizes the review: explicit confirmation for a suggest hook in manual or unarmed runs, or the automatic suggest-hook rule during an armed auto chain. Running the review never authorizes applying its findings.

### Implementing a story

`mano dev` implements the next pending story. Its full contract is `_mano/skills/dev.md`, plus the shared
`_mano/rules/implement.md`.
**Read those files completely before writing any code for a Mano story** — including when the user asks in plain
words. Do not implement from a story file alone. Two rules apply even before you read them:
- The index `Status` column is the only done-signal — a story's number, letter, or title grants no exemption.
- `Not this story` is a hard boundary — implement none of it, whatever the chosen type or library default implies.

### Building a phase

`mano build` is the other implementation path: no story files, the brief's own numbered `## Phase Scope` items
are the units, and `PHASE_DIR/progress.md` is the ledger. Its full contract is `_mano/skills/build.md`, plus the
same `_mano/rules/implement.md`. Three rules apply even before you read them:
- The ledger is written only by `_mano/scripts/progress.js` — never by hand, and never with rows you composed.
- `Not this phase` in the brief is a hard boundary. Once the ledger exists the brief is frozen: an in-goal
  correction is a row inside `mano build`, a distinct outcome goes to the backlog or the next phase, and
  neither goes back through `mano start`.
- `mano build "[what changed]"` is a mid-phase correction, not new scope, and only a phase that already has a
  valid ledger accepts one. The exact wording is the human's — never paraphrase it.

### Which implementation entry

Decide by **validated state, then mode** — never by which path is more familiar:
- either ledger invalid, or a phase holding both → refuse and report;
- a pending rework event, an open Scope row, or an unresolved deviation → `mano build`;
- an incomplete stories ledger → `mano dev`; a complete one → `mano review`;
- a `progress.md` with every Scope leaf `done` and every Exit leaf `met` or `needs-human` → `mano review`;
- no ledger at all → for a new chain the mode decides: `auto` ends at `mano build`, `manual` offers `mano stories` first and
  `mano build` second.
This selects implementation, not permission to skip planning. In auto, `CONTINUE_ACTION` preserves the approved `CHAIN_REMAINING` order, with `stories` removed and terminal `dev` replaced by `build` when neither ledger exists. Auto never runs `mano stories`. A conflict with an existing ledger pauses for reconciliation.
The narrative contract is `_mano/workflow.md` → **Implementation entry**.

### Completed stories are immutable

A story whose Status is `done` is historical record. Never edit its file — not for typos, not mid-conversation,
not from any `mano` action. A fix, update, or new scope touching shipped work is new work: run
`mano stories "[what changed]"` (it inserts the lettered follow-up per its own numbering rule), then `mano dev`
implements it. Stories are logs; `tech-spec.md`, `project-rules.md`, `design-brief.md`, `ux-flow.md` are living
documents — those update in place.

### Do not

- Modify files in `_mano/` or `_mano/templates/` — these are framework files.
- Interpret `mano` commands (e.g. `mano start`, `mano review`) as implementation instructions — these are planning commands. Execute the relevant planning flow instead.
- Create extra tracking files — the framework specifies exactly two ledgers, `PHASE_DIR/stories/README.md` and `PHASE_DIR/progress.md`, each written only by its own script. There is no third state file to invent. Determine state through `_mano/scripts/state.js`, which applies the optional local owner configuration and returns exact paths.
- Auto-advance phases. A completed phase (every story `done`, or every ledger row `done` and every exit criterion `met`) never triggers planning or implementing the next one. Stop and let the user decide; never run `mano start`/`mano stories` on your own initiative.

## Project structure

```
_mano/                    ← Mano framework (do not modify during implementation)
├── skills/               ← Mano skill prompts
├── rules/                ← shared rule fragments; skills name the ones they require
├── scripts/              ← state.js (read-only state projection), backlog.js / stories.js / progress.js (ledger writers), chain.js (records chain actions the human struck)
├── hooks/                ← optional post-skill hooks
└── templates/            ← Mano templates
_mano_output/             ← Planning artifacts
├── project-rules.md      ← Rules for implementation (referenced by stories)
├── tech-spec.md          ← Technical decisions
├── ux-flow.md            ← Screen and navigation definitions
├── design-brief.md       ← Canonical cumulative visual language
├── backlog.md            ← Future work and deferred items
├── reviews.md            ← Sprint review history (human-only)
├── phase-[N]/            ← Default/legacy per-phase work
└── [owner]-phase-[N]/    ← Optional owner-scoped per-phase work
    ├── phase-brief.md    ← Phase scope and goals
    ├── design-preview.html ← Non-canonical UI snapshot for this phase
    ├── progress.md       ← `mano build` ledger: scope rows + exit criteria
    └── stories/          ← Implementation stories (the other ledger; start here on that path)
```

## Context Discipline

Roles in Mano are reasoning lenses, not isolated autonomous agents.

Specialization is maintained through selective context exposure and user discipline. Models may still merge assumptions or infer information outside the intended scope.

Use each role to focus attention on a specific planning concern rather than assuming strict separation.

## Post-Skill Hooks

After completing a Mano skill, check the state projection's `HOOK:` line. `HOOK: none` means no hook applies — skip this entirely. When it names an active `post-[skill]` hook, follow `_mano/rules/hooks.md`. Ignore `.example.md` hooks.

A hook's `## Mode` decides how it runs. `check` is a checklist Mano applies itself, automatically, in both modes, right after the skill's artifacts are written — no confirmation; findings still go through triage. `suggest` (the default) points at an external skill/command and is never run automatically in manual mode or an unarmed run — ask first; during an armed auto chain it runs automatically. `command` names one shell command and **always runs, in both modes**: the hook file is the authorization, so do not ask; report it in one line of the execution log, take the command only from the hook file, and on failure report the exact error without retrying, fixing the user's script, or hand-editing artifacts to compensate. Full contract: `_mano/rules/hooks.md`.

When any just-run `suggest` or `check` hook has printed findings, keep the related
Mano skill active and follow `_mano/rules/hooks.md` → **Post-Hook Findings Triage**.
`post-stories` uses its dedicated immutable-story protocol. Running the hook did
not approve edits. An in-lane finding is `apply`, never a route back to the skill
already running; a finding owned by another artifact is `route: mano [owner]`
and must not be edited here. Apply the smallest selected change within the
per-skill application boundary. Preserve unmentioned content and
adjacent values.

Do not mention specific third-party or external skill names in generic Mano output.

Do not execute a `suggest` hook without explicit user confirmation in manual mode or an unarmed run. An armed auto chain is the explicit exception defined by `_mano/rules/hooks.md`.

Do not write hook suggestions into generated artifacts.
<!-- MANO:END -->
