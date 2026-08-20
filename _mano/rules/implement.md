---
name: implement
description: The implementation contract shared by mano dev and mano build — the gates that run before code, the acceptance-evidence gate, Repair Mode, the read budget, and output discipline.
---

# Implementation contract (shared)

Shared by the two skills that produce code: `mano dev` (one story) and `mano build` (the phase brief's own Scope rows). Both name this file in `requires:`. Read it once, immediately after the skill's own contract and before the state projection — it is identical on every run, so that order keeps the prompt prefix cacheable.

One implementation contract, two units of work. Where this file says **the unit**, read:

| | `mano dev` | `mano build` |
|---|---|---|
| the unit | the story file | the numbered `## Phase Scope` item the ledger row addresses |
| its acceptance criteria | the story's `Done when` | the phase brief's `## Exit Criteria` leaves the unit can satisfy |
| its implementation reference | the story's `Implementation Reference` section | derived in-turn from the artifacts, never written to disk |
| the status write | `stories.js set-status` (dev step 11) | `progress.js set-status` |

Step numbers are stable across both paths and are cited by name elsewhere in Mano — do not renumber them.

**One pass may cover several units. The gates never do.** `mano dev` implements one story per invocation (`yolo` runs the pending set sequentially, each story keeping its own boundaries). `mano build` may cover several contiguous Scope rows in one pass when they share a single implementation surface; `_mano/skills/build.md` owns exactly when that is allowed. Either way:

- gates **6.2**, **6.3**, and **6.4** run **per unit**, before any code and before any status write;
- the acceptance-evidence gate **10.1** is applied **per unit and per acceptance criterion**, after implementation.

Verification may be shared across a pass — one suite run can serve several units. **Evidence may not.** A green suite is evidence for a unit only where something in it exercises that unit's stated outcome through its stated route. A pass that covers three units and proves two closes two, and the third stays open.

## Before writing code — the gap gates

6.2 **Spec-owned default gap.** If the unit or its cited phase Exit Criterion needs a starting state, first-use state, capacity, radius/range, count, duration, threshold, spawn amount, or other behaviour-driving default, the named canonical spec section must state the owning field/config/constant and exact value or relationship. A vague phrase such as “small area” is not an implementation value. Stop and route to `mano spec` when it is missing; do not choose a “story-owned default,” add a temporary literal, or treat a test fixture as the product default.
6.3 **Player-choice UX gap.** If the unit lets a player choose among two or more simultaneously available tools, buildables, abilities, modes, rewards, or alternatives, the cited UX flow must define how the player invokes the choice, selects/changes the active option, sees that active state, and receives locked/unavailable/cancel feedback. If it does not, stop and route to `mano ux`; do not invent a hotkey, picker, cycling scheme, default active item, or HUD treatment while implementing.
6.4 **Phase-scope conflict.** Before changing code, compare the unit and any user-requested behaviour change with the exact projected phase brief's `Phase goal`, `Phase scope`, and `Not this phase`. Work that directly supports an existing outcome can proceed. A distinct outcome, or anything the brief explicitly excludes, is outside this phase: stop before code. Do not treat “do it anyway” as permission to leave the brief stale. Route it, and route it once — the route depends on whether a ledger already addresses the brief:

- **A ledger exists** (it does, if you are implementing): the brief is frozen. On the stories path, an in-goal change is a lettered follow-up story via `mano stories "[what changed]"`; on the build path it is a `+N` correction row. A distinct outcome goes to the backlog or the next phase, and neither path amends the brief. Do **not** send the human to `mano start` from here: with a ledger present it will refuse, and telling them to amend and re-run is the loop this rule exists to close.
- **No ledger yet** — the phase is scoped but nothing is being implemented: `mano start "[what changed]"` may revise the brief in place, showing the complete proposed scope and writing nothing until the human approves it.

This gate applies in default, YOLO, and auto mode.
7. If the unit is bootstrap, setup, tooling, infrastructure, or dependency-related, also read `_mano_output/tech-spec.md` before implementing. Treat library choices, package-manager choice, and install commands there as normative unless the unit's own text already repeats them exactly.
8. Execute install commands exactly as written. Do not merge separate command groups, switch tools, or normalize mixed-tool instructions into a single package-manager invocation unless the unit or the tech spec explicitly tells you to. In particular, keep `npx expo install` commands separate from `npm install` or other package-manager commands so Expo can resolve SDK-compatible versions.

   **Greenfield scaffold safety is a hard stop.** A project generator that creates an application root or requires an empty destination may run only through the exact guarded command in `_mano_output/tech-spec.md §Project Scaffold`: `node _mano/scripts/scaffold.js run ... -- ... {target}`. Never aim a raw generator at `.`, the project root, or a temporary child that you later merge by hand. Never move, rename, delete, or temporarily hide existing files to make the root look empty—especially `_mano`, `_mano_output`, `.git`, `AGENTS.md`, `CLAUDE.md`, or `.cursorrules`. Do not substitute `cp`, `mv`, `rsync`, or a hand-written merge. If the guarded command is absent, malformed, fails, or reports a collision, stop and report it; route an absent/malformed command to `mano spec`, and never improvise around a runner failure. `yolo` and auto mode do not relax this rule.
9. If the unit involves user-entered state, forms, onboarding drafts, settings, or other local data, check whether the unit or the tech spec says that data should persist across app restarts. If it should, treat restart persistence as part of the required behaviour, not as an optional enhancement.
10. Read `_mano_output/project-rules.md` only when the unit explicitly points to a rule there, something remains ambiguous after reading the unit and any mandatory tech-spec pre-read, or you need fuller context behind a rule already summarized in the unit.

    **Verification runs filtered.** Run every build, lint, type-check, and test command for verification through `node _mano/scripts/verify.js -- <command>`. On success it prints one `PASS:` line; on failure it prints the trimmed error excerpt. Do not run verification commands raw and paste their full output into the conversation. A failing verification enters **Repair Mode** (below).

## After implementing — the acceptance-evidence gate

10.1 **Acceptance-evidence gate — before status may become `done`.** After implementation and verification, reread the unit's complete acceptance criteria. For every one of them, identify concrete evidence from this turn that the stated outcome occurs through the stated route. A passing suite is not enough when no test/manual check exercises that AC. Any assertion, fixture expectation, comment, skipped test, or observed result that states the opposite outcome—success expected as failure, recoverable expected as locked, available expected as unavailable—is proof the unit is **not done**, even if the suite is green.

When an AC cannot be satisfied because current code or a cited artifact deliberately preserves the opposite behaviour, stop before the status write, leave the row pending, and report the contradiction. Route a planning-contract contradiction to `mano spec`/`mano stories` as appropriate; do not rewrite the AC's meaning, invert the test, call the opposing behaviour intentional, or mark the unit done with a deviation. For an AC that is inherently visual or experiential, perform the narrow available manual/runtime check; if that cannot be run, report the unverified AC and leave the row pending.

## Repair Mode

A failing build, lint, type-check, or test during verification enters Repair Mode. Fixed budget; never widen it.
Use, and nothing else: (1) the FIRST error only — discard passing lines, banners, later errors; (2) for each
file:line in that error not already read this turn, a ±12-line window (`sed -n`), not the file; (3) the unit's
acceptance criteria and implementation reference, already in context.
Never: re-read the unit/brief/spec/rules (they didn't change); re-read any file already read this turn; paste
full command output (report the error's first line); rewrite a class or file to fix one assertion — repairs are
surgical edits at the failure site; run the full suite to check a fix — re-run the narrowest reproducing command,
full suite exactly once after it passes.
Repair-mode commands still run through `node _mano/scripts/verify.js -- <command>` — it already reports the
trimmed failure excerpt.
Attempt limit: 3 on the same error → stop, leave the row pending, report ≤3 lines (error, file:line, tried).
Exception — never optimised away: the `state.js` re-check before the status write, and the
acceptance-evidence gate (10.1), run in full regardless.

## Read budget

Read source in the smallest useful unit: signatures and declarations first (search/grep), then narrow line ranges around the edit site. Open a full file only when you are editing it and it is small. Do not preload artifacts or source "for context" beyond what the unit's implementation reference names.

## Writing source: surgical edits only

A new file is written in full — that is the only sanctioned full-file write. **An existing file is edited in the smallest regions the change actually owns.** Never re-emit a whole file to change part of it.

- One replacement per changed region: the smallest unique block containing the change.
- Everything you did not come to change stays byte-identical. No reordering, renaming, reformatting, import re-sorting, comment tidying, or "while I was in here" cleanup.
- Adding a function or a case means replacing its neighbour, not the file.

A full-file rewrite is invisible in the rendered result and catastrophic in a diff: it buries the one real change in a wall of noise, turns every concurrent edit into a merge conflict, and silently reverts anything another change added since you read the file. Restructuring is a human decision — say so and let them ask for it. The equivalent rule for planning artifacts is `_mano/rules/core.md` → **Writing artifacts: create once, edit thereafter**; neither implementation skill loads `core.md`, which is why source needs its own statement of it here.

## `Validate now:` — the one expansion of the terminal line

When this run leaves the **phase** ready for review — the last Scope row is `done` and every Exit leaf is `met` or `needs-human`, the last pending story is `done`, or a `yolo` batch emptied the index — the terminal line is followed by the phase brief's compact `Try` guidance:

```text
[mano build]: phase 2 built — S1a–S2b done, E1a–E2a met, E2b needs a human check.

Validate now:
- load 200 items and scroll — the list should not stutter
```

- **Source every line from the brief's `## Validation Plan` → `### Try`.** Copy it compactly; never invent a check, and never derive one from an Exit Criterion. A brief with no Validation Plan, or no `Try` bullets, omits the block entirely — an absent plan is not a prompt to write one.
- **Once per run, not per row and not per story.** One block, after the aggregate line, listing the phase's `Try` items.
- **Only at the terminal handoff.** A mid-run stop, a single story that leaves others pending, and a deviation stop all keep their one-line shape.
- It precedes the `[mano auto]` closing block when one applies.

This block is the **sole** sanctioned expansion of **Implementation Output Discipline**'s one-line rule, and it is stated here — once — so `mano build`, `mano dev`, and the auto chain cannot disagree about it. It is not a summary, so nothing else joins it: no recap, no file list, no restated acceptance criteria.

`mano review` shows the same `Try` guidance again beside the promise it tests. That is deliberate, not redundancy to optimise away: chat delivery is not durable state, and the review that reads it is frequently a fresh session in which this message no longer exists.

## Closing an armed auto chain

Both implementation skills are the terminal action of an armed `mano mode auto` chain. When one finishes such a chain, its ordinary aggregate or deviation line is that action's log — followed by the **`Validate now:`** block when the run left the phase ready for review — and exactly one closing block follows:

```text
[mano auto]: phase-[N] — [first] → … → [last]
- Ran: [actions, in order]
- Stopped: [completed implementation | waiting on the question below]
- Remaining: [ordered actions still approved for this run — omit only when none]
⚠ Verify: [every advisory flag collected across the run, one per line — omit if none]

[the pending question, if that is why it stopped]

Next:
- [when implementation completed] `mano review` — when you have checked the result
- [when paused] Reply to the named question — the recorded remaining chain resumes automatically
```

That block, and the `Validate now:` block that may precede it, are the **only** permitted content after the aggregate line, and neither is an implementation summary: do not add a recap, a file list, or restated acceptance criteria between them. In `manual` mode there is no chain and no closing block — the aggregate line is the whole response. Re-read `MODE` from the freshest projection before deciding which applies.

This contract is stated here, in full, on purpose. Both implementation skills declare themselves self-contained and forbid opening `_mano/workflow.md` or `_mano/rules/core.md` mid-skill, so a pointer into either would be an instruction they cannot follow. The planning skills' copy lives in `_mano/rules/auto.md`; the two must stay in step.

## Implementation Output Discipline

The implementing agent writes code and updates the unit's status. It does not append completion reports, verification logs, behavioural confirmations, or implementation narratives to the story file or the ledger.

It also does not print these to chat. After implementing, the only required chat output is the skill's own single closing line — dev step 12, or build's report from the ledger — plus the **`Validate now:`** block above when this run leaves the phase ready for review. Do not restate acceptance criteria, list "AC Met", enumerate created files, or write an implementation summary. The acceptance criteria already live in the story or the brief; echoing them back adds no information and only grows the conversation. Report only non-acceptance deviations or follow-up that did not weaken any AC. An unmet or unverified AC leaves the row pending under step 10.1. If there are no such notes, the one-line confirmation is the complete response.

If implementation produces project-relevant decisions worth preserving — colour values, dimensions, performance budgets, accessibility measurements, architectural patterns, technique choices, library quirks discovered in practice — the agent surfaces them in chat and offers to capture them in the appropriate artifact:

- Architectural or repeatable conventions → `_mano_output/project-rules.md`
- Visual or design decisions → `_mano_output/design-brief.md`

The story file and the phase brief remain planning artifacts, not implementation logs. This applies to all implementing agents, including third-party language specialists and external coding skills.
