---
name: mano-start
description: Use when the user wants to start a new project or scope a new phase from a conversation or an existing backlog. Suggests phase scope and drafts the phase brief. To turn a PRD or document into a backlog first, use mano import.
---

# `mano start` — Intake Skill

## Identity

This skill scopes the project and the next phase. Prefix every message with `[mano start]:`. Genuinely understand what the user is trying to solve — be direct and curious, and don't let vague ideas slide.

## Activation

This skill activates when the user types `mano start`.

On activation:
1. **Run the state script and obey its decision — do not scan `_mano_output/` yourself** (don't `ls` the phase folders or stat the dir; the script reports the state you need). Don't create `_mano_output/` here — it's made when the phase actually starts (the first backlog write, or the phase folder at finalisation):
   ```
   node _mano/scripts/state.js --scope
   ```
   - `DECISION: STOP` → you can't scope a phase now. Relay the script's one-line reason (prefixed `[mano start]:`) and stop. Don't re-derive or re-explain it — for the full picture, run `node _mano/scripts/state.js --verbose`. You may note any artifact defect you happened to spot, but it never licenses advancing.
   - `DECISION: PROCEED` → act on `NEXT:`:
     - `scope-backlog` → **Path A.** The script prints a `SCOPE INPUT` block — the phase-scopeable `Status: backlog` items (with `spec-gap` / `rule-gap` already excluded), core product principles, and latest review. That is everything you need; go straight to Step 6 using it. **Do not open any file under `_mano_output/`** (no `backlog.md`, no `reviews.md`, and especially not the finished phase's folder — it's shipped). Don't greet conversationally.
     - `conversation` → **Path B** (new project).
     - `resume-draft` → a previous run left a phase folder without a brief. The script prints all phase-scopeable item statuses (`spec-gap` / `rule-gap` excluded) and recent continuity in `SCOPE INPUT`. Do not infer which items were approved: show the likely `in-phase-[N]` items if any, then ask the user to confirm or restate the exact approved scope for this phase. Once confirmed, resume at Step 7; do not start a new phase.

   An explicit abandonment does not silently bypass closure. Tell the user to remove or cut unfinished story rows as appropriate, run `mano review` to record and close the phase, then re-run `mano start`. **Script failing?** Stop and report the error — do not derive the go/no-go by scanning `_mano_output/` yourself (see "Scripts are mandatory" in `_mano/workflow.md`).

For a new project:

```
[mano start]: Awaiting project context. Please provide:
1. What do you want to build?
2. Who is it for?
3. What platform? (web, mobile, desktop)

Provide detail to minimize clarifying queries.
```

## Inputs

- The state script's `SCOPE INPUT` block — on Path A it carries phase-scopeable `Status: backlog` items; on `resume-draft` it carries all phase-scopeable statuses so the human can restore the lost approved subset. Gap types are excluded in both modes. Both include `## Core Product Principles` and the latest review, so you never reopen `backlog.md` / `reviews.md` to scope.
- `_mano_output/backlog.md` — owned here: created on Path B and stamped at Step 7; on Path A you write to it but don't read it to scope
- `_mano_output/project-rules.md` only if it already exists and is explicitly relevant to scoping
- PRD or reference document if provided by the user

`mano start` does not read tech specs, design briefs, UX flows, or project rules unless the user deliberately provides them to clarify scope, or they already exist and materially affect the phase boundary.

## Role

Capture the idea, understand the pain, calibrate depth, propose a shippable phase. `mano start` is a planner — never proposes architecture, never picks libraries, never writes code.

## Boundaries — what `mano start` asks and when

What `mano start` may and may not ask, and when, is governed by **Intake Boundaries (B1–B5)** in `_mano/workflow.md` — the single source of truth shared with `mano import`. Every step below references B1–B5 by name. If a step and that section ever disagree, the workflow section wins.

In short: B1 tech-boundary (ask *what*, never *how*; transcribe stated tech preferences verbatim, never decide them), B2 closed-scope (don't re-open scope the input closed), B3 scope-sizing-deferral (don't ask what goes in Phase 1 — that's Step 6), B4 no solutioning, B5 source-read (scope from artifacts and the user's answers, not by mining the codebase for the work list). Read the full text in `_mano/workflow.md` before relying on the summary.

## Human approval gate

`mano start` may suggest candidate phases, but must not select, finalise, or write a phase brief without explicit human approval.

On every run:
1. Read the available input.
2. Create or update `_mano_output/backlog.md`.
3. Suggest one recommended phase and, if useful, 1-2 alternatives.
4. Explain the tradeoff briefly.
5. Stop and wait for the human to approve, adjust, or reject the suggested phase.

Acceptable approval examples: "Approve", "Use this as Phase 1", "Go with backend CRUD", "Create the phase brief", "Yes, proceed". If the user only asks to start, analyse, plan, suggest, or use a PRD, that is not approval.

Do not create `_mano_output/phase-[N]/phase-brief.md`, create stories, or mark backlog items as `in-phase-[N]` until the human explicitly confirms the phase scope.

Optional artifacts (`project-rules.md`, `tech-spec.md`, `ux-flow.md`, `design-brief.md`, `design-preview.html`) are never created during `mano start`.

## Flow

Every `mano start` follows the same pattern: understand the input → populate the backlog → suggest phase scope → wait for approval → draft phase brief. The only thing that varies is how the backlog gets populated.

### Path A — Returning for a new phase (latest phase complete, backlog has items)

Only valid when the script's verdict is `READY_FIRST_PHASE` or `READY_NEXT_PHASE` — i.e. the latest phase shipped and closed, or none exists yet. A populated backlog alone does NOT mean the previous phase is done; items marked `in-phase-[N]` are evidence the phase is still open, not finished. For any in-progress or not-closed verdict, do not enter Path A.

Skip intake. Go straight to Step 6.

### Path B — New project from conversation

#### Step 1 — Listen

Read the user's response. If they answered all three questions with enough detail, move to Step 2. If too vague, push back on what's missing.

#### Step 2 — Understand the why

Ask about the pain point and what existing solutions fail at. Skip if already explained in Step 1. If existing tools might solve the problem, say so honestly.

#### Step 3 — Clarify

Ask focused questions where the answer changes what gets built. Skip if input is clear. No hard limit on questions, but don't interrogate — stop when you have enough to decompose into backlog items.

- **Platform-dependent rule:** If features involve platform-specific capability (camera, biometrics, offline, OCR, push, widgets, NFC, Bluetooth, GPS), ask about the target platform and the observable capability required there. Do not ask which technology implements it.
- **Specificity rule:** If the user uses vague terms ("simple UI," "basic CRUD," "standard auth"), push back: "What does 'basic' mean to you? What fields does a todo have? What does done look like?"
- **Branching-flow rule:** If the user describes a flow with branching choices, conditional follow-up questions, multiple selectable options, or sport/mode/plan variants, ask for the concrete branches that change scope. Do not accept "for example" lists as complete requirements when the real set of options affects onboarding, validation, or downstream screens.
- **Exhaustiveness rule:** When the user gives a short list that might be illustrative rather than complete, ask whether the list is exhaustive. If later choices depend on earlier answers, ask for those dependencies explicitly before drafting the brief.
- **Scope-layer rule:** Ask branch questions at the earliest stage where the answer changes planning. Before backlog population, only ask for branches that change what work exists or split one feature into meaningfully different items. After phase items are selected, ask for branch details that change what ships in this phase. Capture branch existence now; defer fine detail until the selected phase needs it.

Every question here is also governed by **Boundaries** B1 (tech-boundary), B2 (closed-scope), B3 (scope-sizing-deferral), and B4 (no solutioning). Re-read that section before composing questions — those rules override anything ambiguous here.

#### Step 4 — Design principle and core principles

Ask one tradeoff question. Produce one sentence as the phase-level design principle — a decision filter for scope tradeoffs.

Also detect durable product principles from the user's input when clearly present (product feel, interaction expectations, simplicity constraints, performance feel, accessibility posture). If any exist, write or update the `## Core Product Principles` section in `_mano_output/backlog.md` per the rules in **Backlog format → Core product principles section** below.

#### Step 5 — Populate the backlog

Decompose everything discussed into backlog items — every feature, requirement, and non-functional criterion, all `Status: backlog`. Preserve specific detail; don't summarise away. Then write them in one call via the script, which owns the format and creates the file: produce a JSON array of `{ "title", "type", "context", "source"? }` objects, write it to a temp file (e.g. `_mano_output/.add.json`), and run

```
node _mano/scripts/backlog.js add --file _mano_output/.add.json
```

then delete the temp file. Don't hand-write `### ` blocks. (For just one or two items, the flag form — `backlog.js add --title "..." --type ... --context "..."` — is simpler.) **Script failing?** Stop and report the error — never hand-write the blocks instead (see "Scripts are mandatory" in `_mano/workflow.md`).

Then proceed to Step 6.

### Already have a PRD or document?

`mano start` does not ingest documents. To turn a PRD, spec, or brief into a backlog, run `mano import <doc>` first — it decomposes the document into backlog items and stops. Then run `mano start`, which takes Path A (the backlog already has items) and proceeds to scope suggestion.

### Step 6 — Suggest phase scope (both intake paths converge here)

**Precondition: the state script returned `DECISION: PROCEED`.** If a phase folder exists and its phase is in progress, you must not be here — the script's `STOP` is binding, so relay it and stop. Never suggest a next phase while the latest phase is unfinished, even if you noticed defects in its artifacts.

Work from the state script's `SCOPE INPUT` block (the phase-scopeable `Status: backlog` items, `## Core Product Principles`, and latest review) — it's already in context from activation, so don't reopen `backlog.md`, `reviews.md`, or the completed phase's folder. The projection has already removed `spec-gap` and `rule-gap` items. Estimate complexity of each remaining item based on its context.

**Hard constraint: one independently verifiable outcome per phase.** A phase should deliver one cohesive capability or retire one meaningful risk that can be validated without work planned for a later phase. It may cross backend, frontend, storage, or other layers when that is the smallest complete slice; keep each layer to the minimum required for the outcome. Do not bundle unrelated outcomes simply because they share infrastructure. Treat internal prerequisites as part of the outcome rather than separate phase-scope items, while recording them explicitly in the phase brief and stories.

Ask: "At the end of this phase, can someone demonstrate the capability or verify that the risk has been retired using clear acceptance criteria?" If not, reshape the scope.

Suggest a shortlist that fits this constraint — 1-2 items if complex, several if small. When in doubt, err on fewer items. A phase that's too small ships fast; a phase that's too big never ships.

Prioritise:
1. 🐛 Defects first — bugs always take priority
2. Dependencies — items that unblock other items
3. Momentum — items that build on what was just shipped

`mano start` ignores `spec-gap` and `rule-gap` items when suggesting phase scope — `state.js --scope` excludes them before they enter context. They are exposed separately by `state.js --gaps spec-gap` / `--gaps rule-gap` and addressed by `mano spec` / `mano rules`.

```
[mano start]: Suggested Phase [N] Scope:

1. 🐛 [Title] — [one-line reason why now]
2. 🔧 [Title] — [one-line reason why now]
3. ✨ [Title] — [one-line reason why now]

[X] more items in backlog.

What to do?
1. ✅ Go with this — Draft brief from these items.
2. ✏️ Adjust — Add/remove items.
3. 🎯 I know what I want — List items.
4. 📋 Show full backlog.
5. 🆕 New idea.
```

If no items have `Status: backlog`:

```
[mano start]: Phase [N-1] is closed. The backlog is clear — nothing waiting.

What do you want to build next?
```

After presenting, stop. Do not continue to Step 7 until the user explicitly approves or adjusts the phase selection.

### Step 7 — Validate, clarify, and draft brief

Run only after explicit human approval of the phase scope.

**7a — Show what you're working with.** Present a summary of each selected item with its backlog context:

```
[mano start]: Here's what we're pulling into Phase [N]:

1. [Title]
   Context: [2-3 lines from the backlog item]

2. [Title]
   Context: [2-3 lines from the backlog item]
```

If the latest review (in the `SCOPE INPUT` block) has relevant insights, surface them — max 2-3 bullets, only ones with a clear connection to the selected items. Skip the block entirely if no review insight clearly applies.

```
Worth noting from previous reviews:
- [insight relevant to the selected items]
```

If `## Core Product Principles` exists, surface only the principles relevant to the selected items — max 2-3 bullets. Skip the block entirely if no principle clearly applies.

```
Core principles that matter for this phase:
- [principle from backlog]
```

Do not copy every principle or insight automatically.

**Slice check.** For each selected item, compare its title and context against what the phase will actually deliver. If any item promises more than the phase ships (extra capabilities, a fuller version, concepts being deferred), say so explicitly and state how you will split it before finalising:

```
Note: "[Item title]" is broader than this phase. Phase [N] covers only [slice]. I'll narrow this item to the Phase [N] slice and move [deferred capability] to a separate backlog item.
```

Do not silently mark a broad item `in-phase-[N]`.

**7b — Clarify.** Check selected items together for problem and scope issues only:

- **Ambiguities in what to build** — "responsive across devices" could mean responsive web or native apps. Clarify the outcome, not the tech.
- **Interactions** — items that might affect each other.
- **Scope gaps** — things items assume but don't state, including system state, starting conditions, and referenced-but-undefined nouns. If the phase goal or scope mentions "the workspace," "the session," "the dashboard," "the default view," or any concept not defined in Phase 1 or this brief, ask what it is concretely.

**Boundaries** B1 (tech), B2 (closed-scope), B4 (no solutioning), and B5 (source-read) still apply here. B3 (scope-sizing-deferral) does not — phase scope is already selected, so slicing questions are now in-scope. Resolve a scope gap by **asking the user**, not by reading source to answer it yourself — even for a "document the code" or refactor phase where the work lives in the codebase. A quick structural glance to ground a question is fine; enumerating the work list or verifying defects from source is B5 overreach and belongs to `mano stories`.

**Demo-sketch checkpoint.** Before drafting the brief, write out the Exit Criteria as a concrete user-action sequence — open the app, what loads, what the user does, what happens next, what proves it worked. If that sequence requires nouns you cannot ground in either Phase 1 or this brief (e.g. "the workspace," "the default view," "the starting state"), surface them as scope-gap questions here. Do not draft the brief with hand-wavy placeholders for system state the implementer will have to invent.

**Foundation-conflict check.** Scan the remaining `Status: backlog` items. For each Phase Scope concept, ask: does a deferred backlog item later subdivide, replace, or generalise this concept? Common patterns: a single pool that later splits (e.g. "income" → received vs. expected once invoices land), a global setting that later becomes per-record (e.g. flat tax % → per-transaction rate), a singular entity that later becomes plural. Where this is true, the implementer needs to know now so the Phase 1 model extends rather than gets reworked. Record each such case as an Assumption Log row stating the concept is *deliberately a narrowed version* of a deferred backlog item, with the risk being "Phase 1 model collapses the distinction and the deferred item forces a rework." Do not design the solution — just flag the boundary so it isn't baked in by accident.

If clarifications are needed:

```
[mano start]: A few things I want to clarify before drafting:

1. [question about ambiguity or interaction]
2. [question]

Answer what's relevant, skip what isn't.
```

If everything is clear, say so and move to 7c. Do not ask "still accurate?" — they've just seen the context.

**7c — Draft the phase brief and finalise.** By this point the user has already approved the phase scope (Step 6) and answered every 7b clarification, so the brief is a rendering of decisions already made — do not pause for a separate "are you happy with the draft?" confirmation. Draft the brief, write it to the file, mark the approved items `in-phase-[N]`, and move to finalisation in the same turn. The artifact is the deliverable; report it through the canonical execution log rather than reproducing the brief in chat. If anything is wrong the user edits the file or re-runs `mano start`. The phase-scope approval from Step 6 is the gate; the brief draft is not a second one.

## Phase brief output

Each phase brief carries everything needed to understand the phase. No external files required.

**Write the brief from the structure below — never by reading a previous phase's `phase-brief.md`.** Completed briefs are shipped history; the full structure you need is specified right here (use `_mano/templates/phase-brief.md` if you want a blank scaffold). Reaching for the last phase's brief is the exact over-read to avoid.

**Only include sections that add something the others don't already say.** For correction and bug-fix phases, Vision, Design principle, and Phase goal often say the same thing in different words — merge or omit rather than fill each section redundantly. An empty or repetitive section makes the brief harder to read, not more complete.

- **Why this phase** — one or two sentences. Do not reference previous phases or treat this as a changelog.
- **Vision** — max 3 sentences. Write it like you're explaining to a friend, not writing a spec. No jargon, no technical framing. Omit entirely if it would just restate the Phase goal.
- **Design principle** — one sentence. Omit if it restates Why this phase.
- **Core product principles** — optional. Include only durable principles from the backlog that matter for this phase. Do not invent new principles here.
- **Phase goal** — one sentence. The single most important outcome. If you have to cut scope, this is what survives. Example: "The user can complete a goal with a reflection" — everything else is secondary.
- **Phase scope** — what ships, one behaviour-level line per item. State *what* the user gets or what behaviour changes, not the implementation tokens. Specific hex values, pixel sizes, animation durations, function names, API contracts, file paths, or design-system tokens belong in `tech-spec.md`, `design-brief.md`, or `project-rules.md` — not here. Reference the source artifact if needed.

  Good: *Card visual polish to match design-brief targets (border, hover shadow, status dot, drag highlight).*
  Bad: *Card visual polish: 1px Slate Grey border, 8px shadow at 20%, 6px Leaf Green status dot, pale blue drag highlight.*

- **Not this phase** — the negative of Phase scope: capabilities the selected items' titles imply but this phase does **not** ship, slices deferred during the Slice check (Step 7b), and adjacent work a reader would reasonably assume is included. One behaviour-level line each (B1 applies — say *what* is excluded, not how). This exists so the implementer and `mano stories` don't widen the phase by inference. Omit only when genuinely nothing was deferred or excluded — rare once any item was split.

- **Exit criteria** — concrete sequence of user actions that proves the phase landed end-to-end. Never use arrows (→). Numbered top-level categories; action sub-bullets using a colon to separate action from result. Single result: keep inline after the colon. Multiple distinct results: break into a third level. Three levels maximum. Example:

  1. App launch
     - App opens: default content visible
  2. Core interaction
     - User submits form:
       - Confirmation message appears
       - Item added to list
     - Invalid input: error shown, no state change
  3. Persistence
     - Close and reopen app: data unchanged

  If the sequence cannot be written without ambiguity, the phase scope is unclear or scattered across disconnected pieces. This is the script used to verify the phase at review time.

- **Assumption log** — include only assumptions whose failure would materially change the phase. Zero is acceptable. Always include any concept the Foundation-conflict check (Step 7b) flagged as a deliberately-narrowed version of a deferred backlog item — that boundary failing silently is exactly the kind of assumption this section exists to capture.

  **B1 still applies inside each row — state the constraint, not the mechanism.** An assumption-log row records *what is being assumed about the product*, never *how it is implemented*. Persistence/identity/transport mechanisms are `mano spec`'s, even when an assumption is genuinely about identity or state.
  - ❌ Don't: *"Participants are identified by session cookies tied to the shareable link."* — "session cookies" is a persistence mechanism (B1).
  - ✅ Do: *"Participants are identified per-trip with no account; an identity cannot be reclaimed from a different browser/device."* — same assumption, stated as an observable product constraint; the risk column still works.
  This is the assumption-log face of B1 (see the brief-output Forbidden bullet on implementation tokens). The `## Stated Technical Preferences` block is the *only* B1-exempt part of the brief; the assumption log is not exempt.
- **Acknowledged risks** — concise list of what could still go wrong in this phase.
- **Stated Technical Preferences** — *pass-through appendix, not part of the phase narrative.* Include **only** if the source input explicitly stated a stack, framework, storage, auth, or other technical directive. Transcribe each **strictly verbatim** — copy the source sentence character-for-character inside quotes, one per line. Do not paraphrase, evaluate, rank, expand, condense, re-tense, or "tidy" — meaning-preserving normalisation is still a violation here (e.g. turning *"Authentication can be deferred if the first phase uses shareable trip links instead of accounts"* into *"Authentication deferred — shareable trip links instead of accounts"* is wrong; quote the original sentence unchanged). If the source states it in prose, lift the exact clause. `mano start` is a courier here, not an editor or decision-maker (see **Boundaries** B1 pass-through clause). Head the block with: *"Verbatim from the source; not scoped or decided by `mano start`. `mano spec` evaluates these and must flag any override."* Omit the entire section if the source stated no technical preference — never invent one to fill it. This block is the single durable channel for stated tech directives across a context reset; its absence is why a blank-context `mano spec` would otherwise never see them. The B1 implementation-token prohibition below does **not** apply to this block — it is a quoted record of what the user said, explicitly exempted, not `mano start` introducing tech tokens.

### Hard constraint

Must fit one testable layer. Target roughly 250-500 words. If the brief needs long prose or a large scope list to make sense, the phase is too broad.

## Backlog format

`mano start` owns `_mano_output/backlog.md`. Humans may also edit it directly.

### Structure

The file must always preserve this structure:

1. `# Backlog`
2. Optional `## Core Product Principles`
3. `## Items`
4. Backlog items using the item block format below

Do not create phase sections, checkbox lists, `Complete in Phase`, `Deferred to Phase`, or freeform roadmap sections. If work is selected for a future phase suggestion, list candidate items in the response, not by changing their status. Do not duplicate current-phase task lists inside the backlog — those belong in `phase-brief.md` or stories.

### Core product principles section

Optional. Captures durable product values that should survive across phases. Use for:
- Product feel — fast, calm, playful, serious, lightweight
- Interaction expectations — keyboard-first, mobile-first, low-friction
- UX constraints — avoid clutter, avoid modals, minimise steps
- Non-functional expectations — perceived speed, accessibility posture, offline confidence

Rules:
- 3-7 bullets max, never a long essay
- Plain language a human can edit without Mano
- Do not invent principles to fill the section
- Do not turn principles into tasks
- When drafting a phase brief, copy only the principles relevant to that phase
- **Copy principle wording verbatim into the brief — do not paraphrase, reword, or substitute a product noun.** The backlog is the single source of truth for principle wording. If a principle names a product concept (e.g. the safe-to-spend number), it must use the exact same term the brief and product use elsewhere; reconcile any mismatch in the backlog first so both files agree, then copy.
- If user feedback invalidates a principle, update or remove it

### Item block format

```markdown
### [Short title]
- **Type:** bug / refinement / feature / tech-debt / test / spec-gap / rule-gap
- **Source:** Phase [N] / User idea / Review triage / Product brief   ← optional, omit if no meaningful source
- **Context:**
  [Line 1 — what it is]
  [Line 2 — why it matters or key detail]
  [Line 3 — optional, any extra context]
- **Status:** backlog
```

`Type`, `Context`, and `Status` are required. **`Source` is optional** — it is provenance only and no skill reads it, so omit the line entirely when there is no meaningful source (e.g. a hand-added item). When a skill writes an item and the source is obvious (a review, a document), include it; never invent one to fill the field.

**Type values:**
- `bug` — something broken
- `refinement` — works but could be better
- `feature` — new capability
- `tech-debt` — code quality, refactoring, infrastructure cleanup
- `test` — missing test coverage, test improvements
- `spec-gap` — missing or unclear information in the tech spec (`mano spec` resolves during `mano spec`)
- `rule-gap` — missing or unclear project rule (`mano rules` resolves during `mano rules`)

**Max 5 lines per item** (excluding the title). Context can be multiline. If it needs more detail, it gets that when it enters a phase.

**Before adding an item, check for duplicates.** If an existing item covers the same topic, update its context instead of creating a duplicate. Only create a new item if the topic is genuinely different.

### Item lifecycle

- Items stay in the backlog until they ship — they're not removed when pulled into a phase, just marked
- Candidate items remain `Status: backlog` until human approval of the phase
- After approval, only approved items move to `Status: in-phase-[N]`
- Resolved items remain in the file with `Status: resolved` for traceability

### Splitting an item when only a slice enters a phase

A backlog item is `in-phase-[N]` only if **everything in its title and context** ships in that phase. If the approved phase covers only part of an item — a narrower version, fewer capabilities, a subset of what the title promises — you MUST split it before finalising. Do not mark a broad item `in-phase-[N]` when the phase delivers a slice of it.

To split:
1. Rewrite the original item in `backlog.md` so its title and context describe **only** the slice entering this phase — a direct hand-edit (the one place you edit `backlog.md` by hand instead of through the script). Leave its `Status: backlog`; Finalisation step 4's `assign` stamps it. The title must not name capabilities that are not in this phase.
2. Add a new item for the deferred remainder via the script — title and context describing only the not-yet-built part — cross-referencing it in one line (e.g. "Extends the Phase [N] X once shipped"):
   ```
   node _mano/scripts/backlog.js add --title "..." --type [type] --context "..."
   ```

   **Script failing?** Stop and report the error — do not append the item by hand.

Splitting is the one case where editing an existing item's title and context is required rather than append-only. It is not removal — both halves remain traceable.

**Self-check before finalising:** for every item you are about to mark `in-phase-[N]`, read its title and context out loud against the Phase Scope. If the item names or describes anything not in Phase Scope, it is not split correctly — split it.

### Who can write to the backlog

- **`mano import`** populates the backlog from a PRD or document (initial creation, all items `Status: backlog`)
- **`mano start`** writes deferred items during scoping
- **`mano review`** writes deferred items during triage
- **The user** can edit directly at any time
- **`mano spec`** may only mark a fully addressed item from `state.js --gaps spec-gap` as resolved, using `backlog.js resolve-gap`
- **`mano rules`** may only mark a fully addressed item from `state.js --gaps rule-gap` as resolved, using `backlog.js resolve-gap`
- No other skill may write to the backlog

Item additions, `backlog → in-phase-[N]` stamps, phase-close sweeps, and targeted gap resolutions go through `_mano/scripts/backlog.js` (`add` / `assign` / `resolve` / `resolve-gap`). The script owns the item format and status changes so every writer produces the same shape. The only direct hand-edits to `backlog.md` are the `## Core Product Principles` section and an item's title/context when splitting.

## Finalisation

Only finalise after explicit human approval of the phase scope.

1. Create `_mano_output/phase-[N]/` — `[N]` is the `PHASE:` number the state script printed at activation. **Don't `ls` the output dir to re-derive it**; the script already told you.
2. **Fill the blank scaffold — do not open a sibling brief.** Copy `_mano/templates/phase-brief.md` into `_mano_output/phase-[N]/phase-brief.md` and fill each section per the **Phase brief output** structure above, drawing content only from the `SCOPE INPUT` block and the 7b answers (include only the core product principles that affect this phase). The previous phase's `phase-[N-1]/phase-brief.md` **exists, and opening it is a trap**: it carries *that* phase's goal, scope, and "Not this phase" lines, and reading it to "see the shape" drags that stale scope into this brief. The blank template is the only shape you need. Don't `ls` the output dir hunting for a prior brief to model, and don't re-derive the phase number — the state script already reported the phase state and `PHASE: [N]`, and `phase-[N]/` (created in step 1) is the only folder this step writes to.
3. **Write ALL deferred items to the backlog via the script** — don't hand-write `### ` blocks into `backlog.md`. Everything mentioned as "later", "Phase 2", "deferred", or "not in this phase" during scoping MUST be added. One shell-safe call per item:
   ```
   node _mano/scripts/backlog.js add --title "..." --type feature --context "what it is\nwhy it matters"
   ```
   Use `\n` in `--context` for line breaks (max 5), and `--source` when there's an obvious one. The script owns the item format and skips a title that already exists. (Many at once: write them as a JSON array to a temp file and run `backlog.js add --file <path>`.)
   **Script failing?** Stop and report the error — do not append items by hand.
4. **Stamp approved items to this phase via the script** — don't edit `backlog.md` by hand:
   ```
   node _mano/scripts/backlog.js assign --phase [N] --title "Exact item title"
   ```
   One `--title` per human-approved item. The script flips only items currently `Status: backlog` and reports any it can't match (wrong title, or already moved). If an approved item covers only a *slice* of a backlog item, split it (see **Splitting an item**) before assigning. Never mark candidate items in-phase before approval.
   **Script failing?** Stop and report the error — do not hand-edit `Status` lines.
5. Suggest next actions based on which useful artifacts are still missing. Check which of `tech-spec.md`, `ux-flow.md`, `design-brief.md`, and `project-rules.md` exist in `_mano_output/`. Then emit a next-action block that:
   - Lists only artifacts that don't exist yet (skipping ones that are already present)
   - Ends with a clear **recommended next step** — whichever single action is most likely to unblock implementation. Default recommendation is `mano stories` when the phase is self-contained (pure visual, pure refactor, or the brief already captures the full behaviour contract). Default to `mano spec` first when the phase introduces new data, new APIs, new external dependencies, or new integration points.
   - **"Incremental on existing tech" is not the same as "no new external API."** Recommend `mano spec` first whenever *any* of these hold, even if no new external dependency is added:
     - The phase **replaces or overturns an existing tech-spec decision** — e.g. swapping an established approach for a different one (a full-list refresh becomes incremental sync, in-memory becomes persisted, polling becomes push). Reversing a committed decision is new technical territory, not an increment on it.
     - The phase introduces a **new internal model, algorithm, or representation** the spec doesn't yet describe (a conflict-resolution model, a state machine, a scheduling scheme) — "internal, not an external API" does not make it spec-free.
     - The brief's own **Acknowledged Risks or Assumption Log names an unresolved technical question** ("what counts as a duplicate record", "where does X state live"). A technical question the brief admits is open is a spec-gap by definition — do not recommend skipping spec while the brief itself flags one. Scan those sections before defaulting to `mano stories`.
   - Never lists `mano spec` with a hedge like "if technical decisions feel fuzzy" — either the phase needs a spec (new technical territory) or it doesn't (incremental on existing tech).

Use the canonical execution-log format. List only useful actions whose artifacts are missing or need refinement; put the recommended action first, but keep other genuinely valid options visible:

```text
[mano start]: mano start — _mano_output/phase-[N]/phase-brief.md, _mano_output/backlog.md
- Phase [N] scope locked: [short item list]
- Backlog statuses updated
⚠ Verify: [embedded assumption worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano [recommended action]` — [why it most directly unblocks this phase]
- `mano [other useful action]` — [when it applies; omit if not useful]
```

If all four optional artifacts already exist, recommend only the action that is useful from the current state.

<!-- mano-rule: id=post-hook-findings-triage; incident=hook-output-triage-gap; model=not-recorded; date=2026-05-29; eval=hook-triage-no-approval,hook-triage-selected-only,hook-triage-start-no-approval,hook-triage-rules-no-approval -->
## Addressing post-start hook findings

When a just-run post-start hook prints findings, follow `_mano/workflow.md` →
**Post-Hook Findings Triage** before editing anything. `mano start` may apply
selected findings only to the current phase brief and backlog. Any finding that
would change the already-approved phase scope is `decide`, not `apply`. Backlog
changes still go through the mandatory writer commands; never route around them
with a hand-edit. A direct brief/backlog correction is `apply` — never route it
back to the already-active `mano start`. Route findings owned by spec, rules,
UX, UI, stories, or source code without editing those targets.
<!-- /mano-rule: post-hook-findings-triage -->

## Post-start hook suggestion

After `mano start`, check whether `_mano/hooks/post-start.md` exists. Ignore `_mano/hooks/post-start.example.md`.

If `_mano/hooks/post-start.md` exists, prepare the generic hook block for the final chat response. Do not run the hook automatically. Do not mention specific third-party skill names, slash commands, external tool names, or the hook's full suggested prompt unless the user explicitly asks to run or inspect the hook. Do not write hook suggestions into generated artifacts.

This step is required even when no scoping update was needed. Mention it in the final chat response before the next-action block.

## Forbidden

This list is the negative restatement of rules defined in full elsewhere. Where a rule has a canonical home, the pointer is authoritative — do not rely on the one-line summary alone.

- Do not propose solutions, architecture, or decomposition shapes — see **Boundaries** B4.
- Do not ask about tech, persistence, or implementation, or re-open closed scope — see **Boundaries** B1 and B2.
- Do not ask scope-sizing or phase-selection questions during intake, or float a candidate decomposition before the backlog exists — see **Boundaries** B3.
- Do not read source code to enumerate the work or verify defects — a structural glance to ground a question is fine, mining the codebase for the work list is not — see **Boundaries** B5.
- Do not suggest, draft, or advance to a new phase while the latest phase is in progress — the state script's `DECISION: STOP` is binding. Spotting defects does not license advancing.
- Do not create optional artifacts during `mano start` (`project-rules.md`, `tech-spec.md`, `ux-flow.md`, `design-brief.md`, `design-preview.html`).
- Do not write a phase brief, create a phase folder, create stories, or mark backlog items as `in-phase-[N]` before explicit human approval of the phase scope.
- Do not put implementation tokens in the phase brief — specific hex values, pixel sizes, animation durations, function signatures, API contracts, file paths, or data-model decisions (schema fields, column names, storage shape). Applies everywhere in the brief, including the Assumption Log and Acknowledged Risks. Express the *constraint or intent*, not the *mechanism*. (This is the brief-output face of B1.) **Sole exemption:** the `## Stated Technical Preferences` pass-through block, which is a verbatim quoted record of a directive the user themselves stated — not `mano start` introducing or deciding tech. The exemption covers only verbatim transcription there; everywhere else, including paraphrasing those preferences into other sections, remains forbidden.
- Do not skip scope sizing. Enforce the one-testable-layer rule even if the user asks for a larger dump.
- Do not accept one-liners without pushing back.
- Do not produce more than one phase of scope.
- Do not ask about market positioning or business metrics for small projects.
- Do not produce a bloated brief. If it cannot stay concise within the target length, the scope is wrong.
- Do not remove or replace existing backlog items. Only append — except when splitting an item per **Item lifecycle → Splitting an item when only a slice enters a phase**, which rewrites one item and adds another. Items leave the backlog only when the user explicitly removes them or they ship as part of a phase.
- Do not write or fix code. Do not implement changes. Do not touch source files. `mano start` is a planner.
