---
name: mano-build
description: Use to build the active phase straight from its brief, tracked in a progress.md ledger — no story files. Accepts an optional mid-phase correction, `mano build "[what changed]"`, only when a valid ledger already exists. Read this file and _mano/rules/implement.md fully before writing any code.
requires: [implement]
---

# `mano build` — build the phase from its brief

This file plus `_mano/rules/implement.md` are the **complete contract** for `mano build`. Read both completely before writing any code, including when the user asks in plain words ("now build the phase"). Together they are self-contained: no other `_mano/` file is required, and `_mano/workflow.md` is never opened mid-skill.

**The unit of work is the `## Phase Scope` leaf the human already approved** — a lettered leaf of a numbered category in a two-level brief, the numbered item itself in a flat one, and never a unit this skill invents. That single property is what the rest of this file protects. A row that is a copy of the brief cannot drift from it, so build needs no story format, no filename law, no acceptance-criteria authoring, and no quality rules for text it never writes. What it does need, unchanged and in full, are the gates that decide whether the brief is ready to build at all.

`mano build` is one of two paths and replaces neither. `mano stories` + `mano dev` stay first-class: they split planning (big model) from implementation (small model) and suit a large phase. `mano build` runs one phase in one contract on one model, checkpointed by a ledger. One phase uses one path — a phase holding both `stories/README.md` and `progress.md` is refused by the state projection.

**Read order — keep the prefix stable.** Read this contract and `_mano/rules/implement.md` first (they are identical on every run, so they cache as a stable prompt prefix), then the state projection, then the phase brief, then the artifact sections a row needs, then source.

**An argument is a correction, never new scope.** `mano build "[what changed]"` is accepted **only when a valid ledger exists** — the ledger is the thing the text corrects, and this design still rests on the ledger itself being derivable from the brief alone. The invocation is only a channel; the classification, the write rules, and the stops are the same ones a correction typed mid-run goes through (**Mid-phase corrections**). The exact wording is the human's contract: pass it through verbatim, never paraphrase it into scope-ese, and never treat it as licence to widen a row.

- **A pending `R…` rework event wins over the argument.** Durable state outranks a new sentence. When the projection reports `REWORK: [n] pending`, a plain `mano build` resumes the first event as normal, and `mano build "[new text]"` **refuses without mutation** — no row, no code, no queue, no ledger change of any kind. Name the pending event, show its exact text, and ask the human to resolve or dismiss it first. An approval or a rejection of a pending event is a response *inside that event's deviation flow*; it is never reinterpreted as a new correction argument, and never stored as scope for later.
- **With no pending rework, the argument enters the A/B/C classifier** below, before any normal row resumes. **(A)** a defect in work an existing row or `E` leaf already promised → guarded reopen **before any code**, deviation stop, then fix; **no row is appended**. **(B)** a distinct outcome the phase does not contain → refuse; no row, no code, and offer the explicit backlog-defer choice. Auto mode does not soften this. **(C)** an in-goal nuance no row covers → allocate a `+N` row from the *exact* text, link an existing `E` leaf or obtain approval for a new one, persist scope, criterion, and link in one write, re-run the gap gates against the new row, fire the deviation stop, and wait — code only after the human approves.
- **With no ledger, the argument is rejected without running pre-flight and without `init`.** Nothing exists to correct, so nothing is created to hold it. Say that a plain `mano build` builds the approved brief as written, and that changing that brief goes through `mano start "[the change]"` and a fresh scope approval — not an implicit correction row. Write no ledger, no source, and no backlog item. An approval that armed an auto chain covered the brief as approved; it is not consumed, spent, or reused by this refusal, and the chain resumes only when the human answers.

## Flow

**0. Find what to build by running the state script — do not `ls` for the phase or infer it from the conversation.** Run `node _mano/scripts/state.js --next`. It reports `MODE`, the selected `OWNER`, exact `PHASE_ID`, numeric `PHASE`, `PHASE_DIR`, `BRIEF`, `PROGRESS`, `PROGRESS_STATUS`, `ARTIFACTS`, both ledger tables, the `ROW` to work now with its exact `ROW_CONTRACT`, and `REWORK` when review findings are open. If `MODE` or any routing field is absent, stop and report the malformed projection. Obey its `OWNER`/`PHASE_ID`/paths; never construct `phase-N` from the number. **If the script cannot run, stop and report the exact failure** — do not scan for the phase by hand. If it reports no phase or no brief, follow the line it prints and stop.

Branch on `PROGRESS_STATUS`, and on nothing else:

- **`invalid`** → hard stop. The ledger exists and does not validate. Relay the projection's reasons and its one repair instruction — delete `PHASE_DIR/progress.md` and re-run `mano build` — and stop. Do not hand-repair it, do not `init` over it, and do not treat the phase as unstarted. There is no migration path and none is needed: the format has only ever had one version.
- **`missing`** → go to step 1.
- **`present`** → go to step 2.

**1. No ledger yet → run pre-flight once, against the whole brief, and write nothing until it passes.** This is the cheapest place in the whole phase to catch a gap: nothing has been written and nothing has been built. Run **Step 0 pre-flight** below, in its stated order. A hard gate, an unresolved artifact gap, an unmapped project-rule obligation, or an unproven `Phase Goal` outcome **stops the run and writes no ledger** — route it to the owning skill and stop.

Only once pre-flight is clean: re-run `state.js --next`, confirm `OWNER` and `PHASE_ID` still match what pre-flight ran against, and create the ledger with one command. It takes no content:

```
node _mano/scripts/progress.js init --phase [N] --expect-phase-id [PHASE_ID]
```

`[N]` is the numeric `PHASE` and `[PHASE_ID]` the exact `PHASE_ID`, both from that same fresh projection. The script reads the brief and emits both tables itself — a Scope row per `## Phase Scope` **leaf** (`S1a`, `S1b`, `S2a` for a two-level brief; `S1`, `S2` for a flat one), an Exit Criteria row per `## Exit Criteria` leaf — and fingerprints the brief's addressed sections so a later edit to them fails closed. **You never pass rows in and never hand-write the ledger.** If `init` refuses because a section has no list to parse, that is the brief's shape, not something to work around: report it and route to `mano start`.

Then read the emitted tables back and confirm they are the brief you just ran pre-flight against: one Scope row per scope leaf, one Exit row per exit leaf, the brief's own numbering and lettering, and the label of each joining its category to its leaf. A mismatch means the brief changed underneath you — stop and report it rather than building against a ledger you did not verify.

**2. Implement in row order, one pass at a time.** Take the `ROW` and `ROW_CONTRACT` from the projection. `ROW_CONTRACT` is the row's exact text — the brief's own item or leaf for a normal row, the human's or your own recorded text for a correction or a split — so there is no second read of the brief to make.

A **pass** is what one turn implements. By default it is that one row. When the next rows are contiguous leaves of the same brief category and share one real implementation surface, a pass may cover several of them — the derivation and its six conditions are **Grouping rows into one pass** below. Grouping changes only how many rows a turn covers; every step here stays **per row**:

  a. **Run the gates first, before touching any status or any code.** Apply gates **6.2**, **6.3**, **6.4** and the **read budget** from `_mano/rules/implement.md` against **each row's** contract in the pass. A gate that fires stops the run *here*, with the ledger untouched — a row flipped to `doing` for work that then gets refused is a false record of what happened. In a group, the gate fires against one row and ends the pass **before** that row; the earlier rows are still an honest pass.
  b. Only once the gates pass, flip the pass to `doing` in one call: `node _mano/scripts/progress.js set-status --phase [N] --expect-phase-id [PHASE_ID] --row [id] --status doing` — repeating `--row [id] --status doing` for each row in the pass.
  c. Derive what the pass needs from the artifacts *in this turn*; never write an implementation reference to disk. It is expensive, single-use, and wrong to persist. Implement, then verify through `node _mano/scripts/verify.js -- <command>`, then apply gate **10.1** — **separately to every row in the pass and every `E` leaf you are about to mark**. Verification may be shared; evidence may not.
  d. Flip the rows you proved to `done` and mark `met` every Exit Criterion this turn produced evidence for, in one call:
     `node _mano/scripts/progress.js set-status --phase [N] --expect-phase-id [PHASE_ID] --row [id] --status done --row [Eid] --status met`
     No stored row → criterion mapping exists and none is needed: mark leaves as the evidence appears, and step 4's terminal sweep re-checks all of them regardless of which row got there. A row or leaf you cannot yet prove stays open — that is the gate doing its job, and the next run resumes at the first unresolved leaf.
  e. Re-run `state.js --next` **once for the pass** and confirm `OWNER` and `PHASE_ID` are unchanged and the rows you wrote now read `done`. Stop without claiming progress if any postcondition fails.

A row whose split parts exist is a **roll-up**: its status is derived from its parts and the script refuses to write it directly. Work the parts; the parent closes with the last one.

**2r. Open review findings come first.** When the projection reports `REWORK: [n] pending`, the ledger routes here even if every row was already complete. Process the **first pending event**, in order, before any other row — see **Review findings (rework)**.

**3. Stop when this turn's output budget is spent.** Report from the ledger (see **Chat output**) and stop. **Resume in a fresh session**, not by continuing this one: a fresh session restarts residency and reads back the exact position for a few hundred tokens, while continuing carries every message you already paid for. A resumed run starts at flow step 0 and picks up the row the projection names; it does not re-derive completed rows.

**4. Terminal — every Scope leaf `done` and every Exit leaf `met` or `needs-human`.** Do not report the phase built on the strength of the statuses alone: run the **Terminal evidence sweep** first, then output one aggregate line and stop. The phase is **built, not closed**: `mano review` is mandatory and unchanged. Do not scope, plan, or start another phase.

## The ledger

`PHASE_DIR/progress.md` is the phase's durable state: the decomposition and the status, nothing else. It survives compaction, session end, and interruption, which is why it is a file and not something you hold in the conversation. `state.js --next` routes from it, `mano review` gates on it, and a fresh session resumes from it.

- **The address is the contract; the label is decoration.** The projection's `ROW_CONTRACT` carries the row's exact text and is what you implement against. Never work from the table cell — it is a short handle for scanning, and for a correction or a split it is derived, not authoritative.
- **One address space, and each mark means one thing.** `S2` is `## Phase Scope` item 2; `S2a` is a nested leaf of item 2. **`+` is a human correction** (`S2a+1`), **`.` is a split you authored** (`S2a.1`, `S2a+1.1`), and letters are the brief's own nesting and nothing else. You never choose a correction number — `add-row` allocates it, which is why a correction of a correction cannot be written at all. `E2b` addresses category 2, leaf b of `## Exit Criteria`; an Exit leaf is never split.
- **Never hand-write or hand-edit the ledger.** Every change goes through `progress.js` (`init`, `set-status`, `split`, `add-row`, `request-rework`, `resolve-rework`, `sign-off`). A hand-written approximation of a script-owned format is exactly the drift the script exists to make impossible. If the script fails, stop and report the exact error.
- **Every mutation carries `--expect-phase-id [PHASE_ID]`**, the exact value from the projection you are acting on. The owner can change between the projection and the write; the guard refuses and writes nothing rather than mutating another owner's same-numbered phase.
- **Text arguments travel as files, never inline.** `--text-file`, `--part-file`, `--reason-file`, `--exit-text-file`. Quotes, backticks, `$()`, and newlines do not survive a shell round-trip, and a row's exact text is its contract. Write the text to a scratch file and pass the path.
- **Three status vocabularies, deliberately distinct.** Scope rows: `pending | doing | done`. Exit Criteria: `pending | met | needs-human`. Rework events: `pending | resolved | dismissed`. **Built is not proven** — the script rejects `met` on an `S` row and `done` on an `E` row.
- **The addressed brief is frozen once the ledger exists.** `init` fingerprints `## Phase Goal`, `## Phase Scope`, `## Not This Phase`, and `## Exit Criteria`. Every later command re-checks that fingerprint and refuses when it moved, because every row address points into those sections. That refusal is not a problem to work around — see **Mid-phase corrections**, case (E).
- **Row text is immutable; row status is correctable.** No row's text is ever rewritten. A status may move backwards when a defect surfaces, and that always requires an explicit `--reopen` and always fires the **deviation stop**.
- **Build never edits the phase brief**, or any other artifact it does not own — not to fix a typo, not to record what it built, not when the user says the brief is wrong. Reading an input artifact is how build works; writing to one is out of lane. `progress.md` is the one file build owns, plus the source it is implementing.

## Step 0 — pre-flight

Run these once, against the whole brief, **before any ledger and before any code**, in this order. Resolve each before moving on. A mid-phase correction re-runs 0c.0–0d and 0g against the new row (see **Mid-phase corrections**).

The order is the point. Every one of these can only stop the run cheaply while nothing has been written; once a ledger exists, the same finding costs a reopen, and once code exists it costs a rewrite.

1. **0b** — read the brief and every artifact the projection reports present.
2. **0a, 0c–0e** — the hard gates and the artifact-gap check.
3. **0g** — map every applicable project-rule obligation to a Scope leaf.
4. **0f** — prove the `Phase Goal` → Scope → Exit chain.
5. Any gap or contradiction: **stop, with no ledger written.**
6. Re-check identity, then `init --expect-phase-id`.
7. Verify the emitted rows are the brief you ran pre-flight against.

**0⊘. Ledger-and-source gate (hard stop).** The only files this skill writes are source code, the exact projected `PHASE_DIR/progress.md` (through `progress.js` only), and files a row's own work requires. If you are about to Edit, Write, or shell-modify **another Mano artifact** — the phase brief, tech spec, UX flow, design brief, project rules, backlog, or another owner's phase — **stop immediately**. That belongs to the skill that owns it. This applies even when the user just told you an input artifact is wrong: flag it and route it, do not edit it.

**0a. Overloaded screens.** If a UX flow screen handles more than two primary actions (excluding back/close/cancel/continue unless they perform mutation or branching), flag it before building. If `mano ux` has already split a flow into separate screens or steps, evaluate each step on its own. Create and edit for the same entity using the same underlying screen are not separate primary actions.

```
⚠️ [Screen name] handles [N] primary actions: [list them].
Options:
1. Run `mano ux` to split the screen.
2. Build it as one screen anyway.
```

Wait for the user's choice. On option 1, stop after the handoff message.

**0b. Read the brief and every present artifact.** Read the exact projected `BRIEF`, then **every artifact the projection's `ARTIFACTS` line reports as `present`** — tech spec, UX flow, design brief, project rules. Read all of them, not the ones that look relevant. Relevance is exactly the judgement that hides a newly added rule, a spec section written since the last phase, or a design contract nobody mentioned; the inventory is deterministic and the judgement is not. An artifact reported `absent` is not read and not guessed at — its absence is what 0d and 0g are for.

Then report what you read:

```
[mano build]: Read this run: [phase brief, tech spec, UX flow, design brief, project rules].
```

**0c. Readiness.** For each Phase Scope item involving mechanics, workflows, APIs, or stateful behaviour, verify: what data or entity does it operate on? what starts the behaviour? what state changes? what condition proves it worked? what default fixture, seed data, or example input is needed? If an item depends on missing domain structure, that is a gap — route it to `mano spec`; do not build around it with an invented model.

**0c.0 Spec-owned defaults and initial state — hard gate.** `_mano/rules/implement.md` → **Before writing code — the gap gates** gate 6.2, applied here against the **whole brief** instead of one unit: every Exit Criterion and Phase Scope item that depends on a behaviour-driving default needs that default owned and valued in the canonical tech spec.

If that owner or value is missing, **write no ledger**. Report `⚠️ Build readiness gap: spec-owned default missing`, name the affected exit path and field that needs defining, and route to `mano spec`. Do not offer a build-owned default, a `TODO` in the code, or options to continue with a temporary value. Build may implement an already-decided default; it never chooses one.

**0c.1 Player choice interaction — hard gate.** Gate 6.3 from the same shared contract, applied against the whole brief: wherever the phase lets a player choose among two or more simultaneously available alternatives, `_mano_output/ux-flow.md` must define that choice as a player path — availability, how it is invoked, how the active option is selected and shown, and the locked/unavailable/cancel case. In-world or minimal presentation is still UX.

If that flow is absent or leaves any of those decisions to implementation, **write no ledger**. Report `⚠️ Build readiness gap: player choice interaction missing`, name the affected phase path and missing UX behaviour, and route to `mano ux`. Do not propose a hotkey, picker, cycling scheme, default active item, HUD treatment, or other build-owned interaction. The general artifact-gap options do not waive this gate; only a completed UX flow or an explicit human decision to skip `mano ux` can do so.

**0c.2 Public-interface readiness — hard gate.** For every Phase Scope item that creates, changes, wraps, or depends on a public/package API, command, event protocol, plugin hook, external integration, persisted/wire format, or cross-component contract consumed by independently-owned components or multiple scope items, verify its canonical owning artifact defines:

- the exact consumer-visible operation, method, command, or event names;
- input order/shape, required vs optional values, and behavior-driving defaults;
- result/return or emitted payload plus validation/failure behavior;
- ownership/lifetime and evaluation timing for relative/lazy/dynamic values when they change consumer use;
- semantic-to-canonical mappings for convenience layers, adapters, aliases, serializers, or protocol translations.

For a fluent, builder, pipeline, query, or composed API, also trace every in-scope chain transition from the canonical spec: the exact returned type, the target/owner/context it retains, and which terminal operations remain callable. An Exit Criterion such as `builder.move(...).play()` does not prove `builder.move(...).with(...).play()` or `builder.keyframes(...).play()` unless the spec closes those return-type paths too. Words such as “any”, “all”, “entirely fluent”, and “combined” require coverage of every named category, not one representative leaf.

Apply this only to that consumer-visible or independently-owned boundary, not a private helper, internal service, or component API that one scope item and one implementer can safely design locally. “Supports position, movement, opacity, and generic properties” is not a callable contract: method names, argument shapes, and property mappings are still missing. “See tech-spec §API” is also insufficient when that section contains only the same family list. Verify every artifact section you are about to rely on: the exact operation and promised path must actually be present there.

If any behavior-driving interface field needed by a scope item is absent or has two materially different readings, **write no ledger**. Report one `⚠️ Build readiness gap` naming every missing field and route to `mano spec`. The general gap-check options to continue with a temporary note or partial guidance do not waive this gate; an implementer cannot safely invent a shared/public contract row by row.

**0c.3 Phase-promise polarity — hard gate.** Map every `Phase Goal` outcome and every `Exit Criteria` leaf to the Phase Scope item that will satisfy it and the supporting artifact decisions it needs. Read those decisions for meaning, not keyword presence. If any artifact states the opposite outcome or preserves a stale deferral (`recoverable` vs `stays locked`, `available` vs `unavailable`, `implemented` vs `not wired`, success vs required failure), **write no ledger**. Report one `⚠️ Build readiness gap: supporting artifact contradicts phase promise`, quote both statements, and route to the artifact's owning skill—normally `mano spec` for technical/data/gate contradictions.

**0d. Artifact gap check.** For each Phase Scope item, check whether it depends on a visual, interaction, accessibility, technical, data, API, constant, shared measurement, or rule detail that is not defined by the artifacts read this run. This is a warning/decision point, not a default blocker; the hard gates in 0c.0–0c.3 remain non-continuable.

**Player-flow check.** A game mechanic is not exempt from UX because it happens in the world rather than a screen. When the phase includes player activation, direct manipulation, placement/selection, progression/unlock actions, available-versus-locked states, or feedback for an unmet condition, check `_mano_output/ux-flow.md` for the concrete path: what the player notices, does, sees after success, and sees when the action is unavailable. Multiple simultaneously available choices are the hard gate in 0c.1, not a continuable artifact gap. “Minimal” presentation does not let build invent discoverability or feedback behaviour.

Look for partial-but-usable guidance before flagging a gap. A detail is not missing merely because it is brief. If an artifact contains a relevant section, subsection, token, note, rule, constant, or implementation reference, use it.

Flag a gap only when the missing detail would force the implementer to invent behaviour, visual treatment, data shape, API contract, accessibility semantics, or test fixtures that materially affect the story outcome.

When a gap is found, report it before writing the ledger:

```text
⚠️ Build readiness gap: [short gap name]

Affected scope item: [the brief's numbered item]
Missing guidance: [what is not defined]
Available guidance: [artifact references already found, or "none"]
Risk: [why this would cause guesswork or inconsistent implementation]

Options:
1. Pause and run `[relevant mano action]`
2. Continue using the available artifact guidance only
```

Use the relevant Mano action for the gap type:
- Visual treatment, layout, component appearance → `mano ui`
- Screen flow, interaction sequence, user decision path → `mano ux`
- Technical model, API, persistence, state ownership → `mano spec`
- Coding convention, accessibility enforcement, reusable implementation contract → `mano rules`

Do not invent final design, UX, rules, or technical contracts while building. There is no story file on this path to hold a temporary note: if the human sanctions a temporary choice, it lives in the chat log for this run and nowhere else. Never write it into an artifact you do not own, and never treat it as a substitute for the answer this gate is asking for.

**The options require a human answer.** After presenting a material gap, stop. Never choose option 2 yourself because the artifact is optional, the approved auto chain omitted it, the control is familiar/canonical, or enough implementation can be guessed. In an armed auto chain this is a named pause with the remaining chain preserved. Continue without the owning artifact only after the human explicitly chooses that path; an explicit `skip ux` / `skip ui` in the approved chain already counts as that choice.

If sufficient guidance exists, do not warn — read that section when you reach the row that needs it, for example:

`_mano_output/design-brief.md §EmptyState` for the visual spec, and the Colour Constants rule in `_mano_output/project-rules.md` for how to express it in code.

A conflict between an applicable project rule and the phase scope is not a continuable artifact gap. Stop and apply gate 6.4; options 2 and 3 do not waive an existing rule.

**0e. Reachability.** For each Phase Scope item involving interactive behaviour, screens, endpoints, or any user-triggered action, name the surface it lives on, the action that invokes it, and how the user reaches that surface. Wiring that no item covers is a gap, not something to add silently — an unreachable feature passes its own check and ships as nothing the user can use.

**0g. Project-rule coverage.** Before the ledger exists and before writing code:

1. For every rule-level section in `project-rules.md` (normally each `##` rule, not its `What` / `Why` / `Pattern` parts), mark it internally as `not applicable` with a concrete reason, or `applicable` to one or more Scope rows. Decompose every normative obligation in `What` plus any explicit `must`, `required`, or `never` elsewhere: each bullet, required channel, `both`, and joined obligation needs its own mapping. Treat rationale and examples as interpretive context, not separate obligations. A single general pointer does not cover a compound rule.
2. For each applicable obligation, map it to the exact Scope row that must honour it, and to the Exit Criterion that proves it where one exists.
3. **Map an obligation to an Exit leaf only when the rule itself requires an observable outcome or a companion deliverable** — a documentation page a consumer can open, an accessibility level a user experiences, a persisted format a caller reads. Style, naming, folder structure, architecture, and internal mechanisms are how the work is done, not promises the phase made: do not invent a product promise for them. A rule-required *outcome* with a verification surface and no Exit Criterion covering it is a gap — report it and offer to add an `E` leaf (**Mid-phase corrections**, case C) rather than shipping it unproven.
4. If any applicable obligation has no Scope leaf that can honour it, stop with no ledger written and report it — that is a gap in the brief, not something build fills in. If mapping exposes a phase-scope conflict, apply gate 6.4.

Do not write the ledger, and do not write code, until the map has no unmapped applicable obligations. Report the mapping only when it exposed a conflict or caused a row to be added; a clean map needs no narration.

**0f. Prove the chain: `Phase Goal` outcome → Scope leaves → Exit leaves.** The last pre-flight step, and the one that decides whether the brief can be built at all. For **every distinct outcome the `Phase Goal` promises**, name the one or more `## Phase Scope` items that will ship it and the one or more `## Exit Criteria` leaves that will prove it. Then close the loop both ways:

1. Every Exit Criterion has at least one Scope item that could plausibly satisfy it.
2. Every Scope item contributes to at least one Exit Criterion.
3. Every Phase Goal outcome has both.

A break anywhere in that chain is real information — the human's own brief is internally inconsistent — so it **stops the run with no ledger written**. It is never something to reconcile by inference:

```text
[mano build]: The brief doesn't close. Nothing written.

- Goal outcome "[outcome]" — no scope item ships it
- E2c "[criterion]" — no scope item ships the behaviour it tests
- S4 "[item]" — no exit criterion proves it

`mano start` owns the brief, and nothing addresses it yet — `mano start "[the change]"` can revise it. Or tell me which reading is right and I'll build to that.
```

Do not invent a scope item to cover an orphan criterion, and do not quietly widen a row to absorb one. Do not treat a `Not this phase` line as licence to drop a criterion. An unmapped Phase Goal outcome is the most expensive of the three to find later: it is the whole point of the phase going unbuilt while every row reads `done`.

## The human gate: stop on deviation only

Build runs straight through while the ledger is a copy of the human's own list — asking them to confirm their own approved brief carries no information and buys nothing. It **stops and asks** when, and only when, it deviated:

- pre-flight found a hard gate, an unresolved artifact gap, an unmapped project-rule obligation, or a `Phase Goal` outcome the brief does not close (routes out, no ledger);
- gate 6.4 fired — the work conflicts with `Phase goal` / `Phase scope` / `Not this phase`;
- a sub-row split was needed;
- a row was reopened, or a correction row appended;
- a distinct outcome needs a backlog item — the preview and its approval;
- the terminal sweep reopened a leaf, or left one `needs-human`.

Every stop **names which condition fired** and shows the deviating text next to the phase goal. In an armed auto chain this is a named pause with the remaining chain preserved; do not answer on the human's behalf. The two standing gates never move: the human approves the brief at `mano start`, and `mano review` is mandatory at the end.

## Grouping rows into one pass

A **pass** is what one turn implements, and by default it is one row. When several adjacent rows are really one piece of work, a pass may cover them all. That is the entire scope of grouping: it changes **how many rows one turn covers**, never **what was promised**. It composes no scope text, invents no row, and needs no human confirmation — there is nothing for the human to approve that they did not already approve in the brief.

**A group forms only when all six of these hold.** The first one that fails ends the candidate *before* the failing leaf; it never shrinks some other part of the pass or reorders around the failure.

1. **Start at the first actionable non-`done` normal brief leaf** — the row the projection named, never a later one.
2. **Take only contiguous normal brief leaves with the same numeric category.** `S1a`, `S1b`, `S1c` may form a pass; `S1c` followed by `S2a` may not. A leaf already `done` breaks contiguity.
3. **Never include a `+N` correction or a dotted split row.** Each of those is built alone. A correction carries the human's own words and fires a deviation stop; a split exists because one row already overflowed a turn.
4. **Stop before a leaf whose real implementation surface differs from the pass being formed.** Judge the surface you are actually about to edit — the same file, module, command, or screen — not the fact that two labels sound related.
5. **Stop before any per-row gate failure, and before any risk to this turn's output budget.**
6. **The whole candidate can be implemented *and verified* within this turn.** If you are not confident you can prove every leaf in it before the budget runs out, the pass is smaller.

**There is no numeric cap and no cross-category group. The category is a ceiling, never a mandate.** A category of eight leaves does not become one pass because it is one category — condition 6 decides, and when the honest answer is "I am not certain I can verify all eight in this turn", the pass takes fewer. Taking fewer rows is always available and never needs a justification. Taking more than one category is never available, at any size.

A **flat** brief has no categories, so every row is its own pass. Do not group flat rows by inferring which ones belong together: the ceiling has to have come from the human, and in a flat brief they did not draw one.

**Execution order for a pass:**

1. Derive the candidate group.
2. Run gates **6.2**, **6.3**, **6.4** and the read budget **per row**, before any code. A gate that fires on the third row ends the pass at the second, with nothing written.
3. One status batch to `doing`, covering exactly the rows in the pass.
4. Implement once across the shared surface.
5. Verify once where that is honest — but apply gate **10.1 separately to every row and every `E` leaf**. One green suite is not evidence for three rows unless something in it exercises each one.
6. Write the rows you proved, and the `E` leaves you proved, in one call.
7. Leave any failing or unproven row open, and resume at the first unresolved leaf. A partial pass closes what it proved and nothing else — never close a row on the strength of its neighbour.
8. One state and identity post-check for the pass, not one per row.

The close line may name the row range — `S1a–S1c done`. A split, a reopen, or a correction remains a **deviation stop**, and none of the three ever appears inside a group.

## Sub-rows: the one text build composes

When the row being built overflows this turn's output budget, and only then, record the split:

```
node _mano/scripts/progress.js split --phase [N] --expect-phase-id [PHASE_ID] \
  --row S2 --part-file /tmp/part-done.txt --part-file /tmp/part-remaining.txt
```

Each `--part-file` holds one sub-row's exact text: the first is the part already finished, the rest are what remains.

Three constraints, all enforced:

1. **Only for the row currently `doing`, and only after one part is genuinely complete.** The script refuses to split a `pending` row and records the first part as `done`, so build cannot pre-decompose. Pre-splitting the phase into sub-rows up front recreates story files with a worse format and throws away the entire saving.
2. **A strict partition of the parent.** No sub-row may introduce scope the parent does not already contain. Splitting makes the parent a **roll-up**: its status is derived from its parts, the script refuses to write it directly, and it closes automatically with the last part.
3. **It fires the deviation stop.** Sub-row text is the *only* text in the ledger build composes itself: brief rows are parsed, correction rows carry the user's own words. So the human sees every one of them.

`.` is decomposition you authored (`S2.1`), `+` is a human correction (`S2+1`), and letters are the brief's own nesting (`S2a`) — three separate things, never mixed. A correction can be split (`S2a+1.1`); a correction of a correction cannot be written at all.

## Mid-phase corrections

The user reports something the build should account for. It arrives through one of two channels — typed into a running build, or as the invocation argument `mano build "[what changed]"` — and both go through this one classifier, with the same five cases and the same write rules. The channel changes nothing except when the text arrives. **The principle that makes this safe: the unit's text was written by a human.** A user's mid-phase instruction is human-authored text, exactly as trustworthy as a brief bullet. What must never happen is **build composing a row from its own inference**.

Two things decide whether the classifier runs at all, and both are read from the projection before any classification: a **pending `R…` rework event** takes precedence over an invocation argument (refuse without mutation, and resolve or dismiss the event first), and **no ledger** means there is nothing to correct (refuse, and route to `mano start "[the change]"`). Neither is a case below; both are stated in full at the top of this file.

**(A) A defect in work already marked done — no new scope, no new row.** The code does not do what an existing `S` row or `E` leaf already requires. This is most mid-build reports, and it carries zero invention risk because nothing is authored at all. Reopen the affected rows **before writing any code**, in one call:

```
node _mano/scripts/progress.js set-status --phase [N] --expect-phase-id [PHASE_ID] \
  --row S2 --status doing --reopen --row E2c --status pending --reopen
```

The ledger was wrong: the row was never done, and gate 10.1 letting it through is the bug behind the bug. `--reopen` is mandatory and fires the deviation stop. Reopen the **existing normal rows** by their own addresses — never append a correction row for work an existing row already required, and never attach correction-only `affects:` metadata to a normal row. Reopening after the fix, rather than before it, records a sequence that did not happen.

**(B) A distinct outcome the phase does not contain — no row, no code.** Gate 6.4 applies verbatim: stop **before** code. Do not append a row, do not implement, and do not route to `mano start` to amend a brief that a ledger has already frozen. Offer exactly one explicit choice — defer it to the backlog — and see **Deferring a distinct outcome** below. Auto mode does not soften this.

**(C) A nuance inside the phase goal that no row covers — appended as a `+N` correction.** It supports an existing outcome, but no `S` row or `E` leaf states it. Write the user's exact words to a file and append:

```
node _mano/scripts/progress.js add-row --phase [N] --expect-phase-id [PHASE_ID] \
  --parent S2a --text-file /tmp/correction.txt --exit E2c
```

`--parent` is the existing normal row the nuance belongs under; the script allocates the `+N` itself. `--exit` names the Exit Criterion this correction changes — **it is required**, because a correction with no promise attached lets the phase close with the fix built and its evidence never asked for.

Five constraints, all load-bearing:

1. **The text is the user's, verbatim.** Never paraphrase it into scope-ese, never compose it, never tidy it. It travels as a file precisely so quotes, pipes, and newlines survive.
2. **The Exit side is human-authored or human-approved, never both derived from one sentence.** Either link an existing leaf with `--exit E2c` alone, or — when no existing leaf can prove it — show the user the complete proposed criterion wording and get explicit approval, then pass it as `--exit E2c --exit-text-file /tmp/criterion.txt`. Deriving a scope contract *and* the promise that proves it from one sentence is the model marking its own homework.
3. **`S`, `E`, and the link persist in one write.** The script does this; do not split it into two calls, and do not implement between them.
4. **The gap check runs against the new row before any code** — 0c.0–0d and 0g, then 6.2 / 6.3. If the addition needs a spec-owned default no artifact states, route to `mano spec` and **STOP**, exactly as at ledger creation. The row may exist; no code is written.
5. **The deviation stop fires**, showing the appended row and its Exit link against the phase goal, before implementation. Then wait.

**(D) Nothing is built yet and the brief itself is wrong.** With **no ledger** in this phase, the brief is still amendable: tell the user to run `mano start "[what changed]"`, which shows the complete proposed revised scope and writes nothing until they approve it. That approval is the fresh approval of the revised contract. Once a ledger exists this route is closed — that is case (E), not this one.

**(E) An addressed brief section changed after `init`.** `progress.js` refuses with a contract-digest mismatch and writes nothing. This is correct and is not a problem to work around. `## Phase Goal`, `## Phase Scope`, `## Not This Phase`, and `## Exit Criteria` are frozen while a ledger exists, because every row address points into them; a silent re-point would leave rows claiming to address text that moved. Report it plainly:

```text
[mano build]: The phase brief's addressed sections changed after this ledger was created. Nothing was written.

Implicit migration is not supported — the ledger's addresses would no longer mean what they say.
- An in-goal nuance is a correction: tell me and I'll append it as a `+N` row.
- A distinct outcome belongs in the backlog or the next phase.
- If the brief edit is genuinely the right call, this phase's work has to be discarded: delete
  [PHASE_DIR]/progress.md and re-run `mano build` against the amended brief.
```

Do not offer to reconcile, re-fingerprint, or migrate. Do not edit the brief back.

The boundary to watch is (B) misclassified as (C): new scope smuggled in as a nuance. The test is unchanged from gate 6.4 — *a distinct outcome is outside this phase* — and the deviation stop puts the appended text next to the phase goal for the human to see.

### Deferring a distinct outcome

The one narrow exception to the ledger-and-source write gate (0⊘): build may write **exactly one** backlog item, and only through this flow.

1. Offer the choice explicitly. Do not proceed on silence, on "sure", or on an approved auto chain — an auto chain removes typing, not decisions.
2. On an affirmative answer, **show the complete proposed item and stop**:

```text
[mano build]: That's a distinct outcome, so it's not this phase. Defer it to the backlog?

  Title:   [the exact title]
  Type:    [feature | bug | chore | spec-gap | rule-gap]
  Context: [the exact context, in the user's own terms]
  Source:  [PHASE_ID]
  Track:   [the phase brief's track, or "none"]

Approve these fields and I'll write it. Nothing is written yet.
```

3. **"Defer it" is not approval of model-invented metadata.** The title, type, and context are fields `backlog.js add` requires, and you composed them. Wait for explicit approval of *those fields*, and apply any correction the user makes verbatim.
4. On approval, write it with the shell-safe file API, `Status: backlog`, the current `PHASE_ID` as source, and the brief's track. **Never assign it to the current phase or any phase.** Then stop — no row, no code.

Everything else in 0⊘ still holds: this exception is one backlog item, previewed and approved. It is not permission to touch the brief, the spec, the rules, or another owner's phase.

## Review findings (rework)

`mano review` persists each confirmed substantive finding as an ordered `R…` event in the ledger, with its own exact text. They are durable state, not conversation: a compaction, a restart, or an interleaved command loses a conversation, and these have to survive all three.

When the projection reports `REWORK: [n] pending`, that routes here **even when every row was already `done` and every criterion `met`**. Take the **first pending event**, read its exact text from the ledger's `## Row Contracts`, and classify it into A, B, or C above — per event, never in aggregate:

- **A** → guarded reopen of the named rows, then fix. Mark the event resolved in the same write that closes the work:
  `node _mano/scripts/progress.js resolve-rework --phase [N] --expect-phase-id [PHASE_ID] --id R1 --status resolved`
- **B** → the **Deferring a distinct outcome** flow. Mark the event `resolved` only after the backlog item is actually written.
- **C** → the `+N` correction flow, including its Exit link. Mark the event `resolved` after the correction is built and proven.

**Dismissal is the human's word, never an inference.** If the user rejects an A or C deviation, declines B's backlog proposal, or says outright to dismiss and close, record *that exact decision*:

```
node _mano/scripts/progress.js resolve-rework --phase [N] --expect-phase-id [PHASE_ID] \
  --id R2 --status dismissed --reason-file /tmp/why.txt
```

The reason file holds the human's own words. The script refuses a dismissal without one. You may relay a dismissal the user gave you; you may never conclude one because a finding looked minor, out of scope, or already handled.

