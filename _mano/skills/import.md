---
name: mano-import
description: Use to turn an existing PRD, spec, or product document into a Mano backlog. Decomposes the document into backlog items, then stops.
---

# `mano import` — Document Intake Skill

## Identity

This skill does one job: read a product document (PRD, brief, spec) and decompose it into `_mano_output/backlog.md`. It does **not** scope phases, draft a phase brief, or suggest what ships first — that is `mano start`'s job. Prefix every message with `[mano import]:`.

When `mano import` finishes, the deliverable is a populated backlog and nothing else. The user then runs `mano start`, which takes Path A (backlog already has items) and proceeds to scope suggestion.

## Activation

This skill activates when the user types `mano import` (optionally with a path: `mano import path/to/prd.md`).

- **With a path** (`mano import prd.md`): read that file as the source document.
- **Without a path** (`mano import`): ask which document to read, or accept the document text if the user pasted it inline with the command. Do not proceed until you have a document.

On activation:
1. Run `node _mano/scripts/state.js` and record `TRACK:`. This is the only active-track source; do not read Git config yourself. A missing track is `TRACK: none`.
2. Create `_mano_output/` if it doesn't exist.
2. Read `_mano_output/backlog.md` if it already exists. If it does and already has items, this is not a fresh import — tell the user the backlog already exists and ask whether to merge new items from this document or stop. Do not silently overwrite or duplicate.

## Boundaries

Every question `mano import` asks is governed by **Intake Boundaries (B1–B5)** in `_mano/workflow.md` — the single source of truth shared with `mano start`. In short: B1 tech-boundary (ask *what*, never *how*; transcribe stated tech preferences verbatim into the backlog item context, never decide them), B2 closed-scope, B3 scope-sizing-deferral (never ask what goes in Phase 1 — phases do not exist yet at import time), B4 no solutioning, B5 source-read (decompose the document, not the codebase — do not read source to enumerate or verify work). Read the full text before relying on the summary.

`mano import` never marks items `in-phase-[N]`, never drafts a brief, and never suggests phase scope. Phases do not exist at import time.

## Flow

### Step 1 — Read and check

Read the entire document. Before decomposing, check for:

- **Ambiguities** — terms that sound specific but aren't defined ("basic metadata," "simple UI," "standard CRUD"). Ask what these mean concretely.
- **Gaps** — things the document assumes but doesn't state. Ask only about *product/scope* gaps (what behaviour, for whom, which boundary). Technical gaps are out of scope per **B1**.
- **Contradictions** — if the document says "simple" but lists 8 success criteria, flag it.
- **Hidden branches** — flows that sound linear but contain choice-dependent steps, variant-specific inputs, or example lists that are not obviously complete.

When asking for a formula or a computed value's definition, phrase the relationship in plain language ("balance plus expected money, minus upcoming costs and tax reserve"), not as a code-style expression with variable names (`available_balance + expected_incoming - ...`). The latter is the shape of a B1 implementation brush even when only illustrative — you want the *product meaning*, not a candidate expression.

**Mandatory: the central-noun definition gate.** The checks above are permissive — they let you ask, they do not force you to. This one is not optional. Identify the single noun (occasionally two) the core experience is built around — the thing the document's "answers one question" / "the core experience is" / headline value sentence names: the *safe-to-spend number*, the *readiness indicator*, the *per-person budget estimate*. For that noun, ask: does the document define it in **observable terms** — a concrete rule, threshold, or relationship a non-developer could verify? If it is centred but only named, never defined, **asking what it concretely means is mandatory, not a candidate you may drop.** This is the single highest-value Step 1 question and the one most often silently skipped.

Bound it so it does not manufacture filler:
- Exactly the central noun(s). Not every undefined term — incidental nouns stay under the permissive checks above.
- Skip if the document already defines it observably (a stated formula, an explicit threshold, an enumerated rule). Do not ask the user to re-confirm a definition the document gives.
- Ask the *meaning*, in plain language, never a candidate code expression (the formula rule above still applies).
- This gate forces *inclusion*; it never overrides B1/B2/B3. If the only honest version of the question is "how is it built" or "what's in Phase 1", it is still barred — but a centred core noun almost always has a legitimate product-definition form, so find that form rather than dropping it.

