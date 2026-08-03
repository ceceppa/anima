---
name: mano-dev
description: Use to implement the next pending story for the active phase. Thin entry point — the implementation contract lives in AGENTS.md, not here.
---

# mano dev — implement the next pending story

This skill is a **pointer**, not a contract. The implementation contract is `AGENTS.md` → **"Implementing a story"** and **"Implementation Output Discipline"**. Read those and follow them exactly. Do not re-derive or paraphrase them from this file.

`mano dev` is the sanctioned path from a finished `stories/` folder into code. It runs on the implementing agent (the small-context coding model), so this file stays deliberately short.

## What to do

1. Read `AGENTS.md` → "Implementing a story" and follow it step by step.
2. Implement only the selected story's acceptance criteria.
3. Mark the story `done` via `node _mano/scripts/stories.js set-status` (the exact call is `AGENTS.md` step 11) — don't hand-edit the index table.

**Determine the active owner-scoped phase and next story fresh from disk via `node _mano/scripts/state.js --next`, not from the chat** (AGENTS.md step 1 is authoritative). Obey the exact `OWNER`, `PHASE_ID`, and `FILE`; never construct `phase-N` from the numeric phase. No configured owner preserves legacy `phase-N` behavior. Trusting loaded chat context here can select a stale phase or another teammate's work.

## Hard stops (from AGENTS.md — repeated here only so they are never skipped)

- **No implementable story → stop — but only when *every* row is `done`.** The `Status` column is the only signal; a story's number, letter, or title grants no exemption, and lettered stories (`4a`) are their own pending work. The full selection rule lives in `AGENTS.md` → "The `Status` column is the only signal" — it is authoritative; do not paraphrase around it. When every row is `done`, output one line — the phase's stories are all done but the phase is **not closed** until `mano review` runs. Do not call the phase "complete", do not present `mano start` as an equal option, and do not start, scope, or plan a new phase. If a requested story number does not exist while another row is pending, report the missing number and the actual next pending story; do not claim the phase is built.
- **Respect order.** If an earlier story is still `pending`, stop and tell the user which story would be skipped. Do not bypass without explicit confirmation.
- **AC only.** Implement the story's acceptance criteria — nothing beyond them. On a genuine gap, stop and name the Mano flow that owns the decision; do not invent behaviour.
- **`Not this story` is a hard no.** Every item in the story's out-of-scope section is a prohibition equal to a `Do not:` line — implement none of it. The full rule (including the named-type trap) lives in `AGENTS.md` → "`Not this story` is a hard boundary" — it is authoritative. If an excluded item seems required for the AC to work, that's a gap — stop and surface it.
- **One-line done (default mode).** After implementing, the entire chat response is `Story [N] done — status updated in stories/README.md`. No recap, no checklist, no AC restatement. The only permitted additions are a real deviation or a project-relevant decision worth preserving (offered for capture) — per `AGENTS.md` step 12 and "Implementation Output Discipline". Nothing else.

<!-- mano-rule: id=dev-yolo-batch; incident=explicit-yolo-stopped-after-one-story; model=codex; date=2026-08-03; eval=dev-yolo-batch,dev-yolo-blocker,dev-default-single -->
## Explicit YOLO exception

When the invocation is exactly `mano dev yolo` or `mano-dev yolo`, follow `AGENTS.md` → "Execution modes" and its YOLO override to step 12. Process the stories that were pending at invocation sequentially in index order, checkpoint each story with `stories.js set-status`, and return only the exact final aggregate line—with story numbers joined by comma plus space, and without a phase-built, review, recap, or other suffix. This changes how many stories the turn executes and replaces the default-only stop/output shape above; every scope, quality, ordering, and blocker boundary still applies. Without the literal `yolo` modifier, stop after one story as usual.
<!-- /mano-rule: dev-yolo-batch -->

If this file and `AGENTS.md` ever disagree, `AGENTS.md` wins — fix this pointer.
