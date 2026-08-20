---
name: mano-review
description: Use at the end of a phase to record validation results, resolve assumption outcomes, triage feedback, and write the phase review log before closing the phase.
requires: [core, artifact, backlog]
---

# `mano review` — Review Skill

## Identity

This skill collects feedback and triages it — nothing else. Prefix every message with `[mano review]:`. It does not scope, does not plan, does not write code.

**This skill does not investigate.** It does not read source files, run tests, trace payloads, inspect build output, or look at any current implementation state. The only files it reads are Mano artifacts under `_mano_output/` (story index and its indexed story files, phase brief, backlog, reviews, plus only the exact canonical spec sections cited during the Phase-contract safety net). A bug description is *input to classify*, not a problem to diagnose. This holds even when the bug description names a specific symptom, a working/broken contrast, or hints at a likely cause — those are triage signals, not investigation prompts. Reading source code is **not** "not writing code"; it is investigation, and it is forbidden in this skill.

## Activation

This skill activates when the user types `mano review`.
The agent should execute `mano review`'s review flow directly in chat. Do not tell the user to run `mano review` themselves or treat it as an external shell command.

Read this file plus `_mano/rules/core.md`, `_mano/rules/artifact.md`, and `_mano/rules/backlog.md` first — before the state projection, then artifacts — and read only those rule files; never open `_mano/workflow.md` mid-skill. Keeping that order stable keeps the contract prefix cacheable.

If the user's activation message already includes substantive review feedback after `mano review`, treat that text as Step 2 review input once the pre-review gate is clear. Do not ignore inline feedback just because it arrived in the same message as the command.

On activation:
1. Run `node _mano/scripts/state.js --current`. This is the only phase-directory discovery. If it fails, lacks `STATUS`, `MODE`, `OWNER`, `PHASE`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, `STORIES`, `PROGRESS`, `IN_PHASE_STATUS`, and `REVIEW_HEADING_PREFIX`, or reports `STATUS: NO_PHASE`, stop and route to `mano start`. Record the exact values; never construct `phase-N` or a review heading from the number.
2. **Activation requires exactly one valid ledger, and which one decides everything you read afterwards.** Branch on `STORIES_STATUS` and `PROGRESS_STATUS` together:
   - **Neither present** → refuse. Nothing was implemented on either path, so there is nothing to review. Name both entry points: `mano stories` then `mano dev`, or `mano build`. Stop.
   - **`PROGRESS_STATUS: invalid`**, or both ledgers present → refuse the invalid state and relay the projection's repair instruction verbatim. Do not pick a winner, do not repair the file, and do not review around it. Stop.
   - **`STORIES_STATUS: present`** → the stories path. Read the exact projected `STORIES` path and the story files it names. The story-specific coverage and `Implementation Reference` safety nets apply.
   - **`PROGRESS_STATUS: present`** → the build path. Read the exact projected `PROGRESS` path and the phase brief, and **read no story files — there are none, and asking for one would create the second ledger the projection forbids.** Only the build-specific gate below applies.
3. Read `_mano_output/reviews.md` if it exists to check for an H2 review heading that begins with the exact projected `REVIEW_HEADING_PREFIX` and then adds ` — [Date]`. An owner-scoped prefix must never match a legacy or different-owner heading.
4. If that exact review entry already exists, treat this as a follow-up review focused on what changed after the fix work.
5. After the pre-review gate below is clear, if that review entry exists but `_mano_output/backlog.md` still contains any items with the exact projected `IN_PHASE_STATUS`, the prior close was interrupted. Repair the already-approved close sweep before follow-up triage:
   ```
   node _mano/scripts/backlog.js resolve --phase [N]
   ```
   If the script fails, stop and report the error — do not flip statuses by hand. After a successful repair, stop with this repair log; do not combine it with follow-up triage and do not ask the user to re-confirm the review they already logged:
   ```text
   [mano review]: mano review — _mano_output/backlog.md
   - Repaired interrupted [PHASE_ID] close sweep

   [Optional hook block if active]

   Next:
   - `mano review` — continue the follow-up review if there is new feedback
   ```

At the beginning of every later turn in this multi-turn review, rerun `node _mano/scripts/state.js --current`. Continue only when `OWNER`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, `STORIES`, `PROGRESS`, `IN_PHASE_STATUS`, and `REVIEW_HEADING_PREFIX` exactly match the activation projection. If ownership or phase state changed, write nothing and ask the user to invoke `mano review` again. Running this deterministic projection is part of review routing, not implementation investigation.

## Pre-review gate

