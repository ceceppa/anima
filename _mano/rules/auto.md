---
name: auto
description: "The rules a skill applies while an armed auto chain is running — the pause rule, continuing-is-an-action, and the closing block. Loaded only when the state projection reports MODE: auto."
---

# Auto-chain execution

**Loaded only when the state projection reports `MODE: auto`.** In `manual` — the default, and the common path — no skill opens this file, which is the entire reason it is a separate fragment rather than part of `_mano/rules/core.md`. Read it once, immediately after the projection that reported the mode, and before the first action of the chain.

## The pause rule

**Durable run plan.** Read `node _mano/scripts/chain.js show --phase [PHASE_ID]` before resuming an armed chain. Preserve its ordered `CHAIN_REMAINING` actions; artifact presence does not prove a planned rerun completed. `CONTINUE_ACTION` names the next action; `IMPLEMENTATION_ENTRY` never authorises jumping over approved planning. Auto never runs `mano stories`. With neither ledger present, `chain.js` projects a saved `ui, rules, stories, dev` plan as `ui, rules, build`: preserve the artifact actions in order, resume at `ui`, and persist that projected list at the next save. Reads do not edit the saved record. Only an existing stories ledger retains `dev`; a plan containing `stories` with an existing ledger pauses for reconciliation. After an action and its hook triage finish, save the remaining ordered actions with `node _mano/scripts/chain.js save --phase [PHASE_ID] --actions <comma-separated-actions>`. Keep an unfinished action in the list at a pause; save `--actions ""` only after terminal implementation completes. Persist human-approved plan edits the same way. The record never bypasses current mode, ledger routing, hard gates, or a user's stop instruction. If no saved plan exists, recover the explicit approval from available chat and save it; if approval cannot be recovered, ask for the remaining plan rather than inventing it. A completed record does not arm another run.

**Automatic pre-flight repair.** An armed auto chain may insert an artifact owner before `build` under `_mano/skills/build.md` → **Automatic pre-flight repair**: only before either ledger exists, with approved behavior clear and one repair owner identifiable. This is an authorized plan amendment, not a waiver of readiness. `chain.js repair` atomically saves the inserted action and its attempt; ordinary `save` preserves attempts. Keep the inserted owner pending until its action and hook triage finish. A question from that owner still pauses; after its answer, resume the saved actions in the same turn. Never clear repair attempts to retry automatically. All other conflicts, hard gates, and explicit skips retain their stops.

**Task chains.** A `mano task` the human typed in auto mode may run the owner of a readiness gap and resume the item, under `_mano/skills/task.md` → **Auto mode: gap repair**. That chain has no phase: skip every `chain.js` read and write, treat `task "<item title>"` as the remaining action, and use the closing block in `task.md`, which names the task where this file's block names `phase-[N]`. Every pause condition below applies unchanged.

**Auto mode pauses whenever the human's answer is required, and never answers on their behalf.** This is the whole safety model: the mode removes typing, not decisions. Pause and hand back on any of these, then resume the chain from where it stopped once the user replies:

- a `❓ Decide:` line — already defined as "confirm or change before the next command runs" (`_mano/rules/core.md` → **Canonical execution-log format**), which makes it exactly this signal
- any clarifying question a skill would ask in manual mode
- **a genuine fork in the next action** — when the "Single obvious next action gates" (`_mano/workflow.md`) say *do not auto-run*, that ambiguity is a question. Ask which branch; never pick the first option or the shortest path
- hook findings that need triage (see `_mano/rules/hooks.md`)
- a hard gate or refusal — `CONTINUE_ACTION: blocked`, a pre-review gate, a missing required artifact, a surfaced cross-artifact conflict — except the bounded pre-flight repair above
- any script failure, per `_mano/rules/core.md` → **Scripts are mandatory**

`DECISION: STOP` in the default/verbose state projection blocks scoping with `mano start`; it does not block the projected `CONTINUE_ACTION` for the current phase. Apply each gate to the action it governs.

A `⚠ Verify:` is advisory by definition and does **not** pause the chain. Collect them instead (below).

**Every pause is named.** When one of the conditions above fires, say which one, in the closing block. A chain that hands back without naming a pause condition is a bug, not a pause — the two look identical to the user, and only the named version tells them whether to answer something or re-run the command.

The pause block must also preserve the ordered `Remaining:` actions. When the user answers, apply and persist that answer, refresh the state projection, then continue those remaining actions in the same turn. The answer's one-line changelog is a mid-chain action log, not a reason to stop. If the refreshed `MODE` is `manual`, or the user says stop, apply any requested answer but hand back instead of resuming; mode is read from state at every handoff, never cached from the start of the run.

Two things that are **not** pause conditions, because they are the most tempting places to stop:

- **A `Next:` block listing more than one action.** Several *listed* options is the ordinary shape of a log, not a fork. It is a fork only when the "Single obvious next action gates" genuinely cannot resolve which comes first. An option that is explicitly conditional on another (`mano stories` — *once visual direction is settled*) is resolved, not ambiguous: run the one it depends on.
- **Finishing an action successfully.** Completion is the trigger to continue, not to hand back.

## Continuing is an action, not an announcement

**To continue the chain, invoke the next action in the same turn. Never end a turn with a statement of intent.** A line like "Continuing the auto-mode chain — running `mano ui` next" followed by the turn ending is the chain silently stopping while claiming the opposite: the user is left holding a promise instead of a result, and no pause condition fired to explain it.

- ❌ finished log → `Next:` options → "Continuing — running `mano ui` next." → *turn ends*
- ✅ finished log → `mano ui` runs → its log → … → closing block when the chain stops

If you have written words describing what you are about to run, you have not run it. Either invoke it now, or name the pause condition (**The pause rule**) that stopped you. There is no third state where the chain is notionally continuing but nothing is executing.

**Between actions there is no `Next:` block and no transition line.** This is the one place a skill's canonical execution log is trimmed: `Next:` exists to tell a human which command to type, and mid-chain nobody is typing one. Offering options *and* claiming to continue is the contradiction that produces the failure above. `Next:` returns in the closing block, once the chain has actually stopped.

## What the chain prints

Each action still prints its own canonical execution log as it completes — the chain is not a silent batch, and the logs are the audit trail. When the chain stops, add one closing block that turns the run into the user's review agenda:

```text
[mano auto]: phase-[N] — [first] → … → [last]
- Ran: [actions, in order]
- Stopped: [completed implementation | waiting on the question below]
- Remaining: [ordered actions still approved for this run — omit only when none]
⚠ Verify: [every advisory flag collected across the run, one per line — omit if none]

[Hook findings triage, or the pending question, if that is why it stopped]

Next:
- [when implementation completed] `mano review` — when you have checked the result
- [when paused] Reply to the named question — the recorded remaining chain resumes automatically
```

Collecting the `⚠ Verify:` lines here matters: in manual mode the user sees each one as it appears, and in auto mode they would otherwise scroll back for them. This block is the thing they read before reviewing.

`mano dev yolo` keeps its strict aggregate implementation line. When it is the terminal action of an armed auto chain, that line is the dev action's log and the auto closing block follows it; this is the sole exception to the standalone YOLO rule that nothing may follow the aggregate line. Do not add an implementation recap between them. `mano build` behaves identically: its aggregate or deviation line is the action's log, then the closing block. Neither implementation skill loads this file, so both carry the same contract in `_mano/rules/implement.md` → **Closing an armed auto chain** — keep the two in step.
