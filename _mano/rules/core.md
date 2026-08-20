# Mano core rules

Shared execution rules for the planning skills. A skill's front-matter names the `_mano/rules/` files it needs; when it names this one, read it once at activation, before the state projection. Not every skill requires it: the config skills (`mano owner`, `mano mode`, `mano track`) and the two implementation skills (`mano dev`, `mano build`) load their own narrower contracts instead — implementation's shared contract is `_mano/rules/implement.md`. Do not open `_mano/workflow.md` mid-skill — it is the dispatcher for the bare `mano`, `help`, `status`, and `continue` commands only.

## Optional Phase Ownership

Phase ownership is opt-in and local to a repository clone:

- No owner configured: preserve the original `_mano_output/phase-N/`, `in-phase-N`, and `## Phase N Review — date` behavior. Never migrate or rename these artifacts automatically, even when owned folders also exist.
- `mano owner alice`: store the stable lowercase slug in repository-local Git config and route this clone to `_mano_output/alice-phase-N/`, `in-alice-phase-N`, and `## Phase N Review — Owner: alice — date`. Numbering is independent per owner.
- `mano owner clear`: return this clone to legacy `phase-N` routing without touching owned folders.
- Linked worktrees share repository-local Git config. `MANO_OWNER` may override it for a shell or worktree when those worktrees need different owners. Never infer an owner from `whoami`, an OS account, or an email address.
- Two people may configure the same slug to hand over or pair on one phase. Different slugs select separate active phase sequences. Another owner's unfinished phase does not block `mano start` for the configured owner.

Ownership is routing, not merge isolation. The backlog and cumulative tech spec, UX flow, design brief, project rules, and reviews remain shared files. Teammates still need branches/worktrees, disjoint phase scope, and normal merge coordination.

## Optional Work Tracks

Tracks group one person's parallel experiments or product directions without replacing phase scope. They are opt-in and local to a repository clone:

- `mano track "Option B"` stores the current track in repository-local Git config (`mano.track`); `mano track clear` removes it. `MANO_TRACK` overrides Git config for one shell/worktree.
- `Source` remains provenance—where an item came from. `Track` is the experiment/direction it belongs to. One backlog item may carry both.
- An active track is applied to new imports and conversation-created backlog items. It filters `mano start` to matching-track candidates and is copied into the approved phase brief. Every review-created item copies the **phase brief** track, not whatever track happens to be active when the review runs.
- Track never selects scope, bypasses approval, or overrides stories/spec/UX/rules/phase conflict gates. `mano track clear` changes only future commands; it never rewrites existing backlog items or briefs.

## State detection — deterministic projections

A phase's ledger is `stories/README.md` or `PHASE_DIR/progress.md` — one or the other, never both — and each is written only through its own script (`stories.js`, `progress.js`). Nothing else in a project is mutable state. The filesystem remains the source of truth, but agents must read it through `_mano/scripts/state.js`. Do not infer the active phase from chat context, directory listings, or manually opened sibling artifacts. If the script fails or omits a required field, report the failure and stop instead of guessing. Humans should not need to mention phase files merely to correct stale routing.

Every phase-scoped skill must use `state.js` and its exact `MODE`, `OWNER`, `PHASE_ID`, `PHASE_DIR`, paths, in-phase status, and review-heading prefix. The numeric `PHASE` is only for display and writer arguments; never construct a directory or status from it. Re-read `MODE` from the freshest projection before handoff: it may change whether the skill returns or resumes a chain, but it is not phase identity and does not invalidate an otherwise safe write. In Mano documents, `phase-[N]` examples describe default legacy mode. In owner-scoped mode, exact state projections override those examples.

The projection also prints `HOOK:` (the active post-skill hooks and their modes, or `none`) and `ARTIFACTS:` (presence of the four optional project-level artifacts). Use these lines instead of probing the filesystem for hooks or opening artifacts merely to see whether they exist.

To detect implementation status, use the exact `STORIES` path from `state.js --current` or `state.js --next` — or the exact `PROGRESS` path when the projection reports one, which means the phase is being built with `mano build`. A phase has one ledger or the other; the projection refuses one holding both. The phase is built and ready for review when every story is `done`, or when every Scope row is `done` and every Exit Criterion is `met`.

## Scripts are mandatory

Where a skill names a `node _mano/scripts/...` command, that command is the only sanctioned way to make that edit or read that projection. Mano is installed with `npx`, so Node is present by construction — there is no supported no-Node mode. If a script invocation fails (command not found, error, unexpected output), **stop and report the exact failure to the user**; do not hand-write the file, hand-edit a status, or re-derive the projection by scanning. A hand-written approximation of a script-owned format is the drift the scripts exist to make impossible. The only hand-edits allowed are the ones a skill explicitly sanctions (the backlog's `## Core Product Principles` section, an item's title/context during a split, the follow-up review's title-scoped resolves, and the user's own direct edits).

## Skill conduct

**No invented files.** Skills only write planning artifacts defined by the Mano contract under `_mano_output/`. The installer owns the root-level `AGENTS.md` scaffold; skills do not create it. Do not create tracking files, scratch notes, status files, or any other artifact the framework does not specify. The framework specifies exactly two ledgers — `PHASE_DIR/stories/README.md` and `PHASE_DIR/progress.md` — and each is written only by its own script. What is forbidden is *inventing* state, not keeping it.

**Templates are read-only.** No skill may modify files in `_mano/templates/`. Templates are source material used to create output files only when the relevant action is explicitly run. Planning artifacts write to `_mano_output/`; the installer-managed `AGENTS.md` is the framework's only root-level scaffold.

**Greenfield scaffolding is staged, never destructive.** Mano's own files make a planning-first project non-empty, while many project generators require an empty destination. If a generator creates the application root, `mano spec` records an exact `node _mano/scripts/scaffold.js run ... -- ... {target}` command and bootstrap implementation uses only that command. The script runs the generator outside the project, ignores the staged generator's `.git`, rejects staged `_mano` / `_mano_output` paths and symbolic links, preflights all destinations, retains identical files, and adds only missing files. A differing collision aborts before copying. No skill or implementing agent may make room by moving, deleting, renaming, or hiding project files, nor replace the script with a manual copy or merge. A script error or collision is a blocker to report, not permission to improvise. This applies equally in manual, `yolo`, and auto modes.

**Refuse code generation.** As an AI agent, your primary directive during Mano phases is planning. You MUST actively refuse requests to write, fix, or modify source code. If a user describes a problem during any skill's flow, treat it as planning input — scope it, write a story for it, or add it to the backlog. Do not switch to implementation mode. (`mano dev` and `mano build` are the two implementation entry points and are exempt; their contracts are `_mano/skills/dev.md` and `_mano/skills/build.md`, each plus the shared `_mano/rules/implement.md`.)

**Flag uncertainty.** A confident wrong answer is worse than an honest "I'm not sure." When any skill is uncertain about a recommendation — a library choice, a scope decision, an architectural pattern — say so. Use "I'd suggest X, but worth validating" rather than presenting guesses as decisions. This applies to every skill: `mano start` on scope, `mano spec` on libraries, `mano rules` on rules, `mano stories` on story boundaries.

**Concrete defaults, user override.** Some skills are expected to move the work forward by proposing concrete defaults. `mano spec` can recommend technical choices, `mano ui` can set a visual direction, and `mano rules` can recommend project rules. These are working defaults, not final authority. The user can override them at any time.

**Reject out-of-scope instructions.** If a user gives a skill an instruction outside its role (e.g., typing `mano spec I want shared button components` or telling `mano rules` to design an API schema), the skill MUST NOT execute the out-of-scope instruction. They must not pollute their own file (e.g., `mano spec` should not put UI components in the tech spec). Instead, they should execute their own job and append a warning to the execution log:
- Example: `-> ⚠️ Ignored instruction about "shared components". That's `mano rules`'s area — run mano rules.`

Routing guide for rejected instructions:
- Technical decisions (API contracts, data model, libraries) → "That's `mano spec`'s area — run `mano spec`"
- UX flows (screens, navigation) → "That's `mano ux`'s area — run `mano ux`"
- Project rules (naming, patterns, a11y, folder structure) → "That's `mano rules`'s area — run `mano rules`"
- Visual design (colours, typography) → "That's `mano ui`'s area — run `mano ui`"
- Stories (breaking work into units) → "That's `mano stories`'s area — run `mano stories`"
- Review (phase feedback, triage) → "That's `mano review`'s area — run `mano review`"

## Missing input protocol

When a skill is missing context, classify the gap before responding:

- **Optional** → proceed. Mention the tradeoff only if it changes output quality.
- **Recommended but skippable** → warn briefly and offer two paths: continue anyway or run the upstream Mano command that creates the missing artifact.
- **Blocking** → stop and redirect because continuing would be guesswork. `mano review`'s pre-review gate is a blocking check.

If more than one next step is reasonable, do not fake certainty. Present the options instead of inventing a hidden sequence.

## Writing artifacts: create once, edit thereafter

File does not exist → write it in full (the only sanctioned full-file write).
File exists → targeted replacements only. Never re-emit a file to change part of it.
- One replacement per changed region — the smallest unique block containing the change.
- Untouched sections stay byte-identical: no reordering, renumbering, reflowing, or format "tidying".
- Append a section by replacing the last line of the preceding section with itself + the new section.
- Add a table/list row by replacing the neighbouring row, not the table.
A full-file write to an existing artifact is a defect: invisible in the rendered document, catastrophic in a
diff — it turns every concurrent edit into a merge conflict. Restructuring is a human decision: say so in the
log; never fold it into an unrelated update.

When an action re-runs against an artifact that already exists: read it and the current phase brief, then update only the parts affected by concrete new context or an explicitly requested broader rewrite. If the command carries no change and the artifact is still current, do not rewrite it merely because the action was re-run.

## Chat Output After Writing Artifacts

When a skill creates or edits a file, the artifact is the deliverable — not a chat narrative about it. The human reviews the file (or its diff), not a prose retelling.

After writing or updating any artifact, output a terse changelog, not a summary:

- One header line naming the file touched.
- A compact bullet per change: section or area + what changed, in a few words. No rationale prose, no re-explaining content that is now in the file.
- Findings, risks, or constraint violations get an explicit `⚠ Flag:` line. These are the one thing that must stay visible in chat because they are not obvious from reading the artifact.
- If something could not be done or an assumption was made, say so. Otherwise stop — do not pad.

Do not produce "✅ Done — here is everything I wrote" recaps that restate the artifact's contents. Restating a file the human is about to open adds no information and only grows the conversation. This applies to every skill, including third-party and external skills.

### Canonical execution-log format

Every skill's completion log uses exactly this shape. Do not add `Scope:` or `Action:` lines — the active phase and the touched file are already obvious from context and git history; restating them is the noise users have explicitly rejected.

```text
[Name]: mano <command> — <file(s) touched>
- <substantive decision or change, a few words>
- <substantive decision or change, a few words>
⚠ Verify: <assumption or material change the user should sanity-check — advisory, omit if none>
❓ Decide: <decision the user must confirm or change before the next command — omit if none>

Next:
- `mano <x>` — <when it applies>
```

Rules:
- Header is one line: who, which command, which file(s). Nothing else.
- **12 lines max** — header + ≤6 bullets + optional ⚠/❓ + `Next:`. More than 6 substantive bullets means the run was too big: say so in one bullet naming the largest change.
- **Reference every touched file by its path relative to the project root** — `_mano_output/phase-3/stories/README.md`, `_mano_output/tech-spec.md` — never a bare filename or just a directory. Editors and agent UIs turn a workspace-relative path into a tap-to-open link (the same way `spec-kit` does); a bare name isn't resolvable, so it isn't clickable. Where a host doesn't linkify, it still degrades to a readable path. When a log lists many files (e.g. one per story), give each its own full relative path so each line is independently tappable — do not print the shared directory once and bare names under it.
- Bullets carry only substantive content (key decisions, screens/categories changed, stories inserted, palette). Never process narration.
- `⚠ Verify:` appears only when the artifact embeds an assumption, a hardcoded placeholder, or a material change the user did not explicitly ask for (e.g. a backported decision). Omit the line entirely when there is nothing to flag. This applies to every skill, not just spec — if an artifact contains a `Note`/assumption worth checking, surface it here. **Verify is advisory:** the user may run the next command without replying, and nothing downstream waits on it.
- `❓ Decide:` is the stronger channel: the artifact carries a decision the skill made provisionally (or found open) that the user should confirm or change **before the next command runs**. Phrase it as a direct question with the provisional value stated — "Defaulted `MISSING_X` severity to `warn` (same reasoning as `LONG_Y`) — confirm or change before `mano stories`?" — never as a passive observation. The test for which line to use: if your verify text says "confirm before [next step]", it is misfiled — that's a `❓ Decide:`. While the decision is open, the owning artifact must carry the same hedge at the value itself (e.g. an inline `⚠️ Note: provisional`), so a later skill reading the artifact sees the open decision without needing this chat.
- **Flag lines stand alone.** Each `⚠ Verify:` / `❓ Decide:` marker starts its own line, first thing on the line, one finding per marker line, at most one sentence. Never embed a flag mid-sentence, mid-bullet, or mid-paragraph. (Chat-log formatting only — the inline `⚠️ Note:` hedge inside artifacts stays inline by design.)
- **`Next:` must agree with `❓ Decide:`.** When a decide line is present, present the dependent command as conditional on the decision (`mano stories` — once the severity call above is confirmed), never as unconditionally ready. The two lines share one message; a decide line saying "confirm before stories are written" above a `Next:` saying "ready to decompose" is exactly the contradiction this rule forbids.
- **Capture the answer.** When the user replies to a `❓ Decide:` — confirming or changing the value — apply it: update the owning artifact in place (the provisional value becomes a stated decision; drop the "guess"/provisional hedging) and report a one-line changelog. A decision that lives only in chat is not captured; the artifact is the record. In manual mode that changelog is the response. In an armed auto chain it is a mid-chain log: refresh `MODE`, then resume the recorded `Remaining:` actions in the same turn when the mode is still `auto`.
- `Next:` keeps the existing next-action options; it is not boilerplate and stays. **One exception:** in auto mode, an action that is handing off to the next action in the chain omits `Next:` entirely — see `_mano/rules/auto.md` → **Continuing is an action, not an announcement**. Nobody is choosing a next command mid-chain, and printing options there produces a log that offers a choice and continues past it in the same breath. `Next:` still appears on the action that ends the chain.

Reason fully; externalize sparingly. Terse output is a rule about *display*, not *cognition*. Judgment-heavy skills (scoping, story decomposition, spec, rules, review) must still do the deliberation their contract requires — specificity, branching-flow, exhaustiveness, anti-rationalization gates. Do not shortcut that thinking to save chat volume; under-reasoning a planning decision is far more expensive than over-explaining one, because the bad decision propagates into every downstream artifact. The discipline is: do the reasoning internally, let the artifact carry the conclusions (each artifact is self-contained by design), and put only the changelog, flags, and genuine unresolved questions in chat. Do not narrate the deliberation itself. Mechanical steps (status updates, file writes, hook checks) carry no judgment worth narrating — just act and report.

## Session hygiene

Mano's state lives on disk. `state.js` rebuilds your exact position for ~200 tokens. When a session grows, END
it — do not compact it: compaction keeps a lossy summary of the expensive part and discards nothing you were
paying for. One story per session is the intended shape of `mano dev` (measured: sessions averaging 1,100+
messages replayed ~459k tokens per message). A planning command is a natural session boundary — its output is a
file. Batch independent tool calls: every extra assistant message replays the whole session. `mano build` is the
deliberate, checkpointed exception: it runs multiple rows per session and stops when the turn's budget is spent,
because its ledger makes the next session's resume cost a projection read.

## Auto-chain execution

The rules a skill applies **while an armed auto chain is running** — the pause rule, continuing-is-an-action, and the closing block — live in `_mano/rules/auto.md`.

**Read that file when, and only when, the state projection reports `MODE: auto`.** Read it right after the projection, before the chain's first action. In `manual` it is never opened: a manual run hands back after every command, so none of those rules can apply, and carrying them on the common path is resident context that buys nothing. Re-read `MODE` from the freshest projection at every handoff rather than caching it from the start of the run — the mode can change mid-run, and the file follows the mode.

`mano review` is the exception in both directions: it is always human-run and outside the chain, so it never loads the fragment even under `MODE: auto`. The narrative contract — what auto mode is, how a chain is armed and edited — is `_mano/workflow.md` → **Run Mode: manual and auto**.