**Classify every candidate before it becomes a question — the resolution test.** For each ambiguity, gap, or contradiction you found, ask: *what kind of answer resolves this?*

- Resolved by knowing **what the product is** (a definition, an entity distinction, a behaviour, a missing branch) → it is an import question. Ask it, phrased product-first.
- Resolved by knowing **what goes in Phase 1** (which slice ships first, one-off vs. the fuller version, view-only vs. CRUD, narrowed vs. complete) → it is **not** an import question. Do not ask it. Record it as a note in the relevant backlog item's context so `mano start`'s Foundation-conflict check (Step 7b) can resolve it later. This holds **even when the trigger is a genuine contradiction** (e.g. the dashboard lists a capability the document defers): finding the contradiction is correct; *asking the user to resolve it by sizing Phase 1* is the B3 violation. Note it, don't ask it.
- Resolved by knowing **how it's built** (persistence, schema, stack, API shape) → not a question at all (B1). Not even as a sub-option or a parenthetical "(e.g. opening balance vs. emergent)".

A single document point can yield an import question *and* a note for later — split it, ask only the product half now, and never anchor the question with "Since Phase 1…" or "For this phase…". Import is phase-agnostic; Phase 1 does not exist yet.

Present findings:

```
[mano import]: Before I split this document into backlog items, I need these product decisions:

1. [direct question]
   Why it matters: [effect on the backlog; omit when obvious]
2. [direct question]
3. [direct question]

Reply naturally. Say "unsure" when you do not know an answer.
```

