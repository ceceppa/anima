## Mode
suggest

<!-- Two kinds of hook. `suggest` (this one) produces findings: Mano asks
     before running it in manual/unarmed runs, runs it during an armed auto
     chain, and you approve
     each finding. Change this to `command`
     and add a `## Command` section naming one command to instead run that
     command automatically, every time, after this skill. See hooks/README.md. -->

## Purpose
Optional post-UI review after `mano ui` creates or updates the design brief and current phase preview.

## When useful
- New visual direction was established
- Shared components, tokens, or visual states were added
- Existing visual decisions were replaced or restructured
- A phase screen composition was added or changed
- The user wants a specialist sanity check on visual coherence before implementation

## Inputs

Allow the review skill to read:
- `_mano_output/design-brief.md` — visual direction, shared components, tokens, component states
<!-- mano-rule: id=ui-phase-preview-ownership; incident=cross-phase-preview-overwrite; model=codex; date=2026-08-03; eval=ui-phase-preview,ui-no-phase-preview -->
- The exact current `PREVIEW` path from `state.js --ui` if it exists — the non-canonical snapshot to compare with the current phase's brief entry. Do not read a prior/different-owner preview or a legacy root `_mano_output/design-preview.html`.
<!-- /mano-rule: ui-phase-preview-ownership -->
- `_mano_output/ux-flow.md` if it exists — to verify every screen referenced by the flow has visual guidance
- The exact `BRIEF` path from `state.js --ui` — owner-aware phase scope, including any visual-related items
- `_mano_output/project-rules.md` if it exists — implementation contracts, accessibility rules, and component constraints
- `_mano_output/tech-spec.md` if it exists — for platform constraints that affect flow (offline, biometrics, etc.)

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated artifact.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] review the design brief and current phase preview using the inputs listed in this hook.

Focus areas:
- Coverage: does every screen in the UX flow have matching visual guidance?
- Token consistency: are colour, spacing, and typography tokens used coherently, or do similar visual roles use inconsistent tokens?
- Component states: are loading, empty, disabled, error, and focus states defined for shared components that need them?
- Accessibility: do contrast targets, touch target sizes, and motion guidance appear where they materially affect users?
- Reusability: are components named and scoped well enough for stories to reference them, or do shared elements blur into screen-specific layouts?
- Preview fidelity: does the current phase preview demonstrate only the current phase composition while matching the cumulative brief's relevant tokens and components?

Limit findings to these focus areas. Do not propose UX flow changes, screen sequencing, or user-decision branches — those belong to `mano ux`.

Output format: one bullet per finding. Each finding states the issue, the affected section in the design brief, and the suggested fix. No prose preamble, no executive summary, no closing commentary.

Do not inspect source code, build output, test output, or any current implementation state. The design brief is the source of truth for this review — not the codebase. Do not request the user paste code or run commands to verify against. If the design brief appears inconsistent with implementation, that is `mano review`'s concern, not this hook's.

Do not modify any files. Report findings only. If the user wants changes made, they will run `mano ui` after reviewing your findings.
```

## Instruction for Mano

When this hook is active in a manual or unarmed run, do not run it automatically. During an armed auto chain, run this `suggest` hook automatically and pause only when findings require triage. If you change `## Mode` to `command`, the command runs automatically in both modes — see hooks/README.md.

In a manual or unarmed run, after the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation in a manual or unarmed run. An armed auto chain is the exception above.