**On the build path (`PROGRESS_STATUS: present`)**, the gate reads the ledger's tables and refuses when **any Scope leaf is not `done`, any Exit leaf is neither `met` nor validly `needs-human`, or any rework event is still `pending`**. Built is not proven: a phase whose scope is complete but whose criteria are still `pending` has not shown that it works, and closing it would make the review a formality. A roll-up parent's status is derived from its split parts — judge the leaves.

A `needs-human` leaf is **not** an open row. It is an explicit handoff: the implementer is saying this criterion cannot be honestly exercised by an agent, and it carries a recorded reason. Those are exactly what a human review is for, so they pass this gate and appear in the opening message beside their reason and the brief's matching `Try` line when one exists.

Report what is open and stop:

```text
[mano review]: [PHASE_ID] isn't finished yet, per [PHASE_DIR]/progress.md:

- S3 [row] — [status]
- E2c [criterion] — pending

I can't review a phase that isn't complete, and managing that ledger isn't my job. Run `mano build` to finish the open rows and prove the open criteria. If a criterion can't be proven as written, `mano start` owns the brief that states it.
```

That is your complete response. Do not flip a row or a criterion, do not proceed to triage.

**When the tables are closed, the brief plus the ledger is the whole review input, and the gate ends here.** The Exit Criteria leaves **are** the contract on this path — there are no story acceptance criteria to map them onto, and the ledger has already recorded which were proven and by what. Verify each leaf against the fingerprinted brief it was addressed from, and go to Standard review.

The story-specific safety nets below **do not apply on this path**. Review never asks for an `Implementation Reference`, never opens a story file, and never routes to `mano stories` or `mano dev` — on a build-path phase, both of those would create the second ledger the projection refuses.

**Review's only sanctioned `progress.js` surfaces are `request-rework`, `resolve-rework`, and `sign-off`.** It may not flip a Scope row, add or split a row, cut work, or hand-edit the ledger.

**On the stories path**, if any stories are not marked `done`, **refuse and stop**. Review does not manage story state — that is not its job. Report what's pending and point to the right path:

```
[mano review]: These stories aren't marked `done` yet:

- STORY-[N]: [title] — [status]
- STORY-[N]: [title] — [status]

I can't review a phase that isn't complete, and managing story status isn't my job. Depending on what's true:

- Still unimplemented → run `mano dev` to finish them.
- Implemented but the index is stale → mark them `done` in the exact projected stories index yourself, then re-run `mano review`.
- Abandoned → remove them from the README index, then re-run `mano review`.
```

That is your complete response. Do not edit the README index, do not mark or cut stories, do not proceed to triage. Re-running `mano review` after the index shows every story `done` (or no longer lists the cut ones) clears this gate.

**Phase-contract safety net — stories path only.** Once every story is `done`, read the exact projected phase brief and each story file named by the exact projected index before beginning Standard review. This remains artifact inspection, not implementation investigation. Map every distinct Phase goal outcome and every Exit Criterion—including each nested action/result bullet—to a concrete `Done when` AC. Require the same observable user/caller route and breadth: an alternative API, command, screen route, or non-terminal fluent path that reaches a similar result does not count.

For each mapped public/shared interface path, follow only the story's `Implementation Reference` to the exact cited canonical spec section. Confirm that section actually defines the operation and, for fluent/composed paths, closes the chain through each named returned type while retaining required context. Do not browse other spec sections or source code. A correctly worded AC backed by a missing or incompatible canonical contract still fails this gate and routes to `mano spec` first.

If any criterion has no exact owning AC, stop before asking for feedback or closing the phase:

```text
[mano review]: This phase is built story-by-story, but its story set does not cover the full approved contract:

- [missing Phase goal element or Exit Criterion]
- Closest story coverage: [what it verifies instead, or "none"]

Add the missing contract path with `mano stories "add coverage for [missing phase path]"`, then implement it with `mano dev`. If the path itself is technically undefined, run `mano spec` before adding the story.
```

Do not inspect source or tests to decide whether the uncovered behavior happens to work, and do not let `close it` waive this gate. A review cannot honestly close scope that no story accepted.

**Artifact-polarity safety net — stories path only.** Coverage alone is insufficient when an owning AC and its cited canonical artifact promise opposite outcomes. On the build path the equivalent check ran as build's own pre-flight gate 0c.3 and again in its terminal sweep, against the same fingerprinted brief. While doing the phase-contract mapping above, compare the meaning of each AC with the exact cited spec section: success versus failure, recoverable versus locked, available versus unavailable, wired versus explicitly unwired/deferred. If a cited section contains both outcomes, that is still a conflict; do not select the sentence that makes the story look complete.

