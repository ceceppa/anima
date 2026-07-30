## Mode
suggest

## Purpose
Optional post-spec review after `mano spec` creates, updates, or validates technical artifacts.

## When useful
- API contract changed
- Data model changed
- Persistence strategy changed
- External interface changed
- High-impact technical decision changed
- Existing spec was checked and the user wants a specialist review before stories or implementation

## Inputs

Allow the review skill to read:
- `_mano_output/tech-spec.md` — technical decisions, dependencies, API contracts, data model, persistence, platform constraints
- `_mano_output/phase-[N]/phase-brief.md` — current phase scope, intended outcome, assumptions, risks
- `_mano_output/openapi.yaml` if it exists — machine-readable API contract
- project manifest and lockfile if they exist — actual installed dependencies and package manager evidence

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated artifact.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] review the technical design using the inputs listed in this hook.

Focus areas:
- Correctness of what's specified: API contract shape, data model integrity, persistence assumptions, interface consistency
- Cross-document consistency: contradictions or omissions relative to the phase brief
- Coverage: edge cases the spec doesn't address but should

Limit findings to these focus areas. Do not add commentary on testing strategy, deployment, code style, project structure, or topics outside the spec's stated concerns.

Output format: one bullet per finding. Each finding states the issue, the location in the artifact (section name), and the suggested fix. No prose preamble, no executive summary, no closing commentary.

Do not inspect source code, build output, test output, or any current implementation state. The artifact is the source of truth for this review — not the codebase. Do not request the user paste code or run commands to verify against. If the artifact appears inconsistent with implementation, that is `mano review`'s concern, not this hook's.

Do not modify any files. Report findings only. If the user wants changes made, they will run the appropriate Mano skill after reviewing your findings.
```

## Instruction for Mano

When this hook is active, do not run it automatically.

After the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation.