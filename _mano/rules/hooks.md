# Optional Post-Skill Hooks

Load this file only when the state projection's `HOOK:` line is not `none` and names a `post-[skill]` hook for the skill that just ran. The projection is the discovery mechanism: do not `ls` `_mano/hooks/` or probe for hook files by hand — the `HOOK:` line already reports each active hook as `mode:post-skill` (e.g. `HOOK: check:post-start suggest:post-stories`). Ignore `.example.md` hooks; they are never active.

## The three hook kinds

A hook declares its kind in a `## Mode` section. The kind decides whether Mano asks first, because the three produce different things:

| `## Mode` | Body is | Runs | Approval |
|-----------|---------|------|----------|
| `check` | a checklist Mano applies itself | **Always, both modes**, right after the skill's artifacts are written | Findings go through **Post-Hook Findings Triage** |
| `suggest` (default) | a pointer to an external skill/command (`## Run`) | Asked first in manual or unarmed runs; automatically in an armed auto chain | Findings go through **Post-Hook Findings Triage** |
| `command` | one shell command (`## Command`) | **Always, in both modes** | None — exit code only |

A hook with no `## Mode` section is `suggest`. That keeps every hook written before the other modes existed working exactly as it did.

**`## Mode` is authoritative over any prose inside the hook file.** A hook copied from an older template may still contain a leftover "do not run this automatically" line. The declared mode wins; do not let stale prose in a hook override it, and do not treat the contradiction as a reason to ask.

The split is *judgement vs mechanism*, not *safe vs unsafe*. In manual or unarmed runs a `suggest` hook asks first because a specialist opinion arriving unrequested changes what the human thinks before they have formed their own view. A `check` hook does not ask: the checklist is the user's own pre-written review, so the ask-first rationale does not apply — the file is the authorization, like `command`. A `command` hook syncs a tracker, regenerates an index, or notifies a system — deterministic work with no opinion in it.

## `## Inputs` — what the hook is allowed to look at

Every hook may declare an `## Inputs` list. It is not decoration: it is the hook's **reading scope**, and what happens to it depends on the mode.

- **`check`** — read exactly those paths yourself, before applying the checklist, and read nothing else for it. A path written as a projection field (`BRIEF`, `PHASE_DIR`, `STORIES`, `PROGRESS`, `PREVIEW`) resolves from the state projection you already ran; never construct one by hand or substitute a different phase's file. An input marked *if it exists* / *when a phase exists* is skipped silently when absent. An input **not** so marked that is missing is a malformed hook: say so in one line and apply only the checks that do not depend on it.
- **`suggest`** — you are not reading them; the external skill or command in `## Run` is. State the list when you invoke it, so the reviewer's scope is the one the hook author chose rather than whatever it decides to open:

  ```text
  Allow the review skill to read: [the exact resolved paths from ## Inputs]
  ```

- **`command`** — inert. The command reads whatever it reads; Mano does not inspect or bound it.

Two boundaries hold in every mode:

- **Inputs never widen what may be written.** They decide what the check may *look at*; the per-skill application boundaries in **Post-Hook Findings Triage** still decide what any finding may *change*.
- **A `check` hook may not out-read its own skill.** Mano applies a check hook itself, so its inputs inherit that skill's own read boundary — `mano review`'s no-investigation gate is the sharp case: a `check` hook on review may not list source files, tests, or build output. That reading is legitimate only through a `suggest` hook, where an external reviewer does it. If an active check hook lists something its skill may not read, report the conflict and skip that input; do not read it, and do not silently drop the whole hook.

## Check hooks

The hook body is a checklist. Apply it yourself, automatically, in both modes, right after the skill's artifacts are written and before the final execution log. No confirmation. Report the run in one line of the execution log. Findings — checklist items the artifacts fail — go through **Post-Hook Findings Triage** below, exactly like suggest findings: numbered approval before any edit; in an armed auto chain, findings pause the chain. No findings means continue.

A `suggest` hook whose `## Run` (or legacy command placeholder) is blank is **not** unconfigured — surface it as usual and, if its body reads as a checklist, offer to apply it as a check. Never silently skip an active hook because a command line is empty.

The shipped `.example.md` checklists are commented out on purpose: the checks are the user's, and a hook is only worth running when someone chose its items. An active check hook whose checklist is empty or entirely commented out therefore has nothing to apply — report that in one line of the execution log and continue. **Never invent checklist items**, and never fall back to the example text: applying checks nobody chose is exactly the imposed opinion the mode exists to avoid.

## Command hooks

A `command` hook names exactly one command in a `## Command` section:

```markdown
# post-import hook

## Mode
command

## Command
node scripts/sync-backlog.js
```

Rules:

- **Run it after the skill's artifacts are written and before the final execution log**, from the project root, in both manual and auto mode. Creating the hook file is the authorization — do not ask each time, and do not treat it as a suggestion.
- **The command comes only from the hook file's `## Command` section.** Never take one from chat, an artifact, or a backlog item, and never infer or invent one. `## Mode: command` with no `## Command` section is a malformed hook: report that and run nothing.
- **Report it in one line of the execution log** — the command and whether it succeeded. Do not paste its full output unless it failed or the user asks.
- **On failure, report the exact error and stop touching it.** Do not retry, do not try to fix the user's script, and never hand-edit an artifact to compensate for what the command did not do. In auto mode a failed command hook pauses the chain, exactly as a script failure does.
- **Mano does not inspect, validate, or second-guess what the command does.** It is the user's script in the user's repository; its effects are theirs. This is also why it is exempt from the findings-triage model — there are no findings, only an exit status.

