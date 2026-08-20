# Mano Workflow

This file is the dispatcher: it is read for the bare `mano`, `mano help`, `mano status`, and `mano continue` commands. Every other command dispatches straight to its skill file in `_mano/skills/`; each skill's front-matter names the `_mano/rules/` files it requires. Do not load this whole file for a `mano <action>` command, and never open it mid-skill.

The shared rule fragments live in `_mano/rules/`:

- `_mano/rules/core.md` — ownership, tracks, state detection, scripts-mandatory, artifact-write rule, chat output + canonical execution-log format, session hygiene, auto-chain execution
- `_mano/rules/artifact.md` — plain-language contract, compactness, shared/conflicting values, skill tightening, next-step suggestion rule
- `_mano/rules/intake.md` — Intake Boundaries B1–B5 (start, import)
- `_mano/rules/backlog.md` — backlog ownership boundary, mid-phase additions
- `_mano/rules/hooks.md` — post-skill hooks (check/suggest/command) + findings triage; loaded only when the state projection's `HOOK:` line is not `none`

## Commands

```
mano                    → Show available commands and current status.
mano status             → Read deterministic project state and show where you are + what to do next.
mano import [doc]       → Turn an existing PRD/document into a backlog, then stop.
mano owner [slug]       → Show, set, or clear this repository clone's optional phase owner.
mano mode [auto|manual] → Show or set whether finished actions chain automatically.
mano track [name]       → Show, set, or clear an optional local experiment/work track.
mano start              → Scope a new project or phase.
mano continue           → Auto-run the next logical action if unambiguous.
mano [action]           → Run a planning action: spec, ux, rules, ui, stories, review.
mano build ["<fix>"]    → Build the active phase straight from its brief, tracked in progress.md.
mano dev                → Implement the next pending story for the active phase.
mano help [skill]       → Show what a skill does and when to use it.
```

`mano owner`, `mano mode`, `mano track`, and `mano start` are dedicated commands. `mano [action]` covers `spec`, `ux`, `rules`, `ui`, `stories`, and `review`. `mano build` and `mano dev` are the two implementation entry points — a phase uses one or the other, never both.

**Dispatch only to Mano's own skills — never a similarly-named built-in.** Every `mano <action>` resolves to the matching skill in `_mano/skills/` and to nothing else. The host environment may contain built-in, harness, plugin, or third-party skills whose names overlap a Mano action word — do **not** invoke those for a `mano` command, even if their name looks like an exact match. Resolve the command by its Mano role (the agent and contract below), not by keyword similarity to an ambient skill. Two known, high-impact collisions to call out explicitly:
- **`mano review` → `mano review`** (`_mano/skills/review.md`): record evidence and assumption outcomes, triage feedback into the backlog, write the review log, and close the phase. It reads **only** Mano artifacts and never inspects source. It is **not** a code review / pull-request review / multi-angle diff review. If you find yourself running `git diff`, scanning the diff for bugs, or launching review *agents*, you have invoked the wrong skill — stop and run `mano review` instead.
- **`mano dev` → the implementer** (`_mano/skills/dev.md`): implement the next pending story. It is **not** a dev server, build/run command, or editor launch. If you find yourself starting a server or opening the project in an editor, you have invoked the wrong skill.

Every Mano skill's exact name is `mano-<action>` — **hyphen-separated**: `mano-import`, `mano-review`, `mano-dev`, `mano-spec`, …. When a user types the spaced form (`mano import`, `mano review`, `mano dev`), resolve it to that **exact hyphenated** skill name — the same as if they had typed `mano-import` / `mano-review` — never to a built-in that merely shares the bare keyword. The hyphenated name matches a Mano skill and no built-in, so it is the unambiguous target; the space is only a friendlier spelling of it.

**The separator is a hyphen, never a colon.** Do not transform `mano <action>` into `mano:<action>` — the colon form is plugin-namespace syntax (`plugin:skill`) and matches no Mano skill; trying it wastes a turn and makes the command look unavailable. If a `mano <action>` command appears not to resolve, **try the hyphenated `mano-<action>` skill before concluding it is unavailable** — that is the canonical name, and the most common cause of a "skill not found" is having looked for the spaced or colon form instead of the hyphen. If a user re-issues a command in hyphenated form after a misfire, that is them forcing the exact match — honour it as the Mano skill.