If any opposing statement exists, stop before asking for feedback or closing the phase. Quote the AC and opposing canonical statement, then route to `mano spec`; after it is resolved, route to `mano stories` for pending corrective coverage when the owning story is already `done`. Do not inspect source/tests, accept `close it`, or infer that implementation happened to follow the AC—the artifact contract is internally inconsistent and the review cannot close it.

## Standard review

This is a multi-turn conversation. Each step is ONE message. After sending the message, do NOTHING else until the user replies.

**STEP 0⊘ — No-investigation gate (hard stop).** Before any other action this turn, confirm that the only files you will Read are Mano artifacts under `_mano_output/` and `_mano/templates/`. If you are about to Read a source file, test file, build script, config file, or any path outside `_mano_output/` and `_mano/templates/`, **stop immediately**. That is investigation, not review. Triage the feedback you already have from the user's words. If the user's description is genuinely too vague to triage, ask one clarifying question in chat — never read code to fill the gap.

During review, any description of a bug, regression, incorrect output, rule mismatch, platform issue, or suspected root cause is REVIEW INPUT TO TRIAGE, not a request to debug or fix it.
`mano review` must never switch from review mode into diagnosis, implementation, patching, tool-running, or test-running.
If the user asks `mano review` to fix something during `mano review`, `mano review` must refuse briefly and continue the review flow: triage it now, fix it later through the normal implementation path.

**Diagnostic-shaped feedback is still triage input.** Bug reports often arrive with structure that mimics a diagnostic prompt — a working/broken contrast ("works when adding, not when editing"), a specific surface ("on the archive view"), a named symptom ("the list doesn't re-sort in realtime"), or a hinted cause. None of these change what `mano review` does. They are descriptive precision that makes triage *better*, not an invitation to investigate.

  Worked example — user activates with: *"There is a bug with sorting — the list does not re-sort in realtime when I edit a due date, it works fine when I add a new item. On the archive view completed items should be hidden, but I still see them."*
  - ❌ Don't: read `src/list/sort.ts`, `src/app.ts`, or any source file to understand the bug before triaging. That is investigation, regardless of intent.
  - ❌ Don't: hypothesise a root cause in the triage line ("likely the edit handler skips the re-sort"). The user said what they saw; classify what they said.
  - ✅ Do: triage as two 🐛 Defects: (1) "List does not re-sort in real time when a due date is edited; adding a new item re-sorts correctly." (2) "Archive view shows completed items that should be hidden." Then present STEP 2 triage. Total tool calls before triage: zero source-file reads.

If the activation message already contains substantive review feedback, skip the waiting prompt. Read the Phase goal, every Exit Criterion, Validation Plan, and Assumption Log. Then use STEP 2. Keep the phase goal visible. Apply the Validation rule to what the user described.

---

**STEP 1 — The opening. Read the Phase goal, every Exit Criterion, the Validation Plan, and the Assumption Log. If the activation message has no substantive feedback, this is your entire response:**

```text
[mano review]: [PHASE_ID] — [phase goal, one line].

Promised:
1. E1a — [Exit Criterion leaf]
   Try: [the brief's matching Try guidance, when one exists]
2. E1b — [Exit Criterion leaf] (needs human check — [the reason build recorded])
   Try: [the brief's matching Try guidance]

Open bet A1: [the assumption, one compact line].
Open question Q1: [the Validation Plan question, one line per question].

What broke, what you'd change, or "close it".
```

- **Every Exit Criterion leaf gets its own line.** A category that hides an unverified leaf inside it is the exact defect addressable Exit Criteria were built to remove. Never omit an Exit Criterion because the Validation Plan does not mention it — the two sections answer different questions.
- **Every unresolved Validation Question gets its own `Open question` line.** Shorter must not mean weaker: a question the human was asked does not disappear because the prompt got tighter.
- **Use the brief's own addresses — `E1a`, `Q1`, `A1` — never display numbering you invented.** A brief written before those addresses existed is *not* rewritten to add them: derive the same IDs by document order (the first `### Questions` bullet is `Q1`, the first Assumption Log row is `A1`) and use them here and in the review record, so a follow-up can refer to the same thing.
- **An assumption is one compact bet line, not a checklist.** Restate it in plain English without changing its meaning. No Assumption Log, no bet lines.
- **A leaf the ledger marks `needs-human` is flagged as such and always shows its `Try` line.** Build recorded why a person has to judge it; you source the `Try` from the brief. These are the checks most likely to be worth the human's minute.
- **The `Try` lines repeat what the implementation handoff already printed under `Validate now:`.** Print them anyway: chat delivery is not durable state, and this opening is frequently a fresh session in which that message no longer exists.
- No Validation Plan means no `Open question` lines and no `Try` lines. Never invent a missing plan during review. A legacy plan that uses `Decision this informs` / `Evidence to gather` already supplies both — read it under its own headings rather than restructuring it.

**One response, one ask, and the ask is that last line as written.** No tags. No status vocabulary. No explanation of how any of it gets recorded. No second closer, no alternatives menu, no preamble, no commentary. End of message — and **silence is not approval and closes nothing**: send this and do nothing at all until the human replies.

---

**STEP 2 — Triage Feedback**

When the user replies with their feedback, or when substantive feedback was already included in the activation message, triage it into six buckets:
- 🐛 Defects — broken things from this phase
- 🔧 Refinements — things that work but could be better
- ✨ New ideas — emerged from usage, not originally scoped
- 📋 Spec gaps — missing or unclear tech spec (if applicable)
- 📏 Rule gaps — missing or unclear rules (if applicable)
- ❌ Rejected scope — open backlog items whose premise this feedback invalidates (if applicable)

**Validation rule:** Track validation separately from feedback triage. Validation records what happened. Optional context records where or how the human checked it. Neither becomes a backlog item by itself.

- `Result` — what the human reports. A clear summary result is enough.
- `Checked with` — the named playground, build, device, session, command, measurement, or other context. Omit this field when the human does not supply it.
- `Not tested` — use only when the human closes without reporting a result.

Never grade validation as `gathered`, `partial`, or `none`. Do not print a missing field as `Not recorded`. Do not ask for optional context after the human supplied a result. If the human names context but gives no result, ask only: `What happened?` Then stop.

**Whole-review verdict rule.** Treat a clear, unqualified verdict as substantive feedback. Examples include `all went as planned`, `everything worked`, `everything matched the plan`, and `all good`.

When the verdict refers to the whole review:
- Record the user's verdict in `Result`.
- Mark every Phase check `passed`.
- Mark every presented assumption `confirmed`.
- Do not infer a Decision choice. Closure and successful checks do not answer every learning question.

A qualifier narrows the verdict. For example, `all tests passed` covers the tested Phase checks. It does not confirm product assumptions. If the human states a choice and a result that directly supports it, reuse that result as the Decision's `Why`. Do not make the human restate it.

**A clear positive verdict closes in one exchange — with or without the literal `close it`.** When the verdict is unqualified and nothing in the message needs triage judgment (no defect, refinement, new idea, gap, or rejection to classify), apply the whole-review mapping silently — verdict recorded verbatim as `Result`, every Phase check `passed`, every assumption `confirmed`, resolve sweep run — go straight to STEP 3, and reply with the terse execution-log changelog. Do not present the triage echo or ask whether anything is in the wrong bucket. The echo-back confirmation round survives **only** for mixed or negative feedback, where Mano made triage judgments the human must check.

**Phase-check rule:** Record one result for every Exit Criterion — `passed`, `failed`, `not tested`, or `signed off`. A user-reported failure becomes a 🐛 Defect unless they reject the promised outcome. Do not treat an omitted check as passed. A check the human did not report on records `signed off` when they closed the phase (see **Closing semantics** below), and `not tested` only where the review does not close it.

**Splitting rule:** A single sentence can contain both a failure signal and an improvement detail — split them. If the user says "there's an issue with X, and it should also do Y", the failure is a 🐛 Defect and the improvement detail is a 🔧 Refinement. Defect signals: "issue", "broken", "doesn't work", "fails", "wrong", "missing". Do not collapse a defect into a refinement just because the user described a fix in the same breath.

**Rejected-scope rule:** When the feedback rejects a scoped direction, feature, or assumption ("reject", "drop", "abandon", "we're not doing X anymore", "different direction"), the additions are only half the triage — the other half is the open items that direction leaves orphaned. Read `_mano_output/backlog.md` and list every item still `Status: backlog` that is predicated on the rejected direction as a ❌ rejection candidate, one line each, exact title first. Matching is a judgment call the human confirms per item: propose candidates, never auto-reject, and when unsure whether an item depends on the rejected direction, include it as a candidate and say why — the user removes it from the list if it survives. In-phase items are not candidates; they belong to the phase's close sweep.

For mixed or negative feedback — anything Mano had to classify — echo **only the findings about to be recorded** and ask once (a clear positive verdict skipped this under the whole-review verdict rule above):

```text
[mano review]: [PHASE_ID] — recording:

🐛 Defects:
1. [one sentence with enough context]

🔧 Refinements:
2. [one sentence]

✨ New ideas:
3. [one sentence]

❌ Rejected scope — confirm each:
4. "[exact backlog item title]" — [why the rejected direction orphans it]

Anything in the wrong bucket? Otherwise "close it".
```

**Echo the judgments, not the record.** What goes in this message is what *Mano decided*: each triaged finding under its bucket (📋 Spec gaps and 📏 Rule gaps use the same shape), each ❌ rejection candidate, and any assumption you are marking `invalidated` on inference rather than on the human's own words. Omit every empty bucket. The Validation result, the Decision, the Phase-check results, and the assumptions the human ruled on themselves are **recorded in STEP 3, not echoed here** — reading back what the human just said costs an exchange and confirms nothing. No goal restatement, no phase-check table, no closer menu: one list, one ask.

Rejection candidates follow the same confirmation model as every other bucket: they are visible in this list, the user removes any that survive, and `close it` confirms the list as presented. Never reject an item that was not listed as a candidate here.

**`close it` arriving with a negative finding closes the phase; it does not erase the finding.** "The export is broken, close it" is two instructions, and silently dropping the first is the one outcome the human cannot recover. Echo the finding and ask which it is — routed to rework, or dismissed in their own words — then close in that same exchange. Never infer the dismissal (see **Relay a dismissal, never conclude one** below).

That is your complete response. DO NOT write files yet.

**Fast close — explicit close without a result.** Use this path only when the reply says `close it` and supplies no validation result, decision, assumption verdict, or feedback. Examples include `close it` and `I did not test it; close it`. A positive summary verdict never uses this path.

Skip the triage presentation and go straight to STEP 3. Write no backlog items. Run the resolve sweep and write the review entry. Record `Validation` as `Result: Not tested` and omit `Checked with` — they reported no result, and the record says so. Record the decision as `Not assessed` and omit its Why. Record `Backlog changes` as `None`. Omit `What we learned`. Everything else follows **Closing semantics** below. Do not ask for feedback or another confirmation.

**The close instruction is terminal — never re-confirm it.** A message may carry a whole-review verdict, individual verdicts, or feedback with its close instruction. Examples include `all went as planned, close it` and `1 confirmed, 2 invalidated; close it`. Apply the supplied outcomes, then go straight to writing files. Do **not** emit another triage-confirmation prompt. The user already confirmed the review.

**Dismissing a build-path finding is the human's word, never an inference.** When the human rejects a finding outright during triage — "that's intended", "not doing that, close it" — and it had already been written as a rework event, record that exact decision:

```
node _mano/scripts/progress.js resolve-rework --phase [N] --expect-phase-id [PHASE_ID] --id R2 --status dismissed --reason-file [tmp].txt
```

The reason file holds the human's own words; the script refuses a dismissal without one. **Relay a dismissal, never conclude one** — not because a finding looks minor, not because it seems already handled, and not to clear the way to a close.

The one thing that survives a close instruction is a ❌ rejection candidate the user has not seen. "Drop the dock work, close it" closes the phase, but the open backlog items that rejection orphans are information the user has not been shown, not a re-confirmation of something they already approved. Present the ❌ list alone — no other buckets, no re-litigating the rest of the triage — and write the rest of the close in the same turn.

---

**Closing semantics — `close it` is full human sign-off.**

The human typed it. That is an attestation, and recording it as *untested* would be the framework second-guessing the person it exists to serve. On `close it`, or on an explicit clear all-good verdict:

- **Exit Criteria.** On the build path, `progress.js sign-off` flips every `pending` and `needs-human` leaf to `met` and records `human sign-off at review, [date]` against each one, so the ledger says *who* proved it. In the review record, a criterion the human reported on keeps their result (`passed` / `failed`); one they did not is `signed off`, matching the ledger. On the stories path there is no ledger and the review record is the whole account.
- **Assumptions.** An assumption the human ruled on keeps their verdict (`confirmed` / `invalidated`). One they did not rule on records `accepted`: the phase shipped on it and they closed it. `inconclusive` is for an assumption the human says they still cannot call, not for one they never mentioned.
- **Validation Questions.** An unanswered question records `unanswered at close` — never as answered, passed, or accepted. *"Ship it" does not answer a question the human was asked*, and a question that quietly resolves itself at close is a question there was no point asking. It carries its `Q…` address so a later phase can pick it up.
- **Validation.** `Result` is what the human reported. They reported nothing, it is `Not tested` — sign-off is an attestation, not evidence, and the record keeps the two apart.

There is no second closing keyword. A human who wants to record a failure says what broke; that is already the triage path, and a second keyword would cost the one exchange this whole flow is built to fit in.

---

**STEP 3 — Write to Files (One-Shot Execution)**

When the user confirms (e.g., "close it", "yes"):
1. Read the exact current phase brief's optional `**Track:**` line. If present, use that exact value on every new review item; if absent, omit `track`. Never substitute the active local track: review preserves the experiment that produced the feedback. Then write ALL confirmed triaged items to the backlog **via the writer — don't hand-write the item blocks.** **Map each triage category to its exact `Type` first** (this classification is the review's job; the script only takes the result):
   - 📋 Spec gaps → `spec-gap`
   - 📏 Rule gaps → `rule-gap`
   - 🐛 Defects → `bug`
   - 🔧 Refinements → `refinement`
   - ✨ New ideas → `feature`

   One item — shell-safe flags:
   ```
   node _mano/scripts/backlog.js add --title "[short title]" --type [type] --context "[what it is; why it matters]" --source "[PHASE_ID] review" [--track "[phase brief Track]"]
   ```
   Several items — write a JSON array to a temp file with your file tool (no shell quoting), each element `{ "title", "type", "context", "source": "[PHASE_ID] review", "track"?: "[phase brief Track]" }`, and pass it:
   ```
   node _mano/scripts/backlog.js add --file [tmp].json
   ```
   The script owns the `### / **Type:** / **Context:** / **Status:**` shape, starts every item at `Status: backlog`, and skips any title already present — so you can't misname, invent, or duplicate a field. **Script failing?** Stop and report the error — do not hand-write item blocks (see "Scripts are mandatory" in `_mano/rules/core.md`). For reference, the exact shape the writer produces:

   ```markdown
   ### [Short title]
   - **Type:** bug / refinement / feature / tech-debt / test / spec-gap / rule-gap
   - **Source:** [PHASE_ID] review
   - **Track:** [copy the phase brief's Track, if present]
   - **Context:**
     [what it is; why it matters]
   - **Status:** backlog
   ```
1b. **On the build path only — persist confirmed findings as durable rework, and record the human's sign-off.**

   These two calls are review's entire write surface on `progress.md`. Skip both on the stories path.

   **Findings first.** For every confirmed **substantive** finding — 🐛 Defects, 📋 Spec gaps, 📏 Rule gaps, and any 🔧 Refinement the human wants fixed in this phase — write one event per finding, in the order they were triaged:

   ```
   node _mano/scripts/progress.js request-rework --phase [N] --expect-phase-id [PHASE_ID] --text-file [tmp].txt
   ```

   **One event per finding, each with its own exact text.** Never squeeze mixed feedback into a single blob: build classifies each event A/B/C on its own, and an aggregate event cannot be classified at all. The text file holds the finding as the human described it — their words, not a summary — because that text is what a fresh session will read weeks later.

   This is why the events exist: a conversation does not survive a compaction, a restart, or an interleaved command, and a confirmed finding must. Once written, `state.js` routes the phase back to `mano build` while any event is `pending`, even though every row already reads `done`. A ✨ New idea is not a finding — it is backlog, and it does not reopen the phase.

   **Then the sign-off.** When the human closes the phase — a clear positive verdict, or the literal `close it` — record that attestation:

   ```
   node _mano/scripts/progress.js sign-off --phase [N] --expect-phase-id [PHASE_ID]
   ```

   It flips every `pending` and `needs-human` Exit leaf to `met` and records `human sign-off at review, [date]` against each one. Typing `close it` **is** a human attestation, and the ledger records *who* proved each criterion rather than leaving it as a status nobody owns. The script refuses while any rework event is pending — which is correct: a phase with an open finding is not closing.

   Do not run `sign-off` when the review produced findings that route back to build. Do not run it to tidy a ledger the human did not close.

2. **Resolve shipped items — via the writer's close sweep:**
   ```
   node _mano/scripts/backlog.js resolve --phase [N]
   ```
   It flips every item carrying the current owner's exact projected `IN_PHASE_STATUS` to `resolved` — the whole phase in one call — which officially closes that owner-scoped phase. It never matches another owner's in-phase status, and the items you just triaged remain `Status: backlog`. **Script failing?** Stop and report the error — do not flip statuses by hand.
3. **Retire rejected scope — via the writer, only for ❌ items the user confirmed:**
   ```
   node _mano/scripts/backlog.js reject --title "[exact title]" --title "[exact title]"
   ```
   It flips each named open item to `Status: rejected`, which is not `resolved`: rejected means no longer wanted, resolved means shipped or fixed. Never conflate them — a rejected item recorded as resolved falsely claims the work was done. Skip this step entirely when the triage had no confirmed ❌ items. **Script failing?** Stop and report the error — do not flip statuses by hand.
4. If `_mano_output/reviews.md` does not exist, create it with the top-level title.
5. **Always append** the new review entry at the **bottom** of `_mano_output/reviews.md`. Never insert between existing entries.
6. Fill the review template concretely. Always write a Validation result. Preserve what the human reported. Use `Not tested` only when they reported no result. Add `Checked with` only when the human named the context. Never write an evidence level, `Tried`, or `Not recorded`. A whole-review verdict counts as a stated result and assumption verdict under the Validation rule. **The record is the complete one, even though the echo was short:** add every Exit Criterion leaf to `Phase checks` at its `E…` address, every Validation Question at its `Q…` address, and every assumption at its `A…` address — the same addresses the opening used. Their values follow **Closing semantics** above. Record the human's choice. Use `Not assessed` when they made none. Never infer a choice from completion or test success. When the human states both a choice and a result that directly supports it, reuse the result as `Why`. Otherwise omit Why. List only confirmed backlog changes, or `None`. Omit `What we learned` unless a reusable lesson changes future work.

   **No release recap.** The review entry is a compact validation-and-decision record, not a phase summary or mini-postmortem. Do not record story counts, test counts, shipped-feature inventories, implementation summaries, empty "worked/didn't work" sections, or generic lessons unless a fact directly supports the decision. A lesson belongs in `What we learned` only when it can change a future decision or working rule; name the destination when the user provides one.

Output a cold execution log:
Use the canonical execution-log format defined in `_mano/rules/core.md` ("Canonical execution-log format"):

```
[mano review]: mano review — _mano_output/backlog.md, _mano_output/reviews.md
- Triaged items inserted to backlog
- [N] backlog item(s) marked rejected — omit this line if none
- Validation: [recorded / not tested]
- [PHASE_ID] items marked resolved
- [PHASE_ID] closed
⚠ Verify: [material triage decision worth checking — omit if none]

[Optional hook block if active]

Next:
- `mano start` — scope the next phase from the updated backlog
```
That is your complete response.

## Follow-up review

Use this path only if `_mano_output/reviews.md` already contains an H2 whose prefix exactly matches the projected `REVIEW_HEADING_PREFIX` and the user has completed follow-up fix work.

This is also a multi-turn conversation. Each step is ONE message. After sending the message, do NOTHING else until the user replies.

Even in follow-up review, `mano review` is only collecting outcomes after fix work. `mano review` does not investigate, propose code changes, or perform any fixes.

If the activation message already contains substantive follow-up feedback, skip the waiting prompt and go straight to the triage response format from STEP 2 after checking the existing review state.

---

**STEP 1 — If the activation message does not already contain substantive follow-up feedback, your entire response must be ONLY this format:**

```text
[mano review]: [PHASE_ID] follow-up.

Left open:
1. [the finding the recorded review logged, one line]
2. [next finding]

What's fixed, what's still broken, or "close it".
```

Same rule as the standard opening: one response, one ask, every open item separately visible, no enumeration checklist and no closer menu. `Left open:` lists what the recorded review entry logged as a defect, refinement, or open outcome — one line each, from the review entry and the backlog items it named, never invented. When the recorded review left nothing open, omit the list and let the ask stand alone.

That is your complete response. No preamble. No explanation. End of message.

---

**STEP 2 (Follow-up) — Triage Feedback**

When the user replies, or when substantive follow-up feedback was already included in the activation message, perform triage based on `_mano_output/backlog.md`.

The **whole-review verdict rule** from the standard review applies here too: a clear, unqualified positive verdict with nothing to triage skips this confirmation — apply the mapping silently, go straight to STEP 3 (Follow-up), and reply with the terse changelog. For mixed or negative feedback, present the triaged outcomes for confirmation:

```text
[mano review]: [PHASE_ID] follow-up — recording:

✅ Resolved:
1. [one sentence]

🐛 Still broken:
2. [one sentence]

🔧 Still rough:
3. [one sentence]

✨ New ideas:
4. [one sentence]

❌ Rejected scope — confirm each:
5. "[exact backlog item title]" — [why the rejected direction orphans it]

Anything in the wrong bucket? Otherwise "close it".
```

That is your complete response. DO NOT write to files yet.

**The standard STEP 2's echo rule applies unchanged:** echo the judgments, not the record. Omit every empty bucket. The Validation result and any Decision update are recorded in STEP 3 (Follow-up), not read back here. The ❌ section follows the same **Rejected-scope rule**: propose candidates from the open backlog, never auto-reject, and omit the section when the feedback rejects nothing.

Use the standard review's Validation, **Closing semantics**, and no-release-recap rules here too. Record a `Decision update` only when the user states one.

**Fast close — explicit close with no result.** If the follow-up reply says `close it` and contains no result or feedback, skip the triage presentation. Go straight to STEP 3 (Follow-up) with an empty triage. Write no new backlog items. Append the addendum with `Validation` set to `Result: Not tested`. Omit `Checked with` and Decision update. Record `Outcome changes: None`. A positive summary result follows the standard Validation rule and never becomes `Not tested`.

---

**STEP 3 (Follow-up) — Write to Files (One-Shot Execution)**

When the user confirms (e.g., "close it", "yes"):
1. Read `_mano_output/backlog.md`.
2. Match resolved items to existing backlog items and flip each to `Status: resolved` by hand (these are specific `backlog` items now fixed — a title-scoped edit, not the `resolve --phase` sweep).
3. Append any still open / new ideas to the backlog **via `node _mano/scripts/backlog.js add`** (same flags / `--file` as the standard STEP 3.1) — don't hand-write the blocks. **Script failing?** Stop and report the error.
4. Retire any confirmed ❌ items **via `node _mano/scripts/backlog.js reject --title "[exact title]"`** (same writer and same rejected-vs-resolved distinction as the standard STEP 3.3). Skip when the triage had no confirmed ❌ items.
5. **Do not create a new follow-up review section.** Find the existing owner-aware H2 that begins with the exact projected `REVIEW_HEADING_PREFIX` and append an `### Addendum — [Date]` subsection directly under it (before the next `---` separator). Use the concise addendum structure from `_mano/templates/phase-review.md`. Always record its Validation result. Add `Checked with` only when supplied. Record a decision update only when the human made one. List only actual outcome/backlog changes.

Output execution log (canonical format, see `_mano/rules/core.md`):
```
[mano review]: mano review — _mano_output/backlog.md, _mano_output/reviews.md
- Follow-up statuses updated in backlog
- [N] backlog item(s) marked rejected — omit this line if none
- Validation: [recorded / not tested]
- Addendum appended to [PHASE_ID] review entry

[Optional hook block if active]

Next:
- `mano start` — scope the next phase when the backlog is ready
```
That is your complete response.

## Review log

`mano review` must use `_mano/templates/phase-review.md` as the source of truth for review entries.

- Standard review: append ` — [Date]` to the exact projected `REVIEW_HEADING_PREFIX`, then use the structure from the template.
- Follow-up review: do not create a new follow-up heading. Append an `### Addendum — [Date]` subsection to the existing H2 with that exact prefix, using the addendum structure from the template.
- If `_mano_output/reviews.md` does not exist yet, create it with the template title first, then append real entries.
- The example sections in `_mano/templates/phase-review.md` are structural references only. Do not copy them verbatim into the live file.
- Keep each appended entry concise and concrete. Write for someone who was not in the room. Its job is to preserve evidence, the human decision, assumption outcomes, and resulting backlog changes — not to retell the release.

## Post-review hook

If the state projection's `HOOK:` line names `post-review`, follow `_mano/rules/hooks.md` for it. Otherwise skip hooks entirely — do not probe or `ls` `_mano/hooks/` yourself (the shipped `post-review.example.md` is never active; the projection already excludes it). `mano review` is always human-run and outside the auto chain, so it is an unarmed run even when `MODE: auto`. This check applies even when no review update was needed.

## Forbidden

- Do not skip the review questions. Prior conversations do not count as a review.
- Do not auto-decide during review. Each step is one message. Do not combine steps.
- Do not write any files until the user confirms the triage in STEP 3.
- Do not debug, inspect code, trace payloads, propose patches, run tests, or attempt repairs. `mano review` only classifies feedback and updates backlog/review files after confirmation.
- Do not create stories. `mano review` writes to the backlog and review log only.
- Do not manage story or ledger state. Do not edit story files, mark stories `done`, cut stories, or touch the stories README index — not even in the pre-review gate. If stories aren't `done`, refuse per the pre-review gate and point the user to `mano dev` or their own README edit.
- Do not run `progress.js` outside its three sanctioned surfaces: `request-rework`, `resolve-rework`, and `sign-off`. Never `init`, `set-status`, `split`, or `add-row` — flipping a Scope row would make review the thing that decides work is done.
- On a build-path phase, do not ask for an `Implementation Reference`, open a story file, or route to `mano stories` / `mano dev`. There are no stories, and creating one would give the phase two ledgers.
- Do not check off acceptance criteria in story files.
- Do not scope the next phase. That's `mano start`'s job.
- Do not present the backlog or use it for scoping. Reading it is allowed for two purposes only: in STEP 2, to find rejection candidates when the feedback rejects a scoped direction (list only those candidates, never the backlog at large); and in STEP 3, to append, deduplicate, resolve, or reject items.
- Do not reject a backlog item the user did not confirm as a listed ❌ candidate, and never mark a rejected item `resolved` — that records unwanted work as shipped.
- Do not create files outside the defined output structure. `mano review` writes to `backlog.md` and `reviews.md` only. No extra tracking files.
