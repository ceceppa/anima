# Backlog Ownership Boundary

`mano start` and `mano review` own backlog content and long-lived project continuity. They add items with `backlog.js add`, and rewrite an existing item's title or context with `backlog.js update --title "..." [--new-title "..."] [--context "..."]` — which never touches `Status`, because status changes belong to `assign` / `resolve` / `resolve-gap` / `reject`, except for the explicitly sanctioned follow-up review operation: after human confirmation, `mano review` may hand-edit only the exact existing open items the human reported fixed to `resolved`. This title-scoped exception never closes a phase, rejects an item, or changes unrelated statuses.

An item's `Status` says where it stands: `backlog` (open), `in-phase-N` / `in-owner-phase-N` (scoped into a phase), `in-task` (`mano task` started it — code may already be edited — and hasn't finished), `needs-human` (built by `mano task`, waiting on a check only the human can do — its `- **Check:**` line says what to try), `resolved` (shipped or fixed), `rejected` (no longer wanted — its premise was invalidated). `resolved` and `rejected` are both closed states and neither is scopeable, but they are not interchangeable: recording a rejection as `resolved` claims work was done that never was. `mano review` sets `rejected` on human-confirmed items via `backlog.js reject --title "..."`. `mano import` may also use that writer when a document merge invalidates an existing `Status: backlog` item and the human has authorized rejecting the item or replacing its product direction (see `mano import` Step 1b). Import may append new items and merge context into existing `backlog` items, but never changes scoped or closed items. A merge request alone does not authorize rejection.

Apart from import’s document-merge boundary above, other skills should not edit the backlog except for narrow gap-resolution status updates:
- `mano spec` must run `node _mano/scripts/state.js --spec`; its current-phase item plus spec-gap projection is its only backlog read. After updating the technical specification, it may mark only a fully addressed projected spec-gap item resolved via `backlog.js resolve-gap --type spec-gap --title "..."`.
- `mano rules` must run `node _mano/scripts/state.js --gaps rule-gap`; that projection is its only backlog read. After updating project rules, it may mark only a fully addressed projected item resolved via `backlog.js resolve-gap --type rule-gap --title "..."`.
- `mano ux` and `mano ui` must run `node _mano/scripts/state.js --gaps ux-gap` / `--gaps ui-gap`; that projection is their only backlog read. After updating `ux-flow.md` / `design-brief.md`, each may mark only a fully addressed projected item resolved via `backlog.js resolve-gap --type ux-gap|ui-gap --title "..."`.
- `mano task` works one non-gap item at a time and only when no phase is open. It may add the item it is about to implement (`backlog.js add`), write the human's clarifying answers into that item's context (`backlog.js update`), and move that item between `backlog`, `in-task`, `needs-human`, and `resolved` only through `backlog.js task-status`, which refuses every other move. It never touches another item.

## Artifact gaps versus implementation work

Classify by what completes the item, not by whether it concerns UI or UX. A `ui-gap` or `ux-gap` is complete when the owning planning artifact is corrected or a genuinely missing decision is settled. A requested product change that still needs implementation is `refinement`, `feature`, or `bug` and remains eligible for phase scope. Updating a brief or flow does not implement that change. This classifies backlog items; it never stops `mano ux` or `mano ui` from writing a feature's contract the human asks for. Writing it just doesn't complete the work item.

- “Make the floating browser panel anchor to the viewport's right edge, outside the app's max-width container” → `refinement` (or `bug` if this violates the agreed contract). Preserve the requested behavior in its context; the implementation phase runs the required UI/UX planning.
- “The panel was already corrected to anchor to the viewport, but the design brief still specifies the app container” → `ui-gap` to reconcile the artifact with the accepted correction.
- “The current design contract contradicts itself about panel anchoring, and no decision exists” → `ui-gap` to settle the contract.

Do not turn an explicit desired behavior into an “Open decision” merely because its implementation is deferred or its future phase has not updated the artifacts yet. Create both a work item and a gap only when there is also an independent defect in the current artifact; cross-reference them, and resolving the gap never resolves the implementation item. Project-wide directives with no owning work item still follow intake B1, but a requested change to an existing product is work, even when it affects many screens.

For a legacy gap that actually requests unimplemented work, review proposes a scopeable replacement carrying the original request and provenance, plus rejection of the misclassified gap with a reference to that replacement. Use the existing human-confirmed addition/rejection flow; never mark the gap resolved to imply the product change shipped. Reuse an existing work item when one already owns the request. Start continues to honor STOP until that correction is recorded.

**An open gap is not a note — it is a stop.** While any gap item of any type is unresolved, `state.js` returns `DECISION: STOP` for a new phase and no scope is proposed. That is deliberate: a gap is an artifact decision that a review or a rework already proved missing, and scoping the next phase on top of one is how a spec, rule set, UX flow, or design brief stays wrong for phases at a time. The cost of clearing it is one command per route, named in the projection's `OPEN_GAPS:` line.

No gap-owning skill opens `backlog.md`, even when the user asks it to handle backlog gaps; the read-only projection and targeted writer are the complete interface. Skills should not inspect the backlog for general project memory unless their role explicitly owns that context.

## The backlog roster, and not adding the same work twice

Reading the backlog to *choose scope* stays banned — that is what `SCOPE INPUT` is for. Reading it to answer **"does this project already track this?"** is a different question, it has its own channel, and skipping it is how the same work enters the backlog twice under two names:

```
node _mano/scripts/state.js --titles                 # every item: title, type, status
node _mano/scripts/state.js --titles --match "text"  # just the ones whose title matches
```

The roster carries titles, types and statuses and no context — on a real 381-item backlog, 20 KB against the file's 165 KB. Outside import’s explicit document-reconciliation read, it is the **only** sanctioned way to see items that are already scoped or shipped; `SCOPE INPUT` shows `Status: backlog` items alone, so an item that went `in-phase-N` or `resolved` is invisible to a skill that never runs this. Run it before adding items to an established backlog, and whenever the human asks what the backlog holds. It never feeds scope selection.

**When the human names a piece of work, find it before you write it.** A person saying "add motion interruption example coverage to the phase" is almost always naming an item that already exists — they read it in the backlog. Match their words to a roster title (`--match` on a distinctive word) and use **that** item: assign it, scope it, quote its real title back. Re-expressing their request as a new item you worded yourself is the failure this rule exists to stop — it leaves the item they meant untouched while a near-twin of it enters the phase, and both then look correct in isolation.

- ❌ Human: "add motion interruption example coverage" → `backlog.js add --title "Motion interruption example scenarios"` — their item still sits there, now shadowed by a second one.
- ✅ Human: "add motion interruption example coverage" → roster shows `Motion interruption example coverage` → `backlog.js assign --title "Motion interruption example coverage"`.

`backlog.js add` does the mechanical half, and it is **advisory only**. It already skips an exact title match; it now also reports any item whose title merely resembles an existing one — including items already scoped or resolved, which no projection shows you. Every item is still written, the exit code does not change, and nothing pauses.

That report is not yours to swallow. Carry it to the human as one `⚠ Verify:` line naming the pair, so a real duplicate can be merged or dropped by the person who owns the backlog:

`⚠ Verify: "[new item]" resembles "[existing item]" ([its status]) — merge or drop one if they are the same work.`

One line covering all of them, never one per item, and never a `❓ Decide` — it does not block the next command (`_mano/rules/core.md` → **Canonical execution-log format**). If several fired, name them on that one line.

The check deliberately over-fires: no title metric separates a real duplicate from a real sibling, so "Sequential group playback mode" beside "Parallel group playback mode" trips it too. That is why it never blocks — most of what it catches needs no action. Do not let it slow you down, and do not suppress it with `--no-similar-warning` to keep the output clean; that flag is for `mano import`, where a single authored document legitimately yields sibling titles.

When the answer is "the same work", **fold rather than abandon**. The item you were about to add often carries detail the existing one lacks — a sharper phrasing, a reason, a source. Merge that into the item that already covers the work instead of dropping it on the floor:

```
node _mano/scripts/backlog.js update --title "[the existing item]" --context "[merged context]"
```

None of this replaces looking first. The roster above is what actually prevents a duplicate; the report is the backstop for the one that gets past you, and `update` is how you clean it up without a second item or a hand-edit.

## Mid-phase additions

One more narrow exception, for work the human pulls into a phase that is already open and being built:

- `mano stories` may assign an **exact backlog item the user named** to the **already-approved active** phase, via `backlog.js assign --phase [N] --title "..."`, and then write its story. It never chooses items itself, never scopes, and never assigns to a phase that does not already exist and hold approved scope.

This is not a second scoping skill. `mano start` owns assignment because assignment is normally part of *selecting* what a phase contains — a judgement needing approval. When the human names one exact item to add to a phase already in flight, that judgement has been made and stated directly; only the mechanical step remains. `mano start`'s `DECISION: STOP` blocks *advancing to a new phase*, which is a different operation and stays blocked.

Two hard limits:

- **If the addition changes the phase goal, it is not an addition — it is the next phase.** Say so and stop; do not assign, do not write the story. Small phases are what make the review gate meaningful, and quietly growing one to fit new work is how that gate stops meaning anything.
- **Never edit the phase brief to record the change.** The brief belongs to `mano start`. Flag it instead: the phase now contains work its brief does not describe, and `mano review` reads that brief for the phase goal and Assumption Log. Surface it with `⚠ Verify:` so the human can add a line themselves if they want it recorded — use and flag, never edit another skill's artifact.
