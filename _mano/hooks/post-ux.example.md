## Mode
suggest

<!-- Two kinds of hook. `suggest` (this one) produces findings: Mano asks
     before running it in manual/unarmed runs, runs it during an armed auto
     chain, and you approve
     each finding. Change this to `command`
     and add a `## Command` section naming one command to instead run that
     command automatically, every time, after this skill. See hooks/README.md. -->

## Purpose
Optional post-UX review after `mano ux` creates or updates the UX flow.

## When useful
- New screens or flows were added
- An existing flow was restructured
- Branching paths, decision points, or user variants changed
- The user wants a specialist sanity check on flow coherence before stories pick it up

## Inputs

Allow the review skill to read:
- `_mano_output/ux-flow.md` — screen list, navigation structure, flow sequence, screen specs
- The exact `BRIEF` path from `state.js --current` — current owner-aware phase scope and goal
- `_mano_output/design-brief.md` if it exists — visual inventory and shared components
- `_mano_output/tech-spec.md` if it exists — for platform constraints that affect flow (offline, biometrics, etc.)

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated artifact.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] review the UX flow using the inputs listed in this hook.

Focus areas:
- Reachability: can every screen in the list be reached from a defined entry point, or are any orphaned?
- Exit paths: does every screen have a clear way back, forward, or out?
- Overloaded screens: does any screen handle more than two primary product actions or decisions?
- Branching coverage: are choice-dependent paths fully described, or do branches trail off?
- Phase alignment: does the flow cover the phase goal's user-visible outcomes?
- State transitions: are loading, empty, and error states named where they materially affect the user?

Limit findings to these focus areas. Do not propose visual design, component layouts, copy, or styling decisions — those belong to `mano ui` and the design brief.

Output format: one bullet per finding. Each finding states the issue, the affected screen or flow section, and the suggested fix. No prose preamble, no executive summary, no closing commentary.

Do not inspect source code, build output, test output, or any current implementation state. The UX flow is the source of truth for this review — not the codebase. Do not request the user paste code or run commands to verify against. If the flow appears inconsistent with implementation, that is `mano review`'s concern, not this hook's.

Do not modify any files. Report findings only. If the user wants changes made, they will run `mano ux` after reviewing your findings.
```

## Instruction for Mano

When this hook is active in a manual or unarmed run, do not run it automatically. During an armed auto chain, run this `suggest` hook automatically and pause only when findings require triage. If you change `## Mode` to `command`, the command runs automatically in both modes — see hooks/README.md.

In a manual or unarmed run, after the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation in a manual or unarmed run. An armed auto chain is the exception above.
