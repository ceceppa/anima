# Phase Brief — [Project Name] — Phase [N]

<!-- Owner-scoped mode only: add `**Owner:** [slug]` below. Omit it entirely for default phase-N mode. -->
<!-- Active work-track only: add `**Track:** [name]` below. Omit it entirely when no track is selected. -->

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

<!-- One or two sentences explaining why this phase should happen now and what it makes possible. -->

## Vision

<!-- Max 3 sentences. -->

## Design Principle

<!-- One sentence. The decision filter. -->

## Core Product Principles

<!-- Optional. Include only principles from the backlog that matter for this phase. Keep short and human-readable. -->

-
-

## Phase Goal

<!-- One sentence. The single most important outcome. If you have to cut scope, this survives. -->

## Phase Scope

<!-- What ships, in the order it should be built. Exactly two levels: a numbered category, then lettered `a.` / `b.` / `c.` leaves. Each leaf leads with a short bolded title, then an em dash, then one behaviour-level line. -->

<!-- A category is **a coherent outcome area likely to be implemented together — not a promised module, class, or file.** "Task management" names an area of behaviour; it does not order a `TaskManager`. `mano start` cannot know the final architecture and must not pretend to, so never name a category after a type, layer, folder, or file you expect to exist. -->

<!-- The address is stable for the whole phase: `mano build` addresses category 1 leaf b as `S1b`, and the ledger label joins the two bolded leads (`Task management — Persistence`). Neither is decoration. A flat numbered list is still valid and builds row by row (item 2 is `S2`); leave an existing flat brief alone rather than converting it. Keep the whole brief concise: target roughly 250-500 words total. -->

1. **[Category]**
   a. **[Short title]** — [what ships, stated as behaviour]
   b. **[Short title]** — [what ships, stated as behaviour]
2. **[Category]**
   a. **[Short title]** — [what ships, stated as behaviour]

## Not This Phase

<!-- The negative of Phase Scope: capabilities the selected items imply but this phase does NOT ship, slices deferred during scoping, and adjacent work a reader would assume is included. One behaviour-level line each — what is excluded, not how. Keeps the implementer and `mano stories` from widening the phase by inference. Omit only when nothing was deferred or excluded. -->

-
-

## Exit Criteria

<!-- What a real person can do when this phase is done. Exactly two levels: a numbered category, then lettered `a.` / `b.` / `c.` leaves, each one action and its result separated by a colon. Never use arrows. Every leaf is separately addressable (`mano build` addresses them as `E1a`, `E2b`) and separately provable, so a criterion that would need a third level folds that detail into its own leaf text instead. -->

1. **[Category]**
   a. [action]: [result]
2. **[Category]**
   a. [action]: [result]
   b. [action]: [result]

## Validation Plan

<!-- This plan captures learning. Exit Criteria still captures every promised result. -->

<!-- Every question and every assumption carries a stable address — `Q1`, `Q2`, `A1` — in document order. `mano review` refers to them by that address instead of inventing display numbering that changes between sessions. A brief written before addresses existed keeps its wording: the same IDs are derived by document order, never written back. -->

### Questions

- **Q1.** [One concrete question per bullet. Every question needs a matching test below.]

### Try

- [What the human will use, show, play, or measure to answer a question]
- [What result the human will watch for]

## Assumption Log

| ID | Assumption | Risk if wrong |
|---|---|---|
| A1 | | |

## Acknowledged Risks

-
-

## Stated Technical Preferences

<!-- Pass-through appendix, not part of the phase narrative. Include ONLY if the source input explicitly stated a stack, framework, storage, auth, or other technical directive. Transcribe each strictly verbatim — quote the source sentence unchanged, one per line. Do not paraphrase, evaluate, rank, or tidy. `mano start` is a courier here, not an editor. Omit this whole section if the source stated no technical preference — never invent one to fill it. This is the single durable channel for stated tech directives across a context reset; `mano spec` evaluates them and must flag any override. -->

<!-- Verbatim from the source; not scoped or decided by `mano start`. `mano spec` evaluates these and must flag any override. -->

-

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
