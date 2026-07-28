## Mode
suggest

## Purpose
Optional post-rules review after `mano rules` creates or updates project rules.

## When useful
- New rules were added that materially change implementation patterns
- Existing rules were replaced or restructured
- Rules touch accessibility, naming, file organisation, or testing conventions
- The user wants a specialist sanity check before stories pick the rules up

## Inputs

Allow the review skill to read:
- `_mano_output/project-rules.md` — coding conventions, accessibility patterns, naming, file organisation, testing posture
- `_mano_output/tech-spec.md` if it exists — to verify rules don't restate spec decisions
- `_mano_output/phase-[N]/phase-brief.md` — to verify rules are scoped to current phase needs
- `_mano_output/ux-flow.md` if it exists — user-flow constraints that may require implementation rules
- `_mano_output/design-brief.md` if it exists — component, accessibility, and UI constraints that may require implementation rules

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated artifact.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] review the project rules using the inputs listed in this hook.

Focus areas:
- Enforceability: is each rule concrete enough for an implementer or linter to follow, or is it vague aspiration?
- Boundary integrity: does any rule restate decisions that belong in the tech spec (library choices, API contracts, data model)?
- Boundary integrity: does any rule encode domain logic, game mechanics, or business rules that belong in the spec or stories?
- Boundary integrity: does any rule encode exact tuning values, animation durations, or design tokens that belong in the design brief?
- Coverage: are there recurring patterns the rules should address but don't?
- Over-engineering: are there rules predicting future needs rather than addressing current ones?

Limit findings to these focus areas. Do not add commentary on which libraries the project uses, which framework patterns to adopt, or topics outside rule quality.

Output format: one bullet per finding. Each finding states the issue, the location in the artifact (rule name or section), and the suggested fix. No prose preamble, no executive summary, no closing commentary.

Do not inspect source code, build output, test output, or any current implementation state. The artifact is the source of truth for this review — not the codebase. Do not request the user paste code or run commands to verify against. If the rules appear inconsistent with implementation, that is `mano review`'s concern, not this hook's.

Do not modify any files. Report findings only. If the user wants changes made, they will run `mano rules` after reviewing your findings.
```

## Instruction for Mano

When this hook is active, do not run it automatically.

After the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation.