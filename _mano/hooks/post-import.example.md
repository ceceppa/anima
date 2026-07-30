# post-import hook

## Mode
suggest

## Purpose
Optional post-import review after `mano import` decomposes a PRD or document into the backlog.

## When useful
- a new backlog was just created from a document
- the document was large or ambiguous and the decomposition is worth a second pass
- Core Product Principles were captured from the document
- you want to check the backlog faithfully covers the source before scoping a phase

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated backlog.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Inputs

Allow the review skill to read:

- `_mano_output/backlog.md` — the decomposed backlog, Core Product Principles, and item statuses
- the source document `mano import` ran against, if still available — to check coverage and fidelity

Optional files may be missing. Do not fail because an optional file is absent.

Use only the context relevant to the review target. Do not invent missing context.

## Suggested prompt

```text
[external-review-command] review the imported backlog using the inputs listed in this hook.

Focus on:
- coverage: every feature, requirement, and success criterion in the source appears as a backlog item
- fidelity: items preserve the source's specific detail, not vague summaries
- duplicates or overlapping items
- Core Product Principles captured accurately and not invented
- any stated technical preference preserved verbatim in item context, not decided

Report missing items, lossy summaries, duplicates, and contradictions with the source.

Do not inspect source code.
Do not scope a phase or suggest what ships first.
Do not modify files unless explicitly asked.
```

## Instruction for Mano

When this hook is active, do not run it automatically.

After the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation.
