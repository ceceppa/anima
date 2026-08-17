<!-- MANO:BEGIN -->
# AGENTS.md

This project uses **Mano** for planning. Mano is a structured thinking tool — it produces planning artifacts, not code.

## For coding agents

### Running Mano commands

Mano commands are repo-local workflow instructions, not installed OpenCode skills.

If the user types a Mano command in chat, do **not** try to load an external skill named `mano`.

Instead, execute the corresponding Mano planning flow by reading the local files in this repository:

- `_mano/workflow.md`
- `_mano/skills/[command].md`
- any referenced templates or current `_mano_output/` artifacts

Examples:

- `mano import` → read `_mano/skills/import.md` and follow that flow (PRD/document → backlog)
- `mano start` → read `_mano/skills/start.md` and follow that flow
- `mano spec` → read `_mano/skills/spec.md` and follow that flow
- `mano rules` → read `_mano/skills/rules.md` and follow that flow
- `mano stories` → read `_mano/skills/stories.md` and follow that flow
- `mano review` → read `_mano/skills/review.md` and follow that flow
- `mano dev` → implement the next pending story; read `_mano/skills/dev.md` and follow the "Implementing a story" contract below
- `mano continue` → read `_mano/workflow.md` and determine the next useful Mano action
- `mano mode [auto|manual]` → read `_mano/skills/mode.md`; show or set whether finished actions chain automatically
- `mano track [name]` → read `_mano/skills/track.md`; show, set, or clear the optional local experiment/work track

Note: `mano dev` is the one Mano command that produces code. Every other command above is planning only. `mano dev` runs the "Implementing a story" contract in this file; `_mano/skills/dev.md` is a thin pointer back here.

**Run mode.** Every `state.js` projection prints `MODE: manual|auto`. In `manual` (the default) each command hands back when it finishes. In `auto`, after the human has approved a phase scope, each finished action runs the next one automatically through to `mano dev yolo` — but it pauses for **any** question (a `❓ Decide:`, a clarifying question, an ambiguous next action, hook findings, a gate or blocker) and **never runs `mano review` or scopes a new phase**. Auto mode changes who types the next command; it never changes what a skill may write or which decisions are the human's. The full contract is `_mano/workflow.md` → **Run Mode: manual and auto**.

**Continuing the chain means invoking the next action in the same turn — never announcing it.** Ending a turn on "Continuing — running `mano ui` next" stops the chain while claiming to continue it. Mid-chain, omit the `Next:` block (nobody is typing a command); it returns only in the closing block, on the action that actually ends the chain. Every hand-back names its pause condition; a chain that stops without naming one is a bug.

If a platform skill named `mano` is not available, that is not an error. Continue by using the local `_mano/` files.

**Write for humans.** Every Mano skill follows `_mano/workflow.md` → **Plain-language contract**. Apply it to chat and artifact prose. Assume a teammate has no prior context.

The skill name uses a **hyphen, never a colon**: `mano import` → `mano-import` (read `_mano/skills/import.md`), not `mano:import`. The colon form is plugin-namespace syntax and matches no Mano skill. If a `mano <action>` seems unavailable, try the hyphenated `mano-<action>` before concluding it doesn't exist.

Only use external/platform skills when the user explicitly invokes them or an active Mano hook authorizes the review: explicit confirmation for a suggest hook in manual or unarmed runs, or the automatic suggest-hook rule during an armed auto chain. Running the review never authorizes applying its findings.

### Implementing a story

This is the contract for `mano dev` — the sanctioned path from a finished `stories/` folder into code. When the user wants to implement, this is the section to follow. `_mano/skills/dev.md` only points here; the steps below are authoritative.

<!-- mano-rule: id=dev-yolo-batch; incident=explicit-yolo-stopped-after-one-story; model=codex; date=2026-08-03; eval=dev-yolo-batch,dev-yolo-blocker,dev-default-single -->
### Execution modes

- **Default — one story.** `mano dev` / `mano-dev` implements the next pending story, marks it done, outputs the step 12 line, and stops.
- **Explicit YOLO batch.** Only a literal trailing `yolo` in `mano dev yolo` or `mano-dev yolo` activates this mode. At the first `state.js --next` read, snapshot the exact `OWNER` + `PHASE_ID` and every row whose Status is not `done`. Implement exactly that snapshot sequentially in index order during this turn. Do not absorb stories added later, cross into another phase or owner namespace, or infer YOLO mode from phrases such as "keep going" or "finish it".

