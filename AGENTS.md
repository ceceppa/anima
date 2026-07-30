<!-- MANO:BEGIN -->
# AGENTS.md

This project uses **Mano** for planning. Mano is a structured thinking tool — it produces planning artifacts, not code.

## For coding agents

### Running Mano commands

Mano commands are repo-local workflow instructions, not installed OpenCode skills.

If the user types a Mano command in chat, do **not** try to load an external skill named `mano`.

Instead, execute the corresponding Mano planning flow by reading the local files in this repository:

- `_mano/workflow.md`
- `_mano/skills/[command].md`
- any referenced templates or current `_mano_output/` artifacts

Examples:

- `mano import` → read `_mano/skills/import.md` and follow that flow (PRD/document → backlog)
- `mano start` → read `_mano/skills/start.md` and follow that flow
- `mano spec` → read `_mano/skills/spec.md` and follow that flow
- `mano rules` → read `_mano/skills/rules.md` and follow that flow
- `mano stories` → read `_mano/skills/stories.md` and follow that flow
- `mano review` → read `_mano/skills/review.md` and follow that flow
- `mano dev` → implement the next pending story; read `_mano/skills/dev.md` and follow the "Implementing a story" contract below
- `mano continue` → read `_mano/workflow.md` and determine the next useful Mano action

Note: `mano dev` is the one Mano command that produces code. Every other command above is planning only. `mano dev` runs the "Implementing a story" contract in this file; `_mano/skills/dev.md` is a thin pointer back here.

If a platform skill named `mano` is not available, that is not an error. Continue by using the local `_mano/` files.

The skill name uses a **hyphen, never a colon**: `mano import` → `mano-import` (read `_mano/skills/import.md`), not `mano:import`. The colon form is plugin-namespace syntax and matches no Mano skill. If a `mano <action>` seems unavailable, try the hyphenated `mano-<action>` before concluding it doesn't exist.

Only use external/platform skills when the user explicitly invokes them or when a Mano hook asks whether to run one and the user confirms.

### Implementing a story

This is the contract for `mano dev` — the sanctioned path from a finished `stories/` folder into code. When the user wants to implement, this is the section to follow. `_mano/skills/dev.md` only points here; the steps below are authoritative.

1. **Find what to implement by running the state script — do not `ls` for the phase or infer it from the conversation.** Run `node _mano/scripts/state.js --next`. It reads the filesystem *this turn* and reports the active phase (`PHASE:`), the next pending story (`STORY:` / `FILE:`), and the full ordered story list — computed deterministically, so a stale phase carried in the chat (a previous phase's stories, a closed phase, an earlier `mano dev`/`mano review` run) can't mislead you. Obey its `PHASE`/`STORY`/`FILE`. If it reports nothing to implement (no phase, no brief, no stories, or all done), follow the line it prints and stop — do not scan for work it didn't report. **If the script cannot run (command fails, errors), stop and report the exact failure — do not scan for the phase by hand or guess it from context.** Mano requires Node (it was installed with `npx`); a failing script is an environment problem for the user to fix, not a license to work around the projection.
2. The script's `Stories` block **is** `_mano_output/phase-[N]/stories/README.md`, normalized — it already applies "Status is the only signal" and marks the next pending row with `→`. Use it for steps 3–5; reopen the README only when the script was unavailable.
3. **Hard stops.** If every story in the index is already `done`, STOP. Do not start, scope, or plan a new phase. All stories being done means the phase is built, not closed: `mano review` is mandatory before `mano start` can scope another phase. Output one line stating that the phase is built and must be closed with `mano review`, then stop. Do not call the phase complete or present `mano start` as an equal option. If a user-requested story does not exist but other rows are still pending, stop and say the requested number was not found; name the actual next pending story from the state output. Do not describe that phase as built or complete. These are hard stops, not guidelines.

   **The `Status` column is the only signal — read it, do not interpret around it.** A story is implementable if and only if its Status is not `done` (e.g. `pending`). This decision is made *purely* from the Status column. A story's number, letter, title, or description carries **no** authority over whether it is in scope:
   - There is no "refinement", "extra", "optional", "addendum", or "follow-up" class of story that the user must separately ask for. If a row is in the index and not `done`, it is in scope. Never invent such a category to justify stopping.
   - A lettered story (`4a`, `4b`) is **not** a sub-part of a done story `4` that inherits its done-ness. It is its own ordered, pending work. Letters and numbers are ordering only, never a done-ness signal.
   - "The core stories are done" / "the main work is finished" is **not** a stop condition. The only stop condition is *every row is `done`*. If even one row is `pending`, the phase is not done — implement the next pending story; do not announce the phase complete.
   - Before stating that implementation is built, count the rows whose Status is not `done`. If that count is greater than zero, it is not built — implement the next pending row. If the count is zero, say built but not closed; only `mano review` makes the phase complete.
4. Before implementing the requested story, check whether any earlier story in the index is still `pending`. Treat numbered stories and lettered insertions as ordered work unless the README or story notes explicitly say otherwise.
5. If an earlier story is still `pending`, stop and tell the user which story would be skipped. Do not implement the later story unless the user explicitly confirms they want to bypass the suggested order.
6. Read the story file first. Treat it as the primary implementation contract and expect it to be sufficient for correct implementation. The Implementation Reference section should carry the applicable rules plus any required files, modules, contracts, constraints, ownership boundaries, and prohibitions for that story. Treat exact prop names, attribute names, variant names, state keys, ownership statements, file paths, dependency names, and install commands written there as normative.
7. If the story is bootstrap, setup, tooling, infrastructure, or dependency-related, also read `_mano_output/tech-spec.md` before implementing. Treat library choices, package-manager choice, and install commands there as normative unless the story file already repeats them exactly.
8. Execute install commands exactly as written. Do not merge separate command groups, switch tools, or normalize mixed-tool instructions into a single package-manager invocation unless the story or tech spec explicitly tells you to. In particular, keep `npx expo install` commands separate from `npm install` or other package-manager commands so Expo can resolve SDK-compatible versions.
9. If the story involves user-entered state, forms, onboarding drafts, settings, or other local data, check whether the story or tech spec says that data should persist across app restarts. If it should, treat restart persistence as part of the required behaviour, not as an optional enhancement.
10. Read `_mano_output/project-rules.md` only when the story explicitly points to a rule there, something remains ambiguous after reading the story and any mandatory tech-spec pre-read, or you need fuller context behind a rule already summarized in the story.
11. After implementing, mark the story `done` via the index writer — do **not** hand-edit the README table:
    ```
    node _mano/scripts/stories.js set-status --phase [N] --story [num] --status done
    ```
    `[num]` is the story's `#` in the index (`4`, or `4a` for a lettered insertion). The script flips only that row and leaves the table shape — which `mano review` and the state script both parse — intact. If the script cannot run, stop and report it as a deviation (step 12a) — the story is implemented but not marked done. Do not hand-edit the table: a mis-aligned pipe corrupts a file two other skills parse, and the failing script is an environment problem for the user to fix.
12. **Final step — output exactly one line, then stop.** Your entire chat response for the implementation is a single line: `Story [N] done — status updated in stories/README.md`. Do NOT precede it with a recap, a "let me summarize what was done", a ✅ checklist of created files, an "AC met" list, or any narrative. The story already contains the acceptance criteria; restating them is pure noise. Exactly two additions are permitted, and only when one genuinely applies: (a) a short note for a real deviation — an AC you could not meet, an assumption you made, follow-up needed; and (b) a project-relevant decision worth preserving (a colour value, dimension, performance budget, accessibility measurement, architectural pattern, or library quirk discovered in practice), surfaced with an offer to capture it in the right artifact per "Implementation Output Discipline" below. Neither applies → the one line is the whole response. Nothing else is permitted. This is a hard stop, not a guideline.

## Implementation Output Discipline

When implementing a Mano story, the implementing agent writes code and updates the story's status. It does not append completion reports, verification logs, behavioural confirmations, or implementation narratives to the story file.

It also does not print these to chat. After implementing, the only required chat output is a single line confirming the story is done and its status was moved to `done` in the stories README — for example: `Story 4 done — status updated in stories/README.md`. Do not restate acceptance criteria, list "AC Met", enumerate created files, or write an implementation summary. The acceptance criteria already live in the story; echoing them back adds no information and only grows the conversation. Report only deviations: AC that could not be met, assumptions made, or follow-up needed. If there are none, the one-line confirmation is the complete response.

If implementation produces project-relevant decisions worth preserving — colour values, dimensions, performance budgets, accessibility measurements, architectural patterns, technique choices, library quirks discovered in practice — the agent surfaces them in chat and offers to capture them in the appropriate artifact:

- Architectural or repeatable conventions → `_mano_output/project-rules.md`
- Visual or design decisions → `_mano_output/design-brief.md`
- Story-specific behavioural changes → the story's `## Changes` section (see "In-Flight Story Changes" below)

The story file remains a planning artifact, not an implementation log. This applies to all implementing agents, including third-party language specialists and external coding skills.

## In-Flight Story Changes

The acceptance criteria are the behavioural contract for the current story. Do not invent new behaviour, validation, edge cases, or product rules beyond the story on your own initiative.

**`Not this story` is a hard boundary, not advice.** If the story has a `Not this story` (or equivalently-named out-of-scope) section, every item in it is a prohibition with the same force as a `Do not:` line. Implement none of it, even when the surrounding code, the chosen node/type/component, or a library default makes that behaviour the "natural" or "obvious" thing to add. A common trap: the story names a type whose typical use implies a behaviour the story excludes (e.g. an animated-sprite type used to show a *static* frame, a form widget used without its usual validation). The named type does not authorise the implied behaviour — the `Not this story` line overrides what the type "wants" to do. When a `Not this story` item and your instinct conflict, the `Not this story` item wins; if you believe an excluded item is genuinely required for the AC to work, that is a gap — stop and surface it, do not implement it on your own initiative.

When implementation reveals a gap:

- **Clear user-directed behaviour change:** implement it. Add a `## Changes` note only if the change affects future stories, tests, specs, rules, UX, or review.
- **Ambiguous or scope-expanding change:** ask one clarification or suggest a follow-up story.
- **Bug fix that satisfies existing AC:** implement it. No `## Changes` entry needed.
- **Agent-discovered missing decision:** stop and tell the user which Mano flow owns the decision (`mano spec`, `mano rules`, or `mano stories`). Do not invent it.
- **Change that may invalidate spec, rules, or UX:** mention it for the next `mano review`; do not reconcile artifacts mid-story.

Principle: update the story file only when the change becomes future context.

When a `## Changes` note is warranted, use:

```md
## Changes

- [Short context]: [what changed] because [why it changed].
```

### Do not

- Modify files in `_mano/` or `_mano/templates/` — these are framework files.
- Interpret `mano` commands (e.g. `mano start`, `mano review`) as implementation instructions — these are planning commands. Execute the relevant planning flow instead.
- Create extra tracking files — Mano does not use a dedicated state file. Determine state by reading `_mano_output/` and the latest `phase-[N]/` artifacts.
- Auto-advance phases. A completed phase (all stories `done`) never triggers planning or implementing the next one. Stop and let the user decide; never run `mano start`/`mano stories` on your own initiative.

## Project structure

```
_mano/                    ← Mano framework (do not modify during implementation)
├── skills/               ← Mano skill prompts
├── scripts/              ← state.js (read-only state projection), backlog.js / stories.js (index writers)
├── hooks/                ← optional post-skill hook reminders
└── templates/            ← Mano templates
_mano_output/             ← Planning artifacts
├── project-rules.md      ← Rules for implementation (referenced by stories)
├── tech-spec.md          ← Technical decisions
├── ux-flow.md            ← Screen and navigation definitions
├── design-brief.md       ← Visual language
├── backlog.md            ← Future work and deferred items
├── reviews.md            ← Sprint review history (human-only)
└── phase-[N]/            ← Per-phase work
    ├── phase-brief.md    ← Phase scope and goals
    └── stories/          ← Implementation stories (start here)
```

## Context Discipline

Roles in Mano are reasoning lenses, not isolated autonomous agents.

Specialization is maintained through selective context exposure and user discipline. Models may still merge assumptions or infer information outside the intended scope.

Use each role to focus attention on a specific planning concern rather than assuming strict separation.

## Post-Skill Hooks

After completing a Mano skill, check `_mano/hooks/` for an active post-hook matching the skill name.

Examples:
- `mano import` checks for `_mano/hooks/post-import.md`
- `mano start` checks for `_mano/hooks/post-start.md`
- `mano spec` checks for `_mano/hooks/post-spec.md`
- `mano rules` checks for `_mano/hooks/post-rules.md`
- `mano ux` checks for `_mano/hooks/post-ux.md`
- `mano ui` checks for `_mano/hooks/post-ui.md`
- `mano stories` checks for `_mano/hooks/post-stories.md`
- `mano review` checks for `_mano/hooks/post-review.md`

Ignore `.example.md` hooks.

Hooks are suggest-only. Do not run them automatically.

<!-- mano-rule: id=post-hook-findings-triage; incident=hook-output-triage-gap; model=not-recorded; date=2026-05-29; eval=hook-triage-no-approval,hook-triage-selected-only,hook-triage-start-no-approval,hook-triage-rules-no-approval -->
When a just-run `post-start`, `post-spec`, or `post-rules` hook has printed
findings in chat, keep the matching Mano skill active and follow
`_mano/workflow.md` → **Post-Hook Findings Triage**. Running the hook did not
approve edits. An in-lane finding is `apply`, never a route back to the skill
already running; a finding owned by another artifact is `route: mano [owner]`
and must not be edited here. Apply the smallest selected change and preserve
unmentioned content and adjacent values.
<!-- /mano-rule: post-hook-findings-triage -->

If an active hook exists, mention it in the final response before the next-action block:

```text
Active post-[skill] hook found: `_mano/hooks/post-[skill].md`.
-> Purpose: Optional specialist review of the generated or current artifact.
-> Recommended timing: Run after reviewing the artifact and before the next dependent Mano action if this check matters for the phase.
```

Do not mention specific third-party or external skill names in generic Mano output.

Do not print the hook's suggested prompt unless the user asks to run or view the hook.

Do not execute hooks without explicit user confirmation.

Do not write hook suggestions into generated artifacts.
<!-- MANO:END -->
