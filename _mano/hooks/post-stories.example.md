## Mode
suggest

<!-- Two kinds of hook. `suggest` (this one) produces findings: Mano asks
     before running it in manual/unarmed runs, runs it during an armed auto
     chain, and you approve
     each finding. Change this to `command`
     and add a `## Command` section naming one command to instead run that
     command automatically, every time, after this skill. See hooks/README.md. -->

## Purpose
Optional post-stories review after `mano stories` generates or updates story files for the current phase.

## When useful
- New phase with several stories worth a sanity check before implementation begins
- Stories touch unfamiliar territory and the user wants a specialist look at sequencing, AC quality, or scope
- The user wants a structural check on whether stories cover the phase goal and acknowledged risks

## Inputs

Allow the review skill to read:
- The exact `PHASE_DIR/stories/` from `state.js --current` — all story files for the current owner-aware phase
- The exact `STORIES` path from `state.js --current` — story index
- The exact `BRIEF` path from `state.js --current` — phase scope, goal, exit criteria, acknowledged risks
- `_mano_output/tech-spec.md` if it exists — to verify tech decisions appear in AC
- `_mano_output/project-rules.md` if it exists — to verify relevant rules are translated into stories
- `_mano_output/design-brief.md` if it exists — to verify visual contracts are referenced where needed
- `_mano_output/ux-flow.md` if it exists — user flow and interaction sequencing

Optional files may be missing. Do not fail because an optional file is absent. Use only the context relevant to the review target. Do not invent missing context.

## How to run

Run the relevant external or specialist review manually after reviewing and accepting the generated stories.

Use this hook as a reminder, not as automatic execution.

Replace `[external-review-command]` in your active project hook with the command or skill you want to run.

## Suggested prompt

```text
[external-review-command] review the story set for the current phase using the inputs listed in this hook.

Focus areas:
- Phase goal coverage: does at least one AC verify each distinct outcome and quality word from the phase brief's Phase goal?
- Acknowledged risks: is each risk in the phase brief addressed by at least one story's AC or explicitly flagged in Notes?
- AC quality: are acceptance criteria observable behaviour, or do any reference internal data structures, function names, formulas, or implementation style?
- Sequencing: can each story be verified through a real interface the moment it lands, or are there orphan stories with no externally verifiable exit?
- Reachability: does each interactive story name the surface, trigger, and entry path?
- Implementation Reference quality: are file paths, tokens, and ownership unambiguous (no "A or B", no "if not yet defined")?
- Scope sizing: is any story carrying more than one focused session of work?

Limit findings to these focus areas. Do not propose new stories, rewrite acceptance criteria, or suggest implementation approaches.

**Findings are diagnostic, not prescriptive.** Name the problem and, at most, point at a direction for the fix. Do not write replacement AC text, drafted wording, or "rewrite as: '…'" quotes — even as suggestions. The user owns the rewrite; the reviewer's job is to surface the issue precisely enough that the user (or a follow-up `mano stories` run) can act on it. "AC 7 uses internal enum names (DRAGGING, PENDING) — not observable to the player; rewrite to describe what the player sees" is a finding. "Rewrite as: 'Attempting column drag on an empty visual position…'" is a rewrite and is forbidden.

Output format: one bullet per finding. Each finding states the issue, the affected story file, and where the fix should focus. No drafted replacement text. No prose preamble, no executive summary, no closing commentary.

Do not inspect source code, build output, test output, or any current implementation state. The stories are the source of truth for this review — not the codebase. Do not request the user paste code or run commands to verify against. If a story appears inconsistent with implementation, that is `mano review`'s concern, not this hook's.

Do not modify any files. Report findings only. Mano keeps `mano stories` active, lists each finding, and applies only the story changes the user selects. Done stories still require lettered corrective work.
```

## Instruction for Mano

When this hook is active in a manual or unarmed run, do not run it automatically. During an armed auto chain, run this `suggest` hook automatically and pause only when findings require triage. If you change `## Mode` to `command`, the command runs automatically in both modes — see hooks/README.md.

In a manual or unarmed run, after the related Mano skill completes, mention that the hook is available and ask whether to run it.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not mention specific external skill names in generic Mano output.

Do not execute the hook without explicit user confirmation in a manual or unarmed run. An armed auto chain is the exception above.