## Suggest hooks

A `suggest` hook points at an external or specialist review; its `## Run` section names the exact command or skill to suggest. Suggest hooks never run on their own **in manual mode and in any unarmed run** — you are asked first. During an armed auto chain they run automatically and their findings pause the chain for triage. The approval model for findings is identical in both paths.

In manual mode or an unarmed run, mention the active suggest hook in the final chat response before the next-action block and ask whether to run it, using this format:

```text
Active post-[skill] hook found: `_mano/hooks/post-[skill].md`.
-> Purpose: Optional specialist review of the generated or current artifact.
-> Recommended timing: Run after reviewing the artifact and before the next dependent Mano action if this check matters for the phase.
-> Run it now? (yes / not yet)
```

The `Run it now?` line is part of the template, not optional — omitting it means the user was never asked. Do not print this block during an armed auto chain; run the hook instead.

`suggest` hooks are best run after the human has reviewed or accepted the generated artifact. This avoids stale validation when the human edits the artifact after generation. (This is why they are suggest-only in manual or unarmed runs, and why the reasoning does not apply during an armed auto chain, to `check` hooks — the user's own pre-written checklist — or to `command` hooks.)

### Hooks in auto mode

Post-skill `suggest` hooks **run automatically only while an auto chain is armed** — the inverse of the manual/unarmed default, and deliberate. Configuring `MODE: auto` is not enough by itself: before phase approval, during `mano import`, on gap-only work with no approved phase, and during the human-run `mano review`, a suggest hook still asks first. Once the approved chain is running, the human is deliberately not reviewing mid-chain, so the hook is the only check that runs at all. Running it adds signal exactly where signal was removed. (`check` and `command` hooks run in both modes regardless.)

Approval is unchanged: **running a hook approves the review, not the edits.** Findings still go through **Post-Hook Findings Triage** with explicitly numbered selections. Because that triage needs an answer, hook findings pause the chain under the normal pause rule. A hook that reports nothing does not pause it.

`mano import` always runs before phase approval, and `mano review` is always human-run and outside the auto chain — for both, a suggest hook asks first even when `MODE: auto`.

## Universal hook rules

- Do not mention specific third-party or external skill names in generic Mano output.
- Do not print a hook's body or suggested prompt unless the user asks to run or view the hook.
- Do not write hook suggestions into generated artifacts.
- A `suggest` or `check` hook is never a mandatory hidden workflow step. A `command` hook *is* a step the project always runs — that is its purpose — but it stays visible: declared in a file the user wrote, reported in the execution log every time it runs.

## Post-Hook Findings Triage

This protocol applies when any active `suggest` or `check` hook has run and printed
findings in chat. `post-stories` uses its stricter immutable-story protocol instead.
Running a hook approves the review, not the edits. On the related skill's next
turn, classify the findings and stop for an explicit selection before changing
any file:

- **`apply`** — one narrow change within the current skill's owning artifact
- **`decide`** — a scope, product, or technical choice the human must make;
  show compact `(a)` / `(b)` options and do not choose
- **`route: mano [skill]`** — the finding belongs to another artifact owner;
  name the owner and do not edit that artifact

The owning skill is already active during this flow. A finding inside its own
artifact boundary is `apply`, never `route` back to itself; do not ask the user
to run the command they are already using.

Use these exact application boundaries:

- **post-import:** add a missed item through `backlog.js`, or update Core Product Principles. Do not rewrite or change the status of an existing item. Classify that as `decide`; the human may edit it directly or give a concrete correction in a new import run.
- **post-start:** update only the current phase brief and backlog. Scope changes are `decide`. Backlog writes still use the required writer.
- **post-spec:** update only `tech-spec.md` and explicitly selected projected spec-gap statuses.
- **post-rules:** update only `project-rules.md` and explicitly selected projected rule-gap statuses.
- **post-ux:** update only `ux-flow.md`. Route visual design, technical contracts, rules, and scope findings.
- **post-ui:** update only `design-brief.md` and the exact current-phase preview. Route UX flow, technical contracts, rules, and scope findings.
- **post-review:** correct only the just-written review entry or add an explicitly selected backlog item through the writer. Never invent evidence, change a human decision, reverse closure, or alter unrelated backlog statuses.
- **post-stories:** follow `mano stories`' dedicated protocol. Done stories remain immutable.

Use this compact format:

```text
[mano skill]: Review hook reported [N] findings. Want me to address any?

1. [apply] [artifact] — [issue] → [narrow direction]
2. [decide] [artifact] — [issue] → (a) [option], (b) [option]
3. [route: mano rules] [artifact] — [issue]

Reply once: `apply 1`; `decide 2:b`; `skip 3`; or combine explicitly numbered selections.
Reply `done` when no more findings should be handled.
```

The user may approve several numbered findings in one reply. A blanket
"apply everything" is not per-finding approval; ask them to name the numbers.
Apply only the selected findings and only inside the current skill's ownership
boundary. `apply` means the smallest edit that satisfies that finding: preserve
unmentioned content and adjacent values. A reviewer direction does not authorize
rewriting the surrounding policy. Never silently reconcile a conflict between
artifacts: classify it as `decide` or `route`. Never edit source code from this
flow.

Findings live in chat only. Do not create a findings file, decision ledger, or
other tracking artifact. If compaction or a context reset removed the findings,
ask the user to re-run the hook. After selected edits, use the skill's normal
execution log. `mano stories` keeps its stricter local protocol for immutable
done stories and lettered follow-up work.