`mano dev` and `mano build` are **not** planning actions — they are the two implementation entry points. `mano dev` implements the next pending story from a `stories/` folder, following `_mano/skills/dev.md`. `mano build` builds the phase straight from its brief with no story files, tracked in `PHASE_DIR/progress.md`, following `_mano/skills/build.md`; both share `_mano/rules/implement.md`. The "Refuse code generation" rule (`_mano/rules/core.md`) applies to the planning actions, not to these two.

**One ledger per phase.** `mano stories` + `mano dev` suit a large phase and keep the big-model-plans / small-model-implements split; `mano build` runs one phase in one contract on one model, with the human-authored Phase Scope items as the units. A phase that somehow holds both `stories/README.md` and `progress.md` is refused by `state.js` — decide which ledger is authoritative and remove the other.

### Implementation entry

**Choose implementation by validated state, then mode, in this order.** This is the one rule; every command, status line, and `Next:` block that names an implementation action applies it rather than restating a path from habit.

1. Either ledger invalid, or both ledger paths present → **refuse**, with the repair instruction the projection prints.
2. A pending rework event, any open Scope row, or an unresolved deviation → **`mano build`**.
3. An incomplete stories ledger → **`mano dev`**.
4. A complete stories ledger → **`mano review`**.
5. A progress ledger with every Scope leaf `done`, every Exit leaf `met` or `needs-human`, and no pending rework → **`mano review`**.
6. Only with **no ledger**, after the approved planning gates, does mode decide: **auto** terminates at `mano build`; **manual** offers `mano stories` first and `mano build` second.

Rule 6 is the only one where mode has a say, and it is the only one where two answers are both correct. The rest are read off validated state: a phase that already has a ledger keeps that ledger's path, whatever the mode is.

Auto reaching `mano build` with no ledger is bounded by the same gates as every other path:

- it is reachable **only** after an explicit human approval of the phase scope and after the planning actions that approval armed;
- it never bypasses an open question, a missing-artifact decision, or a hard gate — each of those is a named pause;
- a pre-existing stories ledger keeps the stories path, and the chain runs `mano dev yolo` for it under that rule alone;
- it still stops before `mano review` and never scopes another phase.

`mano import` → `mano start` → scope approval, in auto, therefore ends in `mano build` and **writes no story files**. Import populates the backlog and stops; start scopes and arms the chain; build creates the ledger from the approved brief. No step on that path produces a `stories/` folder.

`mano dev yolo` and `mano-dev yolo` are the same explicit batch invocation: both resolve to the existing `mano-dev` skill with the trailing `yolo` preserved as an argument — never to a separate `mano-dev-yolo` skill. The default command still implements one story. The literal YOLO modifier tells the `_mano/skills/dev.md` implementation contract to process every story that was pending at invocation, sequentially in index order. It is still implementation rather than planning, and it preserves every per-story boundary and hard stop.

When a user types a Mano command in chat, the agent should execute that Mano workflow directly. Do not bounce the command back by telling the user to run it manually.

### Source- and track-filtered phase candidates

`Source` is optional backlog provenance, not a priority or scope field. To focus a returning `mano start` on one imported document, review, or origin, use `mano start from source "[text]"`. Start passes the text to `state.js --scope --source`; the projection returns only phase-scopeable items whose top-level `Source` contains the text, case-insensitively. This narrows what Start proposes—it never auto-selects matching items, changes their status, or bypasses the normal scope-approval gate. No matches means broaden/remove the filter; do not silently fall back to the entire backlog.

`Track` is a separate exact, case-insensitive candidate filter for a named experiment or direction. An active `mano track "[name]"` applies it automatically to Start; `mano start from track "[name]"` temporarily selects another one. It can be combined with Source when both provenance and direction matter. A track is not an Epic, priority, or approval: Start may still propose only a subset, and its usual contradiction checks remain mandatory.

## Run Mode: manual and auto

Mano runs in one of two modes, stored per repository clone in local Git config (`mano.mode`, not committed) and overridable for a shell with `MANO_MODE`. Every `state.js` projection prints the active mode as `MODE:`; read it there rather than asking or assuming. `mano mode` shows it, `mano mode auto` / `mano mode manual` set it, `mano mode clear` returns to the default.

**`manual` is the default and the behaviour every existing project keeps.** Each command finishes, prints its log, and hands back. The absence of configuration is never an opt-in — an unreadable or missing setting resolves to `manual`.

**`auto` chains the actions the user would otherwise type.** It exists because a user who has stopped reading intermediate artifacts is already chaining by hand; the mode makes that explicit and bounded rather than pretending each hand-off is a review. It changes *who types the next command*. It changes nothing about what any skill produces, what it is allowed to write, or which decisions belong to the human.

The rules a skill applies while a chain is running — the pause rule, continuing-is-an-action, and the closing block — are `_mano/rules/auto.md`, which a skill loads only when the projection reports `MODE: auto` and never in `manual`. Hook behaviour inside a chain is `_mano/rules/hooks.md` → **Hooks in auto mode**.

### Where auto mode starts and stops

Auto mode is armed only by an **explicit human approval of a phase scope** in `mano start`. Nothing before that approval is ever automated: intake stays a conversation, and the phase brief is still written only after the human approves the scope. The approval gate is what keeps "correct course at the brief, not after dozens of tasks have shipped" true, so it is never absorbed into the chain.

Once armed, the chain runs the planning actions the phase needs and ends with implementation. Which implementation action that is comes from **Implementation entry** above, not from the mode: with no ledger it is `mano build`, which builds the brief's Phase Scope items in order and stops at its first blocker or when the turn's budget is spent; a phase that already has a stories index keeps that path and ends at `mano dev yolo`. Either way the chain then **stops and hands back — always.** The terminal action is not configurable: a knob there would be one more decision for no gain. In auto mode:

- **never run `mano review`.** Closing a phase is the human's judgement and the one gate the mode exists to preserve.
- **never scope a new phase.** The chain covers one approved phase and no more.

Arming is per phase, not permanent: a command the user types themselves inside an already-approved phase still chains onward (that is the mode), but the chain never carries into a phase the human has not approved. **The user can stop it at any point** — "stop", "wait", "hold on", or any instruction to pause ends the chain immediately and hands back, without needing `mano mode manual`.

At the approval, state the chain you intend to run before starting it, so the user knows they are about to go hands-off and can edit it in the same reply:

```text
→ Auto mode: spec → rules → build
  Reply `1` or `go` — both approve this scope and run the chain above.
  Edit and approve together (`go, skip rules`; `1, add ux`). Pauses for questions; stops before review.
```

`1` and `go` are exact synonyms: both approve the proposed scope and arm the displayed chain. An edit without either token changes the proposal but does not approve it. The numbered option must say it runs the auto chain; never present `1` as brief-only while `go` appears auto-specific.

The proposed chain is an **approved run plan**, not a hint to recompute after every action. Once the user approves it, preserve that order and the remaining actions for this run. Re-evaluate only when new evidence triggers a pause, a hard gate invalidates the plan, or the user edits it. The "Single obvious next action gates" select an unapproved next action; they do not override an explicitly approved remaining action.

## Core principle: à la carte, not a conveyor belt

Actions are independent in the sense that Mano does not force a fixed sequence. You can run actions out of order, but each one still has a contract: some can proceed with partial context, and some should redirect rather than guess.

When a skill activates, it checks for its inputs:
- **Inputs exist** → proceed normally.
- **Useful with partial context** → warn the user what's missing, explain the tradeoff, and offer to continue anyway.
- **Would be guesswork without the missing artifact** → warn the user what's missing and redirect to the action that creates it.

This means:
- You can skip `mano spec` and go straight from `mano start` to `mano stories`.
- You can skip `mano ui` entirely if you have your own design direction.
- You can run `mano stories` without running `mano rules` first.
- Each skill adapts to what's available instead of assuming the full pipeline already exists.

In installed projects, Mano framework files live under `_mano/skills`, `_mano/rules`, and `_mano/templates`. The framework source repository may store these files at the root, but the runtime contract presented to coding agents uses `_mano/...` paths.

`mano ui` begins with `node _mano/scripts/state.js --ui`; that projection is its only phase-directory discovery and supplies the exact owner-aware current `BRIEF`, `PHASE_DIR`, and `PREVIEW` paths plus legacy-root presence without exposing the backlog. It then applies two output lifecycles. `_mano_output/design-brief.md` is the cumulative, canonical visual contract; preserve its established tokens, components, and phase-identity-namespaced Screen Composition entries while extending it for the current phase. The HTML is a non-canonical phase snapshot at the exact projected `PREVIEW`. A same-phase re-run may read and update that file, but a later or differently owned phase must not read or write another phase's preview. Never read, overwrite, move, or infer ownership for a legacy `_mano_output/design-preview.html`; leave it untouched.

The exact projected current phase brief is a blocking input for `mano ui`: if `BRIEF` is missing, stop and route to `mano start`. When the brief exists, a missing current-phase preview keeps `mano ui` useful even when the phase reuses components already documented in the design brief; a new screen composition still deserves its own phase snapshot.

## Rules

- The user owns scope, priorities, and product tradeoffs. `mano spec` may recommend technical defaults, `mano ui` may set visual defaults, and `mano rules` may recommend project rules, but every recommendation is overridable.
- Keep phase briefs concise enough to read in under two minutes. Target roughly 250-500 words plus short lists.
- Actions are a la carte, but some require upstream context or will redirect instead of guessing.
- Each phase brief is self-contained. No external files needed to understand it.
- The filesystem is the state. Mano scans `_mano_output/` through `state.js` to know where you are; there is no global progress file. A phase built with `mano build` keeps a per-phase `progress.md` ledger — that is the phase's own decomposition and status, not a project-level state file, and no skill infers routing from it directly.
- Skills read only what they need (see skill files for specific inputs).

## Human Oversight

Mano assumes humans actively supervise planning outputs.

LLMs may:
- make unsupported assumptions
- merge conflicting context
- preserve outdated decisions
- generate overconfident recommendations

Humans are responsible for:
- validating important decisions
- resolving ambiguity
- rejecting unnecessary complexity
- deciding when an artifact needs a deliberate restructure or replacement

Mano structures collaboration. It does not replace judgment.

## State detection

State is read through `_mano/scripts/state.js` only — the full contract is `_mano/rules/core.md` → **State detection**. The dispatcher-level map:

- No `_mano_output/` folder → no project started → suggest `mano start` (or `mano import <doc>` if the user has a PRD/document to decompose first)
- The projected `BRIEF` exists and the projected phase has **neither ledger** → planning stage. Show which optional artifacts already exist (the projection's `ARTIFACTS:` line) and which are still missing or incomplete. This is rule 6 of **Implementation entry**: in `manual`, offer `mano stories` first and `mano build` second once the phase is clear enough; in `auto`, the approved chain terminates at `mano build`. Read `MODE:` from the projection rather than assuming.
- `stories/` folder exists and at least one row is not `done` → build mode. The next step is implementation: suggest `mano dev` for the next row reported by state. No Mano planning command is required until the user wants to adjust scope or add planning context.
- `progress.md` exists and any Scope row is not `done`, any Exit Criterion is not `met` or `needs-human`, or any rework event is pending → build mode on the build path. Suggest `mano build`; it resumes at the next non-`done` row, or at the first pending `R…` event, as reported by state. Never suggest `mano stories` or `mano dev` for a phase with a ledger.
- The projected stories are all `done` (or the ledger's Scope rows are all `done` and its Exit Criteria all `met`), and the exact projected review entry is absent → phase is **built but not closed**. Direct the user to `mano review`; `mano start` will refuse to scope this owner's next phase until review clears its exact in-phase status.
- `reviews.md` has the exact projected owner-aware review entry and its backlog close sweep is complete → suggest `mano start` for that owner's next phase.

`mano stories` creates the projected `PHASE_DIR/stories/README.md` the first time stories are generated. If its stories folder exists without that index, treat that exact phase's artifacts as incomplete.

To detect the active phase, run `state.js`; it selects the highest phase number only within the locally configured owner namespace, or legacy `phase-N` when ownership is unset.

## Help

When the user types `mano`:
1. Display the command table.
2. Run `node _mano/scripts/state.js --verbose` and show its selected owner-aware status if a project exists.
3. Do not activate any skill.

## Help [skill]

When the user types `mano help [skill]`:

Show a brief description of the skill — what it does, when to use it, what it reads, and what it produces. Do not activate the skill.

| Command | Role | Reads | Produces |
|---------|------|-------|----------|
| **`mano import`** | Turns an existing PRD or document into a backlog. Decomposes the document into items, then stops. Does not scope phases. | A PRD/document (path or pasted), existing backlog | Backlog (items `Status: backlog`) |
| **`mano owner`** | Opts this repository clone into an owner namespace, shows it, or clears it. | Repository-local Git config / `MANO_OWNER` | Local Git config only; no planning artifacts |
| **`mano mode`** | Shows or sets whether finished actions chain automatically (`auto`) or hand back (`manual`, the default). | Repository-local Git config / `MANO_MODE` | Local Git config only; no planning artifacts |
| **`mano track`** | Shows, sets, or clears the optional local experiment/work track. | Repository-local Git config / `MANO_TRACK` | Local Git config only; no planning artifacts |
| **`mano start`** | Scopes projects and phases. Populates the backlog (from conversation), suggests phase scope, drafts the phase brief. | Backlog, previous phase brief, reviews | Phase brief, backlog updates |
| **`mano spec`** | Translates the phase brief into a tech spec. Recommends libraries, defines data model, flags cross-environment boundaries. | Phase brief, existing tech spec, package manifest/lockfile, filtered unresolved spec-gap projection | Tech spec; targeted spec-gap status updates |
| **`mano ux`** | Defines the current phase's new or changed screens, navigation, in-world interactions, and recovery paths in one pass. | Phase brief, UX flow, tech spec, project rules | UX flow |
| **`mano rules`** | Defines and updates project rules — components, patterns, naming, a11y, folder structure. Flags over-engineering. Most useful once the tech stack is known. | Tech spec (recommended), UX flow, design brief, filtered unresolved rule-gap projection, phase brief, existing project rules | Project rules; targeted rule-gap status updates |
| **`mano ui`** | Establishes the visual language — palette, typography, spacing, component guide. Generates a preview HTML. | Phase brief, UX flow, tech spec, project rules, existing design artifacts | Design brief, current visual preview |
| **`mano stories`** | Breaks the phase into implementable stories. Writes directly to files. Flags overloaded screens. | Phase brief, existing current-phase story set on re-run, tech spec, UX flow, design brief, project rules | Story files, stories index |
| **`mano review`** | Records evidence and assumption outcomes after shipping, triages feedback, writes the review log, and closes the phase. | Stories index, phase brief, reviews, backlog | Review log, backlog updates |
| **`mano build`** | Builds the active phase straight from its brief — the human-authored Phase Scope items are the units, tracked in `progress.md`. No story files. `mano build "[what changed]"` passes a mid-phase correction at invocation, and is accepted only when a valid ledger exists. Follows `_mano/skills/build.md` plus `_mano/rules/implement.md`. | Phase brief, `progress.md`, the artifacts a row needs | Source code, ledger rows `done` / criteria `met` |
| **`mano dev`** | Implements the next pending story for the active phase. Not a planning lens — follows the complete contract in `_mano/skills/dev.md` plus `_mano/rules/implement.md`. | Stories index, the selected story, the dev contract | Source code, story marked `done` |

## Status

When the user types `mano status`:
1. Run `node _mano/scripts/state.js --verbose`; do not scan phase folders by hand. It applies optional owner routing.
2. Report the selected owner, exact active `PHASE_ID`, what files exist (use the projection's `ARTIFACTS:` line — do not open artifacts to check existence), what is missing, and what is present-but-incomplete.
3. If multiple planning actions are still reasonable, show them as `Next options` instead of forcing a single `Suggested next action`.
4. Only show one `Suggested next action` when the next move is genuinely narrower than the other valid options.
5. For user-facing or mobile phases, missing or stale design coverage or visual preview keeps `mano ui` visible as a valid next option, even when `mano stories` is also ready. Apply the phase-preview ownership contract above when deciding whether an existing preview covers the phase.
6. Do not activate any skill.

## Single obvious next action gates

`mano continue` should auto-run only when the next planning action is genuinely narrower than the alternatives.

These gates are shared: `mano continue` applies them once per invocation, and auto mode applies them when choosing an action that is not already in the approved remaining chain. An approved chain action wins over a newly recomputed optional branch unless new evidence pauses or invalidates the run. They never override **Implementation entry** — once a ledger exists, its path is decided by validated state, and these gates only choose among *planning* actions. Two auto-mode overrides, from **Run Mode**: the chain never auto-runs `mano review` or a new `mano start`, and with no ledger its terminal action is `mano build` where a manual user would be offered `mano stories` and `mano build`. A phase that already has a stories index keeps the stories path — the chain runs `mano dev yolo` for it instead.

Auto-run is appropriate when:
- no `_mano_output/` exists → `mano start`
- a phase brief exists, neither ledger exists, and supporting artifacts are either already present, irrelevant, or explicitly skipped → the implementation entry rule 6 applies: `mano build` in auto, and in manual `mano stories` and `mano build` are both valid, so show them as options rather than auto-running one
- all stories are done and no review entry exists → `mano review`
- every Scope leaf is `done`, every Exit leaf is `met` or `needs-human`, no rework is pending, and no review entry exists → `mano review`
- the selected namespace's current phase is reviewed and the user asks to keep going → `mano start`

Do not auto-run when:
- spec, UX, rules, or UI are all still plausible options for adding useful clarity
- the phase is user-facing and design context may materially change stories
- the tech approach is unclear enough that stories would become guesswork
- an artifact is stale or conflicting and the right repair path is not obvious
- the project is in build mode with at least one story not `done`
- the phase has no ledger, the mode is `manual`, and both `mano stories` and `mano build` are genuinely available — that is a path choice the human owns

In those cases, show `Next options` instead of choosing for the user. In auto mode this is a pause, not a silent pick — ask which branch and resume once answered. The decision tree for weighing planning options is `_mano/rules/artifact.md` → **Next-step suggestion rule**.

## Continue

When the user types `mano continue`:
1. Run `node _mano/scripts/state.js --verbose` to determine state and apply optional owner routing. Do not scan phase folders by hand.
2. If there is a single obvious next Mano action, execute it immediately.
3. If there are multiple reasonable planning actions, stop and explain the options instead of choosing one.
4. If the project is in build mode, say so plainly instead of forcing a planning command. Which implementation action to name is **Implementation entry**, read off the projection — never guessed from which path is more familiar.

Build-mode fallback output, on the **stories** path (`stories/README.md` with an open row):

```
Build mode: [PHASE_ID]

- Active phase: [exact PHASE_ID]
- Status: At least one story is not done, so no planning action was auto-run.
- Use `mano dev` to implement the next pending story.
- Use `mano stories` only if you need to add or adjust planned work.
- If the phase scope changed, say it to `mano stories "[what changed]"` — with a ledger present the brief is frozen, so an in-goal change becomes a lettered follow-up story and a distinct outcome goes to the backlog or the next phase. `mano start` is closed here.
- Use `mano review` after all stories in the phase are done.
```

Build-mode fallback output, on the **build** path (`progress.md` with an open row or a pending rework event):

```
Build mode: [PHASE_ID]

- Active phase: [exact PHASE_ID]
- Status: [n]/[total] scope rows done, [n]/[total] exit criteria met[, N review finding(s) pending].
- Use `mano build` to resume at the row state reports next.
- A mid-phase correction stays inside `mano build` — say it in plain words, or pass it as `mano build "[what changed]"`. The brief is frozen while the ledger exists, so `mano stories` and `mano start` are both closed here.
- Use `mano review` after every scope row is done and every exit criterion is met.
```

Formatting rule for `mano continue` and `mano status`:
- Never expose drafting notes, placeholder text, formatting reminders, link-fix notes, or internal reasoning.
- If a draft starts to spill internal text, discard it and output only the clean final response.

Rules for what counts as a `single obvious next` action:
- `mano continue` is narrower than `suggested next action`. A shortest path is not automatically a single obvious next step.
- Follow the decision tree in `_mano/rules/artifact.md` → **Next-step suggestion rule**. Only auto-run `mano stories` if the tree resolves to it unambiguously.
- If a local artifact needs repair (for example a `stories/` folder exists without its README index), do not treat that repair need by itself as proof that one planning action is unambiguous. Check whether other planning actions are still reasonably available first.
- When in doubt between "shortest path" and "multiple valid options", stop and explain the options.

## Do

When the user types `mano` with no argument (or just wants to see available actions):
1. Run `node _mano/scripts/state.js --verbose`; use its exact owner and phase identity rather than scanning phase folders.
2. Show available actions with the suggested next action marked:

```
Available Mano commands for [PHASE_ID]:

  import   — Add document requirements to the backlog (`mano import [doc]`)
  status   — Show deterministic project state (`mano status`)
  start    — Scope a new project or phase (`mano start`)
  continue — Run one unambiguous next planning action (`mano continue`)
→ spec     — Tech spec (`mano spec`)
  ux       — UX flow (`mano ux`)
  rules    — Project rules (`mano rules`)
  ui       — Design brief and component guide (`mano ui`)
  stories  — Break phase into implementable stories (`mano stories`)
  review   — Triage feedback, close the phase (`mano review`)
  build    — Build the phase straight from its brief (`mano build ["what changed"]`)
  dev      — Implement the next pending story
  owner    — Show, set, or clear this repository clone's optional phase owner
  mode     — Show or set whether finished actions chain automatically
  track    — Show, set, or clear the optional work track
  help     — Describe one command without running it (`mano help [skill]`)

→ marks the suggested next action.
Type any command shown above.
```

Mark the suggested next action by **Implementation entry**: `dev` when a stories index has an open row, `build` when `progress.md` has an open row or a pending rework event, `review` when either ledger is complete. With no ledger yet, `build` is the marked action in `auto`; in `manual` leave `stories` and `build` both visible and mark neither, because that path choice is the human's.

When the user types `mano [action]`:
- Execute the specific action logic defined in the `skills/` file, loading the rule files its front-matter requires and nothing else.
- Default to **One-Shot** generation for write flows unless the skill file explicitly defines a multi-turn conversation.
- `mano review` is not one-shot during feedback capture and triage; follow `mano review`'s multi-turn contract exactly.
- `mano ui` must begin with one brief preference-capture step on first-run design generation when visual preferences are not already defined; after that reply, `mano ui` generates files in one shot.
- Output a single execution log snippet to the user, not conversational dialogue.

Valid actions: `spec` (`mano spec` — `tech-spec.md`), `ux` (`mano ux` — `ux-flow.md`), `rules` (`mano rules` — `project-rules.md`), `ui` (`mano ui` — `design-brief.md` + projected current preview), `stories` (`mano stories` — projected `PHASE_DIR/stories/`), `review` (`mano review` — `reviews.md`).

## Human approval boundary

`mano start` may create or update the backlog and suggest a phase, but it must not write the projected phase brief or stamp the projected in-phase status until the user explicitly approves the phase scope. The full flow is `_mano/skills/start.md`; the review flow is `_mano/skills/review.md`.

## Minimal pipeline

When the phase is already clear and extra artifacts would add overhead instead of clarity:
- Skip `spec`, `ux`, `rules`, and `ui`.
- Use `mano start` → `mano stories` → `mano dev` → `mano review`, or `mano start` → `mano build` → `mano review` to skip story files entirely. Both are shortest paths; which one is offered follows **Implementation entry** rule 6.
- In `auto`, the second is the only one the chain runs: an approved scope with no ledger ends at `mano build`.
- Add optional planning artifacts later only if the work becomes ambiguous.

`mano review` is the one non-optional step. It closes the selected owner-scoped phase by moving only that phase identity's exact in-phase status to `resolved`; `mano start` requires that closure before it scopes the next phase in the same namespace. Other owners' phases are independent. The optional planning actions can be skipped; review cannot. The ceremony can: `close it` closes immediately, and it is the human's sign-off — recorded as such against every exit criterion. It still records `Validation: Not tested`, `Decision: Not assessed`, and every unanswered Validation Question as `unanswered at close`, so closure never masquerades as validation. A normal entry is a compact validation-and-decision log, not a mini-postmortem.