**Pre-send filter — run mechanically on the drafted question list, do not rely on judgment alone.** Before sending, take each numbered question and apply these checks literally. Any question that hits a check is deleted from the list (and, if it flagged a real foundation conflict, recorded as a note in the relevant backlog item's context instead — not asked):

1. Does the document already state the answer (including by deferring the capability — "later", "eventually", "early phases can start with…")? → delete. You are asking the user to confirm a boundary the document drew. This catches the **confirmation form** ("Does that mean X is fully out of Phase 1?") regardless of how reasonable it sounds.
2. Is the answer "what goes in Phase 1 / which slice ships first" rather than "what the product is"? → delete, note it for `mano start`.
3. Does the question contain "Phase 1", "this phase", "for this phase", "fully out of", or "only … this phase"? → it is almost certainly phase-sizing in disguise; delete unless it is unambiguously a product-definition question that merely mentions the phase by accident.
4. Does the answer change *how it's built* (storage, schema, stack, API)? → delete (B1), no sub-option or parenthetical either.

A question survives only if its answer is a product definition, an entity distinction, a behaviour, or a missing branch — and the document does not already give it.

**Then the inclusion pass — the filter deletes, this one re-adds.** After deleting, confirm the central-noun definition gate is satisfied: if the document's central noun is centred-but-undefined and no surviving question asks what it concretely means, the list is incomplete — add that question before sending. The filter is suppressive by design; it must not be allowed to strip the one mandatory question. A check-1 deletion never applies to the central noun unless the document genuinely defines it observably.

Wait for the user's response before decomposing. Per **B3**, do not ask phase-selection or scope-sizing questions here — including ones disguised as contradictions or as yes/no confirmations ("the document defers X but the dashboard shows it — only X this phase, or also Y?", "does that mean X is out of Phase 1?"). A document that looks too big, or that defers a capability it also references, is normal and is resolved later by `mano start`, not by interrogating the user now.

### Step 2 — Capture durable product principles

If the document clearly states durable product values (product feel, interaction expectations, simplicity constraints, performance feel, accessibility posture), write them to the `## Core Product Principles` section of `_mano_output/backlog.md` per **Backlog format → Core product principles section** in `mano start`. Keep the wording plain and human-editable. Do not invent principles to fill the section. Do not propose a phase-level design principle — that is `mano start`'s job once a phase is being scoped.

### Step 3 — Populate the backlog

Decompose the entire document into backlog items. Every feature, requirement, non-functional criterion, and success criterion. Preserve specific detail from the source — including any stated technical preference, transcribed verbatim into the relevant item's context per B1 (pass-through, not silence). When `TRACK:` is not `none`, include that exact value as `track` on every imported item; Source remains the document name.

Write all items to `_mano_output/backlog.md` with `Status: backlog` through the deterministic writer. Produce a JSON array of `{ "title", "type", "context", "source", "track"? }` objects, write it to a temporary file such as `_mano_output/.import.json`, then run:

```text
node _mano/scripts/backlog.js add --file _mano_output/.import.json
```

Delete the temporary file after the writer succeeds. The writer owns the item shape, duplicate-title check, and default `Status: backlog`; never hand-write blocks. **Script failing?** Stop and report the error (see "Scripts are mandatory" in `_mano/workflow.md`). For reference, the exact shape the writer produces — no `ID`, no `Title`, no `Description`, no checkboxes, no numbering:

```markdown
### [Short title]
- **Type:** bug / refinement / feature / tech-debt / test / spec-gap / rule-gap
- **Source:** [document name]
- **Track:** [active track, if any]
- **Context:**
  [Line 1 — what it is]
  [Line 2 — why it matters or key detail]
  [Line 3 — optional, any extra context]
- **Status:** backlog
```

`Type` values: `bug` (broken), `refinement` (works but could be better), `feature` (new capability), `tech-debt` (refactoring/infra), `test` (missing coverage), `spec-gap` (unclear tech spec), `rule-gap` (unclear project rule). For a document import, most items are `feature`. `Type`, `Context`, and `Status` are required. `Source` is optional provenance — since every item here comes from the document, set it to the document's name (e.g. `product-brief.md`). Max 5 lines of context per item.

Preserve the required file structure in this order: `# Backlog`, then optional `## Core Product Principles`, then `## Items`, then the item blocks. The writer creates or extends that structure and skips duplicate titles. `mano start` reads these items later; going through the writer is what guarantees the field names it parses.

### Step 4 — Stop and hand off

The backlog is the deliverable. Do not scope a phase, draft a brief, or suggest what ships first. Output the execution log:

```
[mano import]: mano import — _mano_output/backlog.md
- [N] items decomposed from [document name]
- Core Product Principles captured: [yes / none found]
⚠ Verify: [any assumption or unresolved ambiguity worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano start` — scope the first phase from this backlog
```

## Post-import hook suggestion

After `mano import` completes, check whether `_mano/hooks/post-import.md` exists. Ignore `_mano/hooks/post-import.example.md`.

If an active `post-import.md` hook exists, check its `## Mode`. A `command` hook runs automatically in both modes. Import is before phase approval, so a `suggest` hook asks with the generic `Run it now?` block even when `MODE: auto`; only an armed auto chain runs suggest hooks automatically. See `_mano/workflow.md` → **Optional Post-Skill Hooks** and **Run Mode**. Do not mention specific third-party skill names or the hook's suggested prompt unless the user explicitly asks to run or inspect it. Do not write hook suggestions into generated artifacts.

## Forbidden

This list is the negative restatement of rules defined in full elsewhere. Where a rule has a canonical home, the pointer is authoritative.

- Do not scope a phase, suggest what ships first, or float a candidate decomposition — that is `mano start`'s job, and it is also forbidden by **B3** and **B4**.
- Do not draft a phase brief, create a phase folder, or mark items `in-phase-[N]`. `mano import` only produces a backlog with all items `Status: backlog`.
- Do not ask about tech, persistence, or implementation, or re-open closed scope — see **Intake Boundaries B1 and B2** in `_mano/workflow.md`.
- Do not ask scope-sizing or phase-selection questions, including ones disguised as contradictions or yes/no confirmations — see **B3**.
- Do not decide, evaluate, or act on a stated technical preference — transcribe it verbatim into the item context and leave the decision to `mano spec` (see **B1**, pass-through).
- Do not create optional project-rule, technical, UX, or UI design artifacts.
- Do not remove or replace existing backlog items. Only append, or merge with explicit user confirmation when a backlog already exists.
- Do not write or fix code. `mano import` is a planner.
