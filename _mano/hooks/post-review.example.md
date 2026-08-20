# post-review hook

## Mode
suggest

## Run
[the exact external command or skill to suggest — e.g. your drift-audit specialist]

## Inputs
- `_mano_output/reviews.md`, `_mano_output/backlog.md`, `_mano_output/tech-spec.md`
- `_mano_output/project-rules.md`, `_mano_output/design-brief.md`, `_mano_output/ux-flow.md`, if they exist
- the exact `BRIEF` path from the state projection
- source code **bounded to the modules the reviewed phase touched** — this is the one hook where comparing artifacts to implementation is the job

## Focus

<!-- What the review should look for, one `- ` line each.
     Uncomment what you want and edit freely — these are examples, not defaults.

- Drift between tech spec / project rules / design brief and what actually shipped.
- Backlog quality: are the review's spec-gaps, rule-gaps, and bugs well-scoped and actionable?
- Issues visible in the changed code that review didn't surface.
-->

One bullet per finding: issue, affected artifact or code location, and which Mano flow owns the resolution. No file modifications — findings only.
