# post-start hook

## Mode
suggest

## Purpose
Optional post-start review after `mano start` creates or updates the backlog, phase suggestion, or phase brief.

## When useful
- a phase was scoped from a backlog that originated in conversation or a prior `mano import`
- phase scope was suggested or approved
- Core Product Principles changed
- backlog structure or statuses changed
- phase brief was created or updated

## How to run

No external review command is configured for this hook. **An unconfigured command is not a reason to skip this hook.** When the hook fires (per Mode/Instruction below), Mano performs the review itself directly against the checklist in "Suggested prompt" — reading the same inputs an external tool would, and reporting findings the same way. Only replace the missing command below with a real external tool/skill if the project later wants that specialist opinion instead of Mano's own; until then, self-review is the default execution path, not a fallback for when nothing else is set up.

External command/skill (optional — leave blank to keep self-review as the path): `[external-review-command]`

## Inputs

Allow the review skill to read:

- `_mano_output/backlog.md` — backlog structure, Core Product Principles, deferred work, and item statuses
- `_mano_output/phase-[N]/phase-brief.md` if it exists — approved phase scope and current phase context
- `_mano_output/reviews.md` if it exists — prior phase findings, unresolved feedback, and lessons that may affect the next phase

Optional files may be missing. Do not fail because an optional file is absent.

Use only the context relevant to the review target. Do not invent missing context.

## Suggested prompt

```text
[external-review-command] review the planning artifacts using the inputs listed in this hook.

Focus on:
- backlog structure and status accuracy
- phase scope risks
- missing or over-broad backlog items
- Core Product Principles preservation
- contradictions with the source brief
- whether the phase scope includes the right demo coverage for the work it introduces
- for runtime-facing work, whether the phase should include a playground demo under `examples/playground/`
- for editor-facing work, whether the phase should include an editor demo under `examples/editor/`
- whether any phase that introduces a new or changed runtime or editor capability is missing a matching example/demo plan

Report issues, risks, contradictions, and suggested improvements.

Do not inspect source code.
Do not compare the phase brief spec against the existing implementation.
Do not modify files unless explicitly asked.
```

## Instruction for Mano

This is a `suggest` hook — see `_mano/workflow.md` → **Optional Post-Skill Hooks** for the full contract. Two distinct run paths, both real, neither optional to consider:

- **Manual or unarmed run:** do not run it automatically. Mention it's available and ask whether to run it. Do not print the suggested prompt unless asked.
- **Armed auto chain** (the human approved the phase scope and the chain is running): run it automatically, immediately after the phase brief is written — no confirmation needed, no "nothing configured" exception. Findings still go through Post-Hook Findings Triage.

Never skip this hook because the "External command/skill" field above is blank — blank means self-review (see "How to run"), not "inactive." A hook file existing at all is the authorization to run it per the rule above; the missing external command changes *who* performs the review, never *whether* it runs.

Do not mention specific external skill names in generic Mano output.