For each snapshotted story, follow steps 6–11 as its own AC-bounded implementation: read that story fresh, honour its dependencies and `Not this story` boundary, perform the required verification, and mark only that story `done` immediately. Then rerun `node _mano/scripts/state.js --next`; continue only when `OWNER` and `PHASE_ID` are unchanged and the reported next pending row is the next snapshotted story. Defer step 12 chat output until the batch finishes.

**`yolo` is an execution-count override, not a scope or safety override.** It does not waive story order, acceptance criteria, project rules, required verification, gap stops, script-failure stops, or any prohibition. Stop at the first blocked or failed story: keep earlier completed rows `done`, leave the current and later rows pending, do not skip or roll back, and report the blocker plus any partial edits. YOLO grants no authority beyond ordinary `mano dev`: story-required implementation actions remain allowed, but it never commits, pushes, runs `mano review`, or starts another phase merely because `yolo` was supplied.
<!-- /mano-rule: dev-yolo-batch -->

1. **Find what to implement by running the state script — do not `ls` for the phase or infer it from the conversation.** Run `node _mano/scripts/state.js --next`. It reads the filesystem *this turn* and reports `MODE`, the selected `OWNER`, exact `PHASE_ID`, numeric `PHASE`, next pending story (`STORY:` / `FILE:`), and full ordered story list. If `MODE` or any routing field is absent, stop and report the malformed projection. Obey its `OWNER`/`PHASE_ID`/`STORY`/`FILE`; never construct `phase-N` from the number. With no owner configured, the projection preserves legacy `phase-N` routing. If it reports nothing to implement, follow the line it prints and stop. **If the script cannot run, stop and report the exact failure — do not scan for the phase by hand or guess it from context.** Refresh `MODE` on every later state read; a change affects the handoff after the current safe unit, not story routing.
2. The script's `Stories` block is the exact active phase's stories index, normalized — it already applies "Status is the only signal" and marks the next pending row with `→`. Use it for steps 3–5; do not open another owner or phase index.
3. **Hard stops.** If every story in the index is already `done`, STOP. Do not start, scope, or plan a new phase. All stories being done means the phase is built, not closed: `mano review` is mandatory before `mano start` can scope another phase. Output one line stating that the phase is built and must be closed with `mano review`, then stop. Do not call the phase complete or present `mano start` as an equal option. If a user-requested story does not exist but other rows are still pending, stop and say the requested number was not found; name the actual next pending story from the state output. Do not describe that phase as built or complete. These are hard stops, not guidelines.

   **The `Status` column is the only signal — read it, do not interpret around it.** A story is implementable if and only if its Status is not `done` (e.g. `pending`). This decision is made *purely* from the Status column. A story's number, letter, title, or description carries **no** authority over whether it is in scope:
   - There is no "refinement", "extra", "optional", "addendum", or "follow-up" class of story that the user must separately ask for. If a row is in the index and not `done`, it is in scope. Never invent such a category to justify stopping.
   - A lettered story (`4a`, `4b`) is **not** a sub-part of a done story `4` that inherits its done-ness. It is its own ordered, pending work. Letters and numbers are ordering only, never a done-ness signal.
   - "The core stories are done" / "the main work is finished" is **not** a stop condition. The only stop condition is *every row is `done`*. If even one row has another Status, the phase is not done — follow the next row reported by state; do not announce the phase complete.
   - Before stating that implementation is built, count the rows whose Status is not `done`. If that count is greater than zero, it is not built — implement the next pending row. If the count is zero, say built but not closed; only `mano review` makes the phase complete.
4. Before implementing the requested story, check whether any earlier story in the index has a Status other than `done`. Treat numbered stories and lettered insertions as ordered work unless the README or story notes explicitly say otherwise.
5. If an earlier story is not `done`, stop and tell the user which story would be skipped. Do not implement the later story unless the user explicitly confirms they want to bypass the suggested order.
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
6. Read the story file first. Treat it as the primary implementation contract and expect it to be sufficient for correct implementation. The Implementation Reference section should carry the applicable rules plus any required files, modules, contracts, constraints, ownership boundaries, and prohibitions for that story. Treat exact prop names, attribute names, variant names, state keys, ownership statements, file paths, dependency names, and install commands written there as normative. **Open every artifact section explicitly named by the Implementation Reference before writing code**; a pointer means the story intentionally left that shared contract at its canonical home. If the named section is absent or does not define an exact consumer-visible public/package or independently-owned cross-component contract the story requires—operation names, input/default shapes, result/failure behavior, or semantic mappings—stop and route the gap to `mano spec`. A section title or broad capability list is not a usable contract.
<!-- /mano-rule: public-interface-contract-readiness -->
<!-- mano-rule: id=public-interface-contract-readiness; incident=public-api-contract-reached-dev-undefined; model=codex; date=2026-08-03; eval=spec-public-interface-completeness,stories-public-interface-gap -->
6.1 **Final-story phase-contract gate.** If the selected story is the last row whose Status is not `done`, run this gate before changing code. Read the exact projected phase brief and every story file listed by the projected index. Map every distinct Phase goal outcome and every Exit Criterion—including each nested action/result bullet—to a concrete `Done when` AC. The AC must exercise the same user/caller route and breadth: reaching the same internal result through another API, command, screen, or non-terminal fluent path is not equivalent. For a composed fluent promise, the AC must contain the composition and terminal call in the same path, and its cited canonical spec section must define that exact chain through every returned type.

If any goal element or Exit Criterion lacks exact AC ownership, stop before implementation, leave this and later rows pending, and name the missing path. Route it to `mano stories "add coverage for [missing phase path]"`; if the missing path also lacks a canonical public/shared contract, route `mano spec` first. Do not reinterpret a broad phase promise to fit the existing stories, and do not use a `Not this story` boundary to waive it. In YOLO mode, earlier checkpointed stories stay `done`; this gate still applies before the final snapshotted story.
<!-- /mano-rule: public-interface-contract-readiness -->
6.2 **Spec-owned default gap.** If the story or its cited phase Exit Criterion needs a starting state, first-use state, capacity, radius/range, count, duration, threshold, spawn amount, or other behaviour-driving default, the named canonical spec section must state the owning field/config/constant and exact value or relationship. A vague phrase such as “small area” is not an implementation value. Stop and route to `mano spec` when it is missing; do not choose a “story-owned default,” add a temporary literal, or treat a test fixture as the product default.
6.3 **Player-choice UX gap.** If the story lets a player choose among two or more simultaneously available tools, buildables, abilities, modes, rewards, or alternatives, the cited UX flow must define how the player invokes the choice, selects/changes the active option, sees that active state, and receives locked/unavailable/cancel feedback. If it does not, stop and route to `mano ux`; do not invent a hotkey, picker, cycling scheme, default active item, or HUD treatment while implementing.
6.4 **Phase-scope conflict.** Before changing code, compare the story and any user-requested behaviour change with the exact projected phase brief's `Phase goal`, `Phase scope`, and `Not this phase`. Work that directly supports an existing outcome can proceed. A distinct outcome, or anything the brief explicitly excludes, is outside this phase: stop before code. Do not treat “do it anyway” as permission to leave the brief stale. Ask the human to either defer it to the backlog/next phase or amend the phase brief to include it, then rerun `mano stories` to create or update the bounded story. This gate applies in default, YOLO, and auto mode.
7. If the story is bootstrap, setup, tooling, infrastructure, or dependency-related, also read `_mano_output/tech-spec.md` before implementing. Treat library choices, package-manager choice, and install commands there as normative unless the story file already repeats them exactly.
8. Execute install commands exactly as written. Do not merge separate command groups, switch tools, or normalize mixed-tool instructions into a single package-manager invocation unless the story or tech spec explicitly tells you to. In particular, keep `npx expo install` commands separate from `npm install` or other package-manager commands so Expo can resolve SDK-compatible versions.

   **Greenfield scaffold safety is a hard stop.** A project generator that creates an application root or requires an empty destination may run only through the exact guarded command in `_mano_output/tech-spec.md §Project Scaffold`: `node _mano/scripts/scaffold.js run ... -- ... {target}`. Never aim a raw generator at `.`, the project root, or a temporary child that you later merge by hand. Never move, rename, delete, or temporarily hide existing files to make the root look empty—especially `_mano`, `_mano_output`, `.git`, `AGENTS.md`, `CLAUDE.md`, or `.cursorrules`. Do not substitute `cp`, `mv`, `rsync`, or a hand-written merge. If the guarded command is absent, malformed, fails, or reports a collision, stop and report it; route an absent/malformed command to `mano spec`, and never improvise around a runner failure. `yolo` and auto mode do not relax this rule.
9. If the story involves user-entered state, forms, onboarding drafts, settings, or other local data, check whether the story or tech spec says that data should persist across app restarts. If it should, treat restart persistence as part of the required behaviour, not as an optional enhancement.
10. Read `_mano_output/project-rules.md` only when the story explicitly points to a rule there, something remains ambiguous after reading the story and any mandatory tech-spec pre-read, or you need fuller context behind a rule already summarized in the story.
<!-- mano-rule: id=phase-acceptance-integrity; incident=exit-criterion-tested-in-reverse; model=codex; date=2026-08-13; eval=pending -->
10.1 **Acceptance-evidence gate — before status may become `done`.** After implementation and verification, reread the selected story's complete `Done when` section. For every AC, identify concrete evidence from this turn that the stated outcome occurs through the stated route. A passing suite is not enough when no test/manual check exercises that AC. Any assertion, fixture expectation, comment, skipped test, or observed result that states the opposite outcome—success expected as failure, recoverable expected as locked, available expected as unavailable—is proof the story is **not done**, even if the suite is green.

When an AC cannot be satisfied because current code or a cited artifact deliberately preserves the opposite behaviour, stop before step 11, leave the row pending, and report the contradiction. Route a planning-contract contradiction to `mano spec`/`mano stories` as appropriate; do not rewrite the AC's meaning, invert the test, call the opposing behaviour intentional, or mark the story done with a deviation. For an AC that is inherently visual or experiential, perform the narrow available manual/runtime check; if that cannot be run, report the unverified AC and leave the story pending.
<!-- /mano-rule: phase-acceptance-integrity -->
11. After implementing, mark the story `done` via the index writer — do **not** hand-edit the README table:
    ```
    node _mano/scripts/stories.js set-status --phase [N] --story [num] --status done
    ```
    `[N]` is the numeric `PHASE` from the same state projection and `[num]` is the story's `#` in the index (`4`, or `4a`). The writer independently resolves the configured owner, so if ownership changed since step 1 it must fail or target a different identity; rerun `state.js --next` immediately before this command and stop unless `OWNER` and `PHASE_ID` still match. The script must report that the exact requested row changed to `done` or was already `done`; a missing row is a failure and writes nothing. After the writer succeeds, rerun `state.js --next`. Confirm that `OWNER` and `PHASE_ID` are unchanged and the completed row now appears as `done` in the ordered Stories block. Stop without claiming completion if either postcondition fails. Do not hand-edit the table.
12. **Final step — output exactly one line, then stop.** Your entire chat response for the implementation is a single line: `Story [N] done — status updated in stories/README.md`. Do NOT precede it with a recap, a "let me summarize what was done", a ✅ checklist of created files, an "AC met" list, or any narrative. The story already contains the acceptance criteria; restating them is pure noise. Exactly two additions are permitted, and only when one genuinely applies: (a) a short note about a non-acceptance deviation or follow-up that does not contradict an AC and did not weaken verification; and (b) a project-relevant decision worth preserving (a colour value, dimension, performance budget, accessibility measurement, architectural pattern, or library quirk discovered in practice), surfaced with an offer to capture it in the right artifact per "Implementation Output Discipline" below. An unmet or unverified AC is never an allowed suffix: step 10.1 leaves the story pending. Neither addition applies → the one line is the whole response. Nothing else is permitted. This is a hard stop, not a guideline.

<!-- mano-rule: id=dev-yolo-batch; incident=explicit-yolo-stopped-after-one-story; model=codex; date=2026-08-03; eval=dev-yolo-batch,dev-yolo-blocker,dev-default-single -->
**YOLO-only override to step 12:** do not output or stop after each successfully checkpointed story. When every story in the initial snapshot is done and a final state read shows no pending rows in that phase, output exactly one aggregate line — `Stories [comma-and-space-separated story numbers] done — statuses updated in stories/README.md` — then stop; for stories 1 through 3, the literal line is `Stories 1, 2, 3 done — statuses updated in stories/README.md`. That final no-pending state is the YOLO batch's success check; do not also emit step 3's ordinary phase-built / `mano review` response or append any suffix. If the initial snapshot contained one story, use the ordinary singular line. If the batch stops early or new pending work appears, output one concise deviation line naming the completed story numbers, the current pending story, and the blocker; never claim the phase is built. **Auto-chain exception:** when `mano dev yolo` is the terminal action of an armed `mano mode auto` chain, this aggregate/deviation line is the dev action log, then emit the required `[mano auto]` closing block from `_mano/workflow.md`. That closing block is not an implementation summary and is the only permitted content after the line.
<!-- /mano-rule: dev-yolo-batch -->

## Implementation Output Discipline

When implementing a Mano story, the implementing agent writes code and updates the story's status. It does not append completion reports, verification logs, behavioural confirmations, or implementation narratives to the story file.

It also does not print these to chat. After implementing, the only required chat output is a single line confirming the story is done and its status was moved to `done` in the stories README — for example: `Story 4 done — status updated in stories/README.md`. Do not restate acceptance criteria, list "AC Met", enumerate created files, or write an implementation summary. The acceptance criteria already live in the story; echoing them back adds no information and only grows the conversation. Report only non-acceptance deviations or follow-up that did not weaken any AC. An unmet or unverified AC leaves the story pending under step 10.1. If there are no such notes, the one-line confirmation is the complete response.

<!-- mano-rule: id=dev-yolo-batch; incident=explicit-yolo-stopped-after-one-story; model=codex; date=2026-08-03; eval=dev-yolo-batch,dev-yolo-blocker,dev-default-single -->
In YOLO mode, "after implementing" means after the whole initial snapshot, not after each story. Produce no interim chat messages; the aggregate or interrupted-batch line defined above is the single implementation response, except for the required auto-chain closing block when this batch is the last action of an armed auto run.
<!-- /mano-rule: dev-yolo-batch -->

If implementation produces project-relevant decisions worth preserving — colour values, dimensions, performance budgets, accessibility measurements, architectural patterns, technique choices, library quirks discovered in practice — the agent surfaces them in chat and offers to capture them in the appropriate artifact:

- Architectural or repeatable conventions → `_mano_output/project-rules.md`
- Visual or design decisions → `_mano_output/design-brief.md`
- Story-specific behavioural changes → the story's `## Changes` section (see "In-Flight Story Changes" below)

The story file remains a planning artifact, not an implementation log. This applies to all implementing agents, including third-party language specialists and external coding skills.

## In-Flight Story Changes

The acceptance criteria are the behavioural contract for the current story. Do not invent new behaviour, validation, edge cases, or product rules beyond the story on your own initiative.

**`Not this story` is a hard boundary, not advice.** If the story has a `Not this story` (or equivalently-named out-of-scope) section, every item in it is a prohibition with the same force as a `Do not:` line. Implement none of it, even when the surrounding code, the chosen node/type/component, or a library default makes that behaviour the "natural" or "obvious" thing to add. A common trap: the story names a type whose typical use implies a behaviour the story excludes (e.g. an animated-sprite type used to show a *static* frame, a form widget used without its usual validation). The named type does not authorise the implied behaviour — the `Not this story` line overrides what the type "wants" to do. When a `Not this story` item and your instinct conflict, the `Not this story` item wins; if you believe an excluded item is genuinely required for the AC to work, that is a gap — stop and surface it, do not implement it on your own initiative.

When implementation reveals a gap:

- **Clear user-directed behaviour change within the phase:** implement it. Add a `## Changes` note only if the change affects future stories, tests, specs, rules, UX, or review.
- **Scope-expanding change:** apply step 6.4. The human may choose it, but code and stories must not become the only record of that choice.
- **Ambiguous change:** ask one clarification or suggest a follow-up story.
- **Bug fix that satisfies existing AC:** implement it. No `## Changes` entry needed.
- **Agent-discovered missing decision:** stop and tell the user which Mano flow owns the decision (`mano spec`, `mano rules`, or `mano stories`). Do not invent it.
- **Change that may invalidate spec, rules, or UX:** mention it for the next `mano review`; do not reconcile artifacts mid-story.

Principle: update the story file only when the change becomes future context.

When a `## Changes` note is warranted, use:

```md
## Changes

- [Short context]: [what changed] because [why it changed].
```

### Do not

- Modify files in `_mano/` or `_mano/templates/` — these are framework files.
- Interpret `mano` commands (e.g. `mano start`, `mano review`) as implementation instructions — these are planning commands. Execute the relevant planning flow instead.
- Create extra tracking files — Mano does not use a dedicated phase-state file. Determine state through `_mano/scripts/state.js`, which applies the optional local owner configuration and returns exact paths.
- Auto-advance phases. A completed phase (all stories `done`) never triggers planning or implementing the next one. Stop and let the user decide; never run `mano start`/`mano stories` on your own initiative.
- **Edit any story file whose row is `done` in its `stories/README.md`** — for any reason, including fixing information that turned out stale, adding scope the user just requested, or a fix so small it seems easier to just patch in place. This applies to every phase, reviewed/closed or still open, and it applies even when you are not currently "in" `mano stories`/`mano dev` — e.g. mid-conversation direct edits, or work started from `mano ui`/`mano spec`/`mano rules` that ends up touching implementation. Before editing any file under a phase's `stories/` directory, check its row's status first. If `done`, stop: create a new lettered story instead (`story-1a`, `story-1b`, …) via `node _mano/scripts/stories.js add-row`, describing the change and referencing the original; implement/verify against the new story; mark it `done` through the writer if already complete. A `done` story is a historical record of what was true when it shipped — reverting a done story's stale-looking text back to what was actually true at the time, once a new story carries the current reality forward, is correct, not a bug. (`_mano/skills/stories.md` → "Mid-build additions" has the full procedure; `tech-spec.md`/`project-rules.md`/`design-brief.md`/`ux-flow.md` are NOT covered by this rule — those living artifacts are meant to be extended after a phase closes.)

## Project structure

```
_mano/                    ← Mano framework (do not modify during implementation)
├── skills/               ← Mano skill prompts
├── scripts/              ← state.js (read-only state projection), backlog.js / stories.js (index writers)
├── hooks/                ← optional post-skill hook reminders
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
    └── stories/          ← Implementation stories (start here)
```

## Context Discipline

Roles in Mano are reasoning lenses, not isolated autonomous agents.

Specialization is maintained through selective context exposure and user discipline. Models may still merge assumptions or infer information outside the intended scope.

Use each role to focus attention on a specific planning concern rather than assuming strict separation.

## Post-Skill Hooks

After completing a Mano skill, check `_mano/hooks/` for an active post-hook matching the skill name.

Examples:
- `mano import` checks for `_mano/hooks/post-import.md`
- `mano start` checks for `_mano/hooks/post-start.md`
- `mano spec` checks for `_mano/hooks/post-spec.md`
- `mano rules` checks for `_mano/hooks/post-rules.md`
- `mano ux` checks for `_mano/hooks/post-ux.md`
- `mano ui` checks for `_mano/hooks/post-ui.md`
- `mano stories` checks for `_mano/hooks/post-stories.md`
- `mano review` checks for `_mano/hooks/post-review.md`

Ignore `.example.md` hooks.

A hook's `## Mode` section decides how it runs. `suggest` (the default, and the kind assumed everywhere below) produces findings and is never run automatically in manual mode or an unarmed run — ask first. During an armed auto chain it runs automatically. `command` names one command in a `## Command` section and **always runs, in both modes**, after the artifacts are written: the hook file is the authorization, so do not ask. Report it in one line of the execution log, take the command only from the hook file, and on failure report the exact error without retrying, fixing the user's script, or hand-editing artifacts to compensate. Full contract: `_mano/workflow.md` → **Optional Post-Skill Hooks**.

<!-- mano-rule: id=post-hook-findings-triage; incident=hook-output-triage-gap; model=not-recorded; date=2026-05-29; eval=hook-triage-no-approval,hook-triage-selected-only,hook-triage-start-no-approval,hook-triage-rules-no-approval -->
When any just-run `suggest` hook has printed findings in chat, keep the related
Mano skill active and follow `_mano/workflow.md` → **Post-Hook Findings Triage**.
`post-stories` uses its dedicated immutable-story protocol. Running the hook did
not approve edits. An in-lane finding is `apply`, never a route back to the skill
already running; a finding owned by another artifact is `route: mano [owner]`
and must not be edited here. Apply the smallest selected change within the
workflow's per-skill application boundary. Preserve unmentioned content and
adjacent values.
<!-- /mano-rule: post-hook-findings-triage -->

In manual mode or an unarmed run, if an active `suggest` hook exists, mention it in the final response before the next-action block (a `command` hook has already run — report it in the execution log instead):

```text
Active post-[skill] hook found: `_mano/hooks/post-[skill].md`.
-> Purpose: Optional specialist review of the generated or current artifact.
-> Recommended timing: Run after reviewing the artifact and before the next dependent Mano action if this check matters for the phase.
-> Run it now? (yes / not yet)
```

In manual mode or an unarmed run, the `Run it now?` line is part of the template, not optional — omitting it means the user was never asked. During an armed auto chain, run the `suggest` hook automatically; no suggestion block is printed. No findings means continue, while findings pause for numbered triage under `_mano/workflow.md`.

Do not mention specific third-party or external skill names in generic Mano output.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not execute a `suggest` hook without explicit user confirmation in manual mode or an unarmed run. An armed auto chain is the explicit exception defined by `_mano/workflow.md`.

Do not write hook suggestions into generated artifacts.
<!-- MANO:END -->
