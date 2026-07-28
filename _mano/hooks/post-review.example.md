## Mode
suggest

## Purpose
Optional post-review audit after `mano review` triages a phase and writes findings to the backlog.

## When useful
- A phase just closed and the user wants a deeper specialist look at code quality, architecture drift, or accumulated technical debt
- Review identified spec gaps or rule gaps and the user wants a specialist confirmation before scoping the next phase
- The user wants a structured comparison between what shipped and what the planning artifacts described

## Inputs

Allow the audit skill to read:
- `_mano_output/reviews.md` — phase review findings and triaged items
- `_mano_output/backlog.md` — items the review wrote, including spec-gaps and rule-gaps
- `_mano_output/tech-spec.md` — technical decisions for comparison
- `_mano_output/project-rules.md` if it exists
- `_mano_output/design-brief.md` if it exists
- `_mano_output/ux-flow.md` if it exists — user-flow assumptions that may need updates after review
- `_mano_output/phase-[N]/phase-brief.md` — phase that was just reviewed

Source code access for this hook: **allowed** but bounded. This is the only Mano hook where comparing artifacts to implementation is part of the job, since `mano review` is the drift-detection step. Inspection should be scoped to the modules and files that changed in the reviewed phase. Do not perform a project-wide audit unless the user explicitly asks.

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the review findings.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] audit the closed phase using the inputs listed in this hook.

Focus areas:
- Drift between tech spec and implementation: are decisions in the spec actually reflected in the code that shipped?
- Drift between project rules and implementation: are rules being followed consistently?
- Drift between design brief and implementation: do shipped screens match the documented visual direction?
- Backlog quality: are the spec-gaps, rule-gaps, and bugs that review identified well-scoped and actionable?
- Missed concerns: are there issues visible in the changed code that review didn't surface?

Limit findings to these focus areas. Do not propose new features, suggest architectural rewrites, or comment on code unrelated to the reviewed phase.

Source code inspection: allowed and expected for this hook, but bounded to modules touched in the reviewed phase. Do not perform a project-wide code audit. Do not propose changes to unrelated code.

Output format: one bullet per finding. Each finding states the issue, the affected artifact or code location, and either the suggested fix or which Mano flow owns the resolution (`mano spec`, `mano rules`, `mano start` for backlog adjustment). No prose preamble, no executive summary, no closing commentary.

Do not modify any files. Report findings only. If the user wants changes made, they will run the appropriate Mano skill after reviewing your findings.
```

## Instruction for Mano

When this hook is active, do not run it automatically.

After the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation.