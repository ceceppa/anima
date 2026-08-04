# post-start hook

## Mode
suggest

<!-- Two kinds of hook. `suggest` (this one) produces findings: Mano asks
     before running it and you approve each finding. Change this to `command`
     and add a `## Command` section naming one command to instead run that
     command automatically, every time, after this skill. See hooks/README.md. -->

## Purpose
Optional post-start review after `mano start` creates or updates the backlog, phase suggestion, or phase brief.

## When useful
- a phase was scoped from a backlog that originated in conversation or a prior `mano import`
- phase scope was suggested or approved
- Core Product Principles changed
- backlog structure or statuses changed
- phase brief was created or updated

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated artifact.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Inputs

Allow the review skill to read:

- `_mano_output/backlog.md` — backlog structure, Core Product Principles, deferred work, and item statuses
- The exact `BRIEF` path from `state.js --current` if it exists — approved phase scope and current phase context
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

Report issues, risks, contradictions, and suggested improvements.

Do not inspect source code.
Do not compare the phase brief spec against the existing implementation.
Do not modify files unless explicitly asked.
```

## Instruction for Mano

When this hook is active, do not run it automatically. (This applies to `## Mode: suggest`, which is what this file declares. If you change `## Mode` to `command`, the mode wins over this line and the command runs automatically — see hooks/README.md.)

After the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation.