Once nothing is pending, normal precedence resumes: open rows route to build, a complete ledger routes to review. If a crash lands between a backlog write and its `resolve-rework`, the event stays `pending` and a retry may produce one visible duplicate backlog item — say so, and let the human delete it. That is the accepted cost of not building an idempotency subsystem for a local CLI.

## Terminal evidence sweep

Every Scope leaf reads `done` and every Exit leaf reads `met`. **That is not sufficient to report the phase built.** A criterion marked `met` under row 2 can be regressed by row 6, and the status will still say `met` — statuses record what was believed at the time, not what is true now. Before the terminal line, and only in the session that is about to write it:

1. **Refresh identity.** Re-run `state.js --next`; confirm `OWNER`, `PHASE_ID`, and `PROGRESS_STATUS: present`. A contract-digest failure here means the brief moved: stop, case (E).
2. **Re-run the whole-brief checks against the artifacts as they stand now** — 0g project-rule coverage, 0c.3 artifact polarity, and the 0f `Phase Goal` → Scope → Exit chain. Artifacts may have been extended since pre-flight, and a rule added mid-phase is exactly the one nobody mapped.
3. **Re-run canonical verification on the final code**, through `node _mano/scripts/verify.js -- <command>`. Not the narrow command from the last repair — the project's full check.
4. **Re-evaluate every Exit leaf against final evidence**, in this session. For a manual or experiential criterion, repeat the narrow human-facing check when you can honestly perform it now. Never infer, after a fresh session, that an earlier observation still holds — you did not observe it.
5. **Reopen any leaf that later work invalidated**, with `--reopen`. Then fix or prove it. A sweep that finds a regression has done its job; a sweep that never finds one is not evidence it works.
6. **Refuse terminal success while any correction lacks an affected or new Exit leaf.** *"Fixed but unprovable" cannot close a phase.*
7. **Mark genuinely human-only leaves `needs-human`**, with a reason file: a criterion that is inherently visual, experiential, or otherwise impossible for you to exercise honestly.

```
node _mano/scripts/progress.js set-status --phase [N] --expect-phase-id [PHASE_ID] \
  --row E1b --status needs-human --reason-file /tmp/reason.txt
```

`needs-human` is a **terminal handoff, not an escape hatch**. It is not for a missing test, unavailable tooling, a failed check, or an artifact gap — each of those has its own route, and the script refuses `needs-human` while any Scope leaf is open or any rework event is pending. Do **not** stop mid-run to ask the human to author `Try` text for it: `mano review` sources that from the brief. Write the status and its reason, and keep going.

8. **Write the final statuses, then refresh state one last time** and report from the ledger.

`met` is implementer evidence and `needs-human` is an explicit handoff. Neither is the human's verdict — that is what `mano review` is for.

## Chat output

`_mano/rules/implement.md` → **Implementation Output Discipline** applies in full. Build's own shape:

**Mid-run stop (budget spent):** one line naming what is left, from the ledger — `[mano build]: [PHASE_ID] — S1, S2 done. 4/7 exit criteria met. Next: S3. Start a fresh session to continue.` No recap, no file list, no "AC met" checklist, no narrative.

**Terminal:** one aggregate line, and only after the **Terminal evidence sweep** passes: `[mano build]: [PHASE_ID] built — all scope rows done, all exit criteria met in [PHASE_DIR]/progress.md. Run mano review to close the phase.` When the sweep left any leaf `needs-human`, say so in the same line — `… all scope rows done, 6 exit criteria met, 1 needs human check in [PHASE_DIR]/progress.md.` — without listing them; review shows them.

The terminal line is followed by the **`Validate now:`** block — the brief's own `Try` guidance, copied compactly, once for the phase — exactly as `_mano/rules/implement.md` → **`Validate now:` — the one expansion of the terminal line** defines it. Omit the block when the brief has no `Try` bullets; never invent one, and never derive one from an Exit Criterion.

**Deviation stop:** the named condition, the deviating text, and the question — nothing else. Then stop; do not continue into code while the question is open.

Two suffixes are permitted, and only when one genuinely applies: a short note about a non-acceptance deviation that did not weaken verification, and a project-relevant decision worth preserving, offered for capture in the artifact that owns it. An unmet Exit Criterion is never a permitted suffix — gate 10.1 leaves the row open instead.

When `mano build` is the terminal action of an armed `mano mode auto` chain, the aggregate or deviation line is the build action's log, followed by the required `[mano auto]` closing block from `_mano/rules/implement.md` → **Closing an armed auto chain**. That block is the only permitted content after the line.

## Forbidden

- Do not write, read, or create story files. Stories belong to the other path; a phase holding both ledgers is refused.
- Do not hand-write, hand-edit, or reformat `progress.md`. Every change goes through `progress.js`.
- Do not paraphrase, shorten, or "tidy" a row's text — not at `init` (the parser owns it), not in a correction (the user owns it).
- Do not pre-decompose scope rows into sub-rows before building them.
- Do not accept an invocation argument as new scope, create a ledger to hold one, or accept one at all while a rework event is pending.
- Do not group a correction row, a split row, or leaves from two brief categories into one pass.
- Do not write any backlog item except through the previewed, explicitly approved defer flow — exactly one item, never assigned to a phase.
- Do not infer a rework dismissal. Relay the human's decision or leave the event pending.
- Do not report the phase built on the strength of the statuses alone; the terminal sweep runs first.
- Do not run `mano review`, close the phase, or scope another phase. Built is not closed.
- Do not edit the phase brief or any other input artifact — flag and route instead.
