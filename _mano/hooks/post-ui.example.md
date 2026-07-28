## Mode
suggest

## Purpose
Optional post-UI review after `mano ui` creates or updates the design brief.

## When useful
- New visual direction was established
- Shared components, tokens, or visual states were added
- Existing visual decisions were replaced or restructured
- The user wants a specialist sanity check on visual coherence before implementation

## Inputs

Allow the review skill to read:
- `_mano_output/design-brief.md` — visual direction, shared components, tokens, component states
- `_mano_output/ux-flow.md` if it exists — to verify every screen referenced by the flow has visual guidance
- `_mano_output/phase-[N]/phase-brief.md` — phase scope, including any visual-related items
- `_mano_output/project-rules.md` if it exists — implementation contracts, accessibility rules, and component constraints
- `_mano_output/tech-spec.md` if it exists — for platform constraints that affect flow (offline, biometrics, etc.)

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated artifact.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] review the design brief using the inputs listed in this hook.

Focus areas:
- Coverage: does every screen in the UX flow have matching visual guidance?
- Token consistency: are colour, spacing, and typography tokens used coherently, or do similar visual roles use inconsistent tokens?
- Component states: are loading, empty, disabled, error, and focus states defined for shared components that need them?
- Accessibility: do contrast targets, touch target sizes, and motion guidance appear where they materially affect users?
- Reusability: are components named and scoped well enough for stories to reference them, or do shared elements blur into screen-specific layouts?

Limit findings to these focus areas. Do not propose UX flow changes, screen sequencing, or user-decision branches — those belong to `mano ux`.

Output format: one bullet per finding. Each finding states the issue, the affected section in the design brief, and the suggested fix. No prose preamble, no executive summary, no closing commentary.

Do not inspect source code, build output, test output, or any current implementation state. The design brief is the source of truth for this review — not the codebase. Do not request the user paste code or run commands to verify against. If the design brief appears inconsistent with implementation, that is `mano review`'s concern, not this hook's.

Do not modify any files. Report findings only. If the user wants changes made, they will run `mano ui` after reviewing your findings.
```

## Instruction for Mano

When this hook is active, do not run it automatically.

After the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation.