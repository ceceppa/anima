---
name: mano-review
description: Use at the end of a phase to triage feedback, capture bugs/refinements, and write the phase review log before closing the phase.
---

# `mano review` — Review Skill

## Identity

This skill collects feedback and triages it — nothing else. Prefix every message with `[mano review]:`. It does not scope, does not plan, does not write code.

**This skill does not investigate.** It does not read source files, run tests, trace payloads, inspect build output, or look at any current implementation state. The only files it reads are Mano artifacts under `_mano_output/` (story index, phase brief, backlog, reviews). A bug description is *input to classify*, not a problem to diagnose. This holds even when the bug description names a specific symptom, a working/broken contrast, or hints at a likely cause — those are triage signals, not investigation prompts. Reading source code is **not** "not writing code"; it is investigation, and it is forbidden in this skill.

## Activation

This skill activates when the user types `mano review`.
The agent should execute `mano review`'s review flow directly in chat. Do not tell the user to run `mano review` themselves or treat it as an external shell command.

If the user's activation message already includes substantive review feedback after `mano review`, treat that text as Step 2 review input once the pre-review gate is clear. Do not ignore inline feedback just because it arrived in the same message as the command.

On activation:
1. Run `node _mano/scripts/state.js --current`. This is the only phase-directory discovery. If it fails, lacks `STATUS`, `OWNER`, `PHASE`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, `STORIES`, `IN_PHASE_STATUS`, and `REVIEW_HEADING_PREFIX`, or reports `STATUS: NO_PHASE`, stop and route to `mano start`. Record the exact values; never construct `phase-N` or a review heading from the number.
2. Read the exact projected `STORIES` path to check story completion status.
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

At the beginning of every later turn in this multi-turn review, rerun `node _mano/scripts/state.js --current`. Continue only when `OWNER`, `PHASE_ID`, `PHASE_DIR`, `BRIEF`, `STORIES`, `IN_PHASE_STATUS`, and `REVIEW_HEADING_PREFIX` exactly match the activation projection. If ownership or phase state changed, write nothing and ask the user to invoke `mano review` again. Running this deterministic projection is part of review routing, not implementation investigation.

## Pre-review gate

If any stories are not marked `done`, **refuse and stop**. Review does not manage story state — that is not its job. Report what's pending and point to the right path:

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

If the activation message already contains substantive review feedback, skip the waiting prompt and go straight to the triage response format from STEP 2 after reading the phase goal. Keep the phase goal visible in that response.

---

**STEP 1 — Read the phase brief to get the phase goal and its Assumption Log. If the activation message does not already contain substantive feedback, your entire response must be ONLY this format:**

```
[mano review]: Review initiated. [PHASE_ID] goal: "[phase goal]"

This phase assumed:
1. [assumption — verbatim from the brief's Assumption Log]
2. [assumption]

Confirm, invalidate, or skip each (e.g. "1 confirmed, 2 invalidated: <what actually happened>").
Then log unstructured feedback: what is broken, what needs refinement, and any new ideas — or say "close it" if there's nothing to log.
```

If the brief has no Assumption Log entries, omit the assumptions block and the confirm/invalidate line.

That is your complete response. No preamble. No explanation. No extra commentary or planning. End of message.

---

**STEP 2 — Triage Feedback**

When the user replies with their feedback, or when substantive feedback was already included in the activation message, triage it into six buckets:
- 🐛 Defects — broken things from this phase
- 🔧 Refinements — things that work but could be better
- ✨ New ideas — emerged from usage, not originally scoped
- 📋 Spec gaps — missing or unclear tech spec (if applicable)
- 📏 Rule gaps — missing or unclear rules (if applicable)
- ❌ Rejected scope — open backlog items whose premise this feedback invalidates (if applicable)

**Splitting rule:** A single sentence can contain both a failure signal and an improvement detail — split them. If the user says "there's an issue with X, and it should also do Y", the failure is a 🐛 Defect and the improvement detail is a 🔧 Refinement. Defect signals: "issue", "broken", "doesn't work", "fails", "wrong", "missing". Do not collapse a defect into a refinement just because the user described a fix in the same breath.

**Rejected-scope rule:** When the feedback rejects a scoped direction, feature, or assumption ("reject", "drop", "abandon", "we're not doing X anymore", "different direction"), the additions are only half the triage — the other half is the open items that direction leaves orphaned. Read `_mano_output/backlog.md` and list every item still `Status: backlog` that is predicated on the rejected direction as a ❌ rejection candidate, one line each, exact title first. Matching is a judgment call the human confirms per item: propose candidates, never auto-reject, and when unsure whether an item depends on the rejected direction, include it as a candidate and say why — the user removes it from the list if it survives. In-phase items are not candidates; they belong to the phase's close sweep.

Present the triaged list to the user for confirmation:

```
[mano review]: Feedback Triaged. [PHASE_ID] goal: "[phase goal]"

🐛 Defects:
1. [one sentence with enough context]

🔧 Refinements:
2. [one sentence]

✨ New ideas:
3. [one sentence]

❌ Rejected scope (open backlog items this feedback invalidates — confirm each):
4. "[exact backlog item title]" — [why it depends on the rejected direction]

Does this look right? Tell me what to move or remove, or say "close it" to log this.
```

Omit the ❌ section when the feedback rejects nothing. Rejection candidates follow the same confirmation model as every other bucket: they are visible in the presented list, the user removes any that survive, and "close it" confirms the list as presented. Never reject an item that was not listed as a candidate in this message.

That is your complete response. DO NOT write files yet.

**Fast close — no feedback to triage.** If the user's reply contains no feedback to triage (e.g. "nothing to report, close it", "close it", "all good"), skip the triage presentation entirely — there is nothing to confirm. Treat the reply as direct confirmation and go straight to STEP 3 with an empty triage: no backlog items are written, the resolve sweep and review entry still happen. In the review entry, fill the Assumption results table from any verdicts the user gave in STEP 1; record `What we'd do differently` as "No feedback logged." Do not ask a follow-up question to fish for feedback before closing — "close it" means close it.

**The close instruction is terminal — never re-confirm it.** When a single message carries both the assumption verdicts and a close instruction (e.g. "all valid, close it", "1 confirmed 2 invalidated, close it", "all good close it"), that one message clears STEP 1 *and* is the STEP 3 confirmation. Go straight to writing files. Do **not** emit an empty-triage "Does this look right? Say close it to log" message — that is a second confirmation gate the user already satisfied, and it is the exact double-confirm this rule forbids. Re-prompting after the user has already said "close it" is a bug, not caution.

The one thing that survives a close instruction is a ❌ rejection candidate the user has not seen. "Drop the dock work, close it" closes the phase, but the open backlog items that rejection orphans are information the user has not been shown, not a re-confirmation of something they already approved. Present the ❌ list alone — no other buckets, no re-litigating the rest of the triage — and write the rest of the close in the same turn.

---

**STEP 3 — Write to Files (One-Shot Execution)**

When the user confirms (e.g., "close it", "yes"):
1. Write ALL confirmed triaged items to the backlog **via the writer — don't hand-write the item blocks.** **Map each triage category to its exact `Type` first** (this classification is the review's job; the script only takes the result):
   - 📋 Spec gaps → `spec-gap`
   - 📏 Rule gaps → `rule-gap`
   - 🐛 Defects → `bug`
   - 🔧 Refinements → `refinement`
   - ✨ New ideas → `feature`

   One item — shell-safe flags:
   ```
   node _mano/scripts/backlog.js add --title "[short title]" --type [type] --context "[what it is; why it matters]" --source "[PHASE_ID] review"
   ```
   Several items — write a JSON array to a temp file with your file tool (no shell quoting), each element `{ "title", "type", "context", "source": "[PHASE_ID] review" }`, and pass it:
   ```
   node _mano/scripts/backlog.js add --file [tmp].json
   ```
   The script owns the `### / **Type:** / **Context:** / **Status:**` shape, starts every item at `Status: backlog`, and skips any title already present — so you can't misname, invent, or duplicate a field. **Script failing?** Stop and report the error — do not hand-write item blocks (see "Scripts are mandatory" in `_mano/workflow.md`). For reference, the exact shape the writer produces:

   ```markdown
   ### [Short title]
   - **Type:** bug / refinement / feature / tech-debt / test / spec-gap / rule-gap
   - **Source:** [PHASE_ID] review
   - **Context:**
     [what it is; why it matters]
   - **Status:** backlog
   ```
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
6. Fill the template sections concretely. When scope was rejected, the review entry records what was rejected and why in the narrative sections — it is the phase's durable record of a direction change.

Output a cold execution log:
Use the canonical execution-log format defined in `_mano/workflow.md` ("Canonical execution-log format"):

```
[mano review]: mano review — _mano_output/backlog.md, _mano_output/reviews.md
- Triaged items inserted to backlog
- [N] backlog item(s) marked rejected — omit this line if none
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

```
[mano review]: [PHASE_ID] follow-up review. We already logged the main review for this phase.

Tell me what changed after the fixes — what's resolved, what's still broken, what's still rough, and anything new that showed up.
```

That is your complete response. No preamble. No explanation. End of message.

---

**STEP 2 (Follow-up) — Triage Feedback**

When the user replies, or when substantive follow-up feedback was already included in the activation message, perform triage based on `_mano_output/backlog.md`:

Present the triaged outcomes for confirmation:

```
[mano review]: Follow-up Triaged. [PHASE_ID]

✅ Resolved:
1. [one sentence]

🐛 Still broken:
2. [one sentence]

🔧 Still rough:
3. [one sentence]

✨ New ideas:
4. [one sentence]

❌ Rejected scope (open backlog items this feedback invalidates — confirm each):
5. "[exact backlog item title]" — [why it depends on the rejected direction]

Does this look right? Tell me what to move or remove, or say "close it".
```

That is your complete response. DO NOT write to files yet.

The ❌ section follows the same **Rejected-scope rule** as the standard STEP 2: propose candidates from the open backlog, never auto-reject, and omit the section when the feedback rejects nothing.

**Fast close — nothing to triage.** If the user's follow-up reply contains no feedback to triage (e.g. "everything's resolved, close it", "all good"), skip the triage presentation — there is nothing to confirm. Treat the reply as direct confirmation and go straight to STEP 3 (Follow-up) with an empty triage: no new backlog items are written; the addendum is still appended, recording the outcomes the user stated (or "No follow-up feedback logged"). Do not ask a follow-up question to fish for feedback before closing.

---

**STEP 3 (Follow-up) — Write to Files (One-Shot Execution)**

When the user confirms (e.g., "close it", "yes"):
1. Read `_mano_output/backlog.md`.
2. Match resolved items to existing backlog items and flip each to `Status: resolved` by hand (these are specific `backlog` items now fixed — a title-scoped edit, not the `resolve --phase` sweep).
3. Append any still open / new ideas to the backlog **via `node _mano/scripts/backlog.js add`** (same flags / `--file` as the standard STEP 3.1) — don't hand-write the blocks. **Script failing?** Stop and report the error.
4. Retire any confirmed ❌ items **via `node _mano/scripts/backlog.js reject --title "[exact title]"`** (same writer and same rejected-vs-resolved distinction as the standard STEP 3.3). Skip when the triage had no confirmed ❌ items.
5. **Do not create a new follow-up review section.** Find the existing owner-aware H2 that begins with the exact projected `REVIEW_HEADING_PREFIX` and append an `### Addendum — [Date]` subsection directly under it (before the next `---` separator). Use the addendum structure from `_mano/templates/phase-review.md`.

Output execution log (canonical format, see `_mano/workflow.md`):
```
[mano review]: mano review — _mano_output/backlog.md, _mano_output/reviews.md
- Follow-up statuses updated in backlog
- [N] backlog item(s) marked rejected — omit this line if none
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
- Keep each appended entry concise and concrete. Write for someone who was not in the room.

## Post-Review Hook Suggestion

After `mano review` completes, always check whether this exact file exists:

`_mano/hooks/post-review.md`

Test for that one path directly (a targeted existence check, e.g. `test -f _mano/hooks/post-review.md`). Do **not** `ls` the hooks directory and reason about its contents: the directory always ships a `post-review.example.md` template, which is **not** an active hook, and listing-then-classifying is where it gets mistaken for one. Only the exact `post-review.md` (no `.example`) counts.

If that active `post-review.md` hook exists, prepare the generic hook block for the final chat response.

Check the hook's `## Mode` first: a `command` hook runs automatically in both modes and is reported in the execution log, never as a suggestion (`_mano/workflow.md` → **Optional Post-Skill Hooks**). Do not run a `suggest` hook automatically.

Do not mention specific third-party skill names, slash commands, external tool names, or the hook's full suggested prompt unless the user explicitly asks to run or inspect the hook.

This step is required even when no review update was needed.

Mention it in the final chat response before the next-action block.

This applies whether the skill:
- created an artifact
- updated an artifact
- checked existing artifacts and decided no update was needed

Do not print the hook's suggested prompt unless the user asks to run or view the hook.
Do not execute the hook without explicit user confirmation.
Do not write hook suggestions into generated artifacts.

## Forbidden

- Do not skip the review questions. Prior conversations do not count as a review.
- Do not auto-decide during review. Each step is one message. Do not combine steps.
- Do not write any files until the user confirms the triage in STEP 3.
- Do not debug, inspect code, trace payloads, propose patches, run tests, or attempt repairs. `mano review` only classifies feedback and updates backlog/review files after confirmation.
- Do not create stories. `mano review` writes to the backlog and review log only.
- Do not manage story state. Do not edit story files, mark stories `done`, cut stories, or touch the stories README index — not even in the pre-review gate. If stories aren't `done`, refuse per the pre-review gate and point the user to `mano dev` or their own README edit.
- Do not check off acceptance criteria in story files.
- Do not scope the next phase. That's `mano start`'s job.
- Do not present the backlog or use it for scoping. Reading it is allowed for two purposes only: in STEP 2, to find rejection candidates when the feedback rejects a scoped direction (list only those candidates, never the backlog at large); and in STEP 3, to append, deduplicate, resolve, or reject items.
- Do not reject a backlog item the user did not confirm as a listed ❌ candidate, and never mark a rejected item `resolved` — that records unwanted work as shipped.
- Do not create files outside the defined output structure. `mano review` writes to `backlog.md` and `reviews.md` only. No extra tracking files.
