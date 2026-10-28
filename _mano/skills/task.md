---
name: mano-task
description: Use to implement one narrow piece of work directly, without a phase. Takes an existing backlog item's title or a plain description of new work, asks how the human will check it unless they already said what they should see, makes sure the item is clearly written first, then implements exactly that item. Refused while a phase is open.
requires: []
---

# `mano task "[item title or what you want]"` — implement one item without a phase

## Language check — before any response

After loading this contract and its required rules, run `node _mano/scripts/settings.js language` from the project root **before the first user-facing message or any project write**. Use the returned `language.chat` for all conversation, including progress, questions, errors, and the final response; use `language.artefacts` for new planning artifacts and `language.build` for new implementation content (code, tests, product documentation, and product/UI text, including preview copy). The command resolves missing or `null` `artefacts` through `build`, then `chat`, then `null`. Never read settings JSON directly or infer languages from the prompt, source files, or this skill's English examples. A `null` value preserves existing behaviour for that channel only. If the command fails or any of the three fields is absent, report the failure and stop; do not guess.

This check applies on direct invocation, auto-chain handoff, and resumption after interruption or compaction. Re-run after an owner or language change. English response examples, including “exact” or one-line templates, constrain structure and meaning, not prose language: translate their prose into `language.chat`. Preserve command names, paths, required labels, status tokens, and verbatim quotations or diagnostics. Before sending **each** message, check its prose against `language.chat`; before each project write, check planning prose against `language.artefacts` and implementation content against `language.build`. Do not emit an extra language-confirmation message. The human's own words stay verbatim in whatever language they used.

## What it is for

`mano task` is for validating a single narrow idea: build one piece, try it for real, then decide the next one. It skips the phase brief, stories, ledger, and review. It keeps everything that makes the result trustworthy: the item is written down before any code, the artifacts are followed, missing decisions are routed to their owners, and the item only closes on evidence.

A phase is the right tool when several items have to land together, or when the work needs a goal and a review. `mano task` is the right tool when one item can be built and judged on its own.

This file is the complete contract. It carries its own copies of the `mano dev` / `mano build` readiness and done gates, adapted from a story to a backlog item; each copy is marked with the `_mano/rules/implement.md` step it mirrors, so a change to one is easy to carry to the other. Do not load `_mano/rules/implement.md` as well: its phase-scope gate assumes a phase brief, and here there isn't one.

`mano task` is only ever started by the human. Auto mode never chains into it, `mano continue` never selects it, and no other skill's `Next:` line offers it as a substitute for a phase. Once the human has typed it, auto mode may run the owner of a readiness gap and come back to the item (see **Auto mode: gap repair**).

## Steps

1. **Check the gate.** Run `node _mano/scripts/state.js --task`. On `TASK: refused`, stop: a phase is open, and its own path owns the code until review closes it. Relay `OPEN_PHASE` and `REASON` in the refused output (see Output) and write nothing. Closing a `needs-human` item is the one exception: it changes a status line, never code, so it runs whatever the gate says. The `NEEDS_HUMAN:` lines list every item waiting on the human. The `IN_TASK:` lines list every item an earlier run edited and didn't finish; if one is not the item this request names, carry it to the human as one `⚠ Verify:` line (`"<title>" is still in-task from an earlier run`) and continue.
2. **Find the item.** Run `node _mano/scripts/state.js --titles --match "<text>"`, with the request itself when it reads like a title, otherwise its most distinctive word. Never open `backlog.md` to search it.
   - **One exact title match** (case-insensitive) → that item. Go by its status: `backlog` → step 3. `in-task` → an earlier run started it and didn't finish: skip step 3, since the item was written before that run's first edit, and go to step 4, treating the changes it left as this item's work so far. `needs-human` → **Closing a `needs-human` item** below. `in-phase-*` → stop; it belongs to its phase (`mano dev` / `mano build`). `resolved` or `rejected` → stop and say so; a change to finished work is a new item, so offer to run the request as one.
   - **A gap type** (`spec-gap`, `rule-gap`, `ux-gap`, `ui-gap`) is a decision, not code: stop and route it to `mano spec` / `rules` / `ux` / `ui`.
   - **No exact match** → the request is new work. If the roster shows titles that look like the same work, list them and ask once whether it is one of those or a new item. Otherwise go to step 3 with a new item.
3. **Clarify the item** (see **Clarify before code**). This step ends either with a clearly written item in `backlog.md` and its outcome, or with questions for the human and no other writes.
4. **Read project context before you change anything:** the item's context, the artifacts it names, and `_mano_output/project-rules.md` for the area you'll touch. Then read source.
5. **Run the readiness gates (R2–R5) and the escalation check.** If any of them stops you, stop before you edit anything. In auto mode, check **Auto mode: gap repair** before handing back.
6. **Mark the item `in-task`, then implement exactly this item** (see Rules). Before the first edit, run `node _mano/scripts/backlog.js task-status --title "<title>" --to in-task`; skip it only when the item is already `in-task`. The script refuses to move a `backlog` item anywhere else, so step 8 can't run without it.
7. **Verify.** Run every build, lint, type-check, and test command the project uses. Report each as pass or fail, and on failure only the first error, never the full output. If a failure's fix is inside this item's scope, fix it and re-run. Otherwise document the changes being kept under D3, report the failure, and leave the status alone.
8. **Document the changes through their owning skills (D3), then run all done gates (D1–D3) and write the status** with `node _mano/scripts/backlog.js task-status`. Never edit a status or `Check:` line by hand.
   - All gates pass → `--title "<title>" --to resolved`.
   - D2 and D3 pass and D1's only shortfall is a human-only part (see D1) → `--title "<title>" --to needs-human --check "<what the human should try, one line>"`.
   - Anything else → no status write; the item stays `in-task` and is reported as partial.
9. **Report** (see Output).

## Clarify before code

An item is clearly written when its outcome can be checked: what a user, test, or caller can see happen once it's done. A backlog item has no acceptance criteria, so this outcome stands in for them, and the done gates check against it.

**The check is the human's.** The outcome is the item's definition of done. When you write it from an item the human didn't write here, they only approve it, often without reading it, and what they actually meant shows up after the code. First reuse what the human has already supplied in their own words (defined below). A result they describe, what a user, test, or caller sees happen once it's done, is their check even if they did not label it one: don't ask for it again. Never ask for the action on its own. For new behaviour it is doing what the result describes, and for a bug it is the reproduction they gave, so the answer would only repeat them. Ask only when nothing in their own words says what they should see: a bare title, an item they didn't write here, or a request that names the work but not its result ("improve the search", "tidy up the export code"). Then show what the item asks for (its context, at most five lines) and ask:

> What will you do to check it works, and what should you see?

If the reproduction is already given and concrete questions about intended behaviour will supply the missing expected result, ask those questions only. Do not also ask the generic check question or ask them to restate the scenario. Combine the original scenario with their answers for the check, preserving their words. A report that cargo is lost does not decide where it should land: do not invent that result, even as an example answer. This is not a blanket exemption for bugs; unresolved behaviour still needs a decision before code. A question that depends on another answer should be conditional on that answer, not an independent required choice.

For example, “When I throw the full ball at a closing door, its cargo is lost” already supplies the reproduction. If the intended destination is unresolved, ask where the cargo should end up when the door closes during flight; do not also ask how they will verify the fix. If a side-of-door question matters only when the door blocks the cargo, make that dependency explicit.

Their own words are the request, their answers in this conversation, and the item's `Human check failed:` and `Human redirection:` lines. A title, or an item they didn't write here, is not. Ask once, in the same message as any other question. Every reply is complete: a check, or "just build it" / "as the item says", which means you build the outcome from the item and don't ask again. The question asks for something the item doesn't have, not for a yes, so it isn't the confirmation round ruled out below.

A check they give becomes part of the outcome, in their words: R1 builds on it, D1 needs evidence for each part of it, and a `needs-human` `Check:` line starts from it. Write it into the item as one context line, `Done when: <their words, on one line>`. When the check is a result they already described, `Done when:` quotes the sentence of theirs that states it, word for word (their goal line, when they wrote one), because the rest of the context condenses their request into your lines. If the context would pass five lines, shorten your own lines, never theirs. When the check covers more than the item, name the extra part and the item that already tracks it (`node _mano/scripts/state.js --titles --match "<its distinctive word>"`), and ask once: leave it out, or widen this item to include it? Widening is the human's call, and it never sends them to `mano start` on its own.

**One message carries everything.** When this step is going to ask the human anything, first read what R2–R5 check (`tech-spec.md`, `ux-flow.md`, `design-brief.md`, where they exist; not source) and run those gates against the outcome drafted so far. Put each stop in the same message as the questions, so the human sees every missing value, missing flow, and replacement at once instead of meeting a gate after answering. Step 5 still runs the gates in full.

❌ "Here's the outcome I'll build: the panel lists every result. Does that look right?" (asks for a yes)
❌ The request says "after saving, the new entry appears at the top of the list", and the reply asks "What will you do to check it works, and what should you see?" (their words already say what they'll see)
✅ "The item says: 'Show how many results the search found.' What will you do to check it works, and what should you see?"

**R1 — Write the outcome.** In one or two lines, write the observable outcome. Every part of it must come from the item's context, an artifact it names, or the human's words in this conversation, never from what you'd expect such a feature to do.

**For new work, draft the item first.** Title: short and specific. Type: `feature`, `bug`, `refinement`, `tech-debt`, or `test`, never a gap type. Context: at most 5 lines, built from the human's words; keep their phrasing where you can and add nothing they didn't say.

**Ask before writing when the outcome can't be grounded.** Ask the human when:

- a part of the outcome would be your guess: "make it feel better", "improve the inventory";
- the item names an open detail itself ("Open product detail: …", "TBD", a question);
- it uses a noun the item and artifacts never define ("the active ball", "the default view");
- it gives a short list that may be only examples, and the full set changes what gets built;
- it describes something that starts but never says what ends it or what happens at the edge: when the effect stops, what reverts, what happens on the floor, at zero, or when two happen at once.

Ask all your questions at once, numbered, one decision each, and only those whose answer changes what gets built. Ask *what* it does, never *how* it's built. These are not yours to ask:

- the stack, a library, storage, or architecture → `mano spec`;
- a number, duration, radius, or other default → R2 routes it to `mano spec`;
- how a player picks between options → R3 routes it to `mano ux`;
- anything the item already states. Don't re-open it.

When the item is already clear and the human's own words already say what they should see, ask nothing: no confirmation round and no "does this look right?".

❌ "Should the colour change use a shader or a material swap?" (how, belongs to `mano spec`)
❌ "Which shade of red?" (a value, belongs to `mano spec` via R2)
✅ "Does the ball stay coloured while it holds something, or flash once when the capture happens?"

**Write the item.** Once the outcome is grounded, which may be right away or after the human answers:

- new item → `node _mano/scripts/backlog.js add --title "<title>" --type <type> --source "mano task" --context "<context>"`. If it prints `SIMILAR`, carry that to the human as one `⚠ Verify:` line and continue.
- existing item whose context was missing what the answers supplied → `node _mano/scripts/backlog.js update --title "<title>" --context "<context>"`, keeping every existing line that still holds and adding the answers in the human's words.

Then continue to step 4 in the same turn. The human's answers are the approval, so there is no second confirmation. Never write the item and then stop to ask whether to implement it.

**Too big for one item** → don't clarify, escalate (see below). Questions are there to pin down one item, not to break a feature into many.

## Readiness gates — before any edit

A stop here means **no edits**: no source, no tests, no artifacts. The item keeps its status: `backlog`, or `in-task` when an earlier run started it. A new item added in step 3 stays in the backlog, which is where it should be. Name the gate, quote what's missing, and name the owning command with what it has to decide after the item title. An owner handed only a title has nothing to write. Do not write the gap into `backlog.md` yourself; the human decides whether to record it.

<!-- mirrors _mano/rules/implement.md 6.2 -->
**R2 — Spec-owned default gap.** If the item needs a starting state, first-use state, capacity, radius/range, count, duration, threshold, spawn amount, or other behaviour-driving default, the canonical spec must define its owner and authority under `_mano/rules/artifact.md` → **Parameter authority: contracts, tuning, and seeds**: an exact contractual value/relationship, or declared tuning with a configuration home, constraints, and an initialisation route. An existing tuning configuration or authorised seed/seed-selection rule satisfies this gate without a current numeric default in the spec. A vague phrase such as "small area" is not an implementation value. If it's missing, stop → `mano spec "[the item title]: [each missing value, named]"`. `mano spec` writes a directive like that into `tech-spec.md` with no phase and no backlog row. Do not choose a default yourself, add a temporary literal, or treat a test fixture as the product default.

<!-- mirrors _mano/rules/implement.md 6.3 -->
**R3 — Player-choice UX gap.** If the item lets a player choose among two or more simultaneously available tools, buildables, abilities, modes, rewards, or alternatives, `_mano_output/ux-flow.md` must define how the player invokes the choice, selects/changes the active option, sees that active state, and receives locked/unavailable/cancel feedback. If it doesn't, or the file doesn't exist, stop → `mano ux "[the item title]: [the choice that needs a flow]"`. Do not invent a hotkey, picker, cycling scheme, default active item, or HUD treatment.

<!-- mirrors _mano/rules/implement.md 7–9 -->
**R4 — Tech-spec pre-read.** If the item is setup, tooling, infrastructure, or dependency work, or involves user-entered or local data, read `_mano_output/tech-spec.md` first.
- Library choices, the package manager, and install commands there are normative. Run install commands exactly as written; don't merge, reorder, or switch tools.
- Never run a project generator against the project root, and never move, rename, or delete existing files to make room for one. If the item needs one and the tech spec has no guarded `node _mano/scripts/scaffold.js run ...` command for it, stop → `mano spec "[the item title]: scaffold command"`.
- If the tech spec says the data persists across restarts, restart persistence is part of R1's outcome, not an extra.
- If the item needs a stack decision the tech spec doesn't make (a new library, storage, or service), stop: escalate (see below).

**R5 — Contract contradiction.** An authorised tuning change that differs only from a non-normative seed is not a contradiction; changes to its constraints or promised outcome still are. If the R1 outcome needs the opposite of what `ux-flow.md`, `design-brief.md`, or a value in `tech-spec.md` states, stop. Both are the human's decisions, so which one stands is theirs to say: quote both and raise one `❓ Decide:`. The route writes the item's version into the owner's artifact as a replacement: `mano ui "<item title>: <the item's version, in its words> (replaces: <the artifact's statement>)"`, or `mano ux` / `mano spec` for their files. Running it is the answer. Build against neither version until the artifact agrees with the item. Any other contradiction with `tech-spec.md`, or one with `project-rules.md`, is an escalation (below).

When the item's version is the human's own words from this conversation (their request or their check), they have already said which one stands. Humans build by iteration: they ship the smallest version and widen its limits later, so replacing an earlier artifact decision is the normal next step, not a mistake. Raise no `❓ Decide:`. Show the stop as the replacement it is, quoting both, with the same route. Keep the `❓ Decide:` for an item whose version comes only from text the human hasn't restated, where either one may be the stale one.

❌ `Next: mano ui "Visible shield glow"` (a title gives the owner nothing to write)
✅ `Next: mano ui "Visible shield glow: the glow stays on for the whole immunity window (replaces: the shield shows only on a blocked hit)"`

## Escalate instead of implementing when

- the task requires a significant architecture decision
- requirements stay materially ambiguous after clarification
- implementation would affect multiple major systems
- the task conflicts with existing project rules
- completing it requires substantial work outside the backlog item

In those cases make no edits and leave the status as it is. Name the trigger in one line, then recommend creating a phase: `mano start` with this item.

## Auto mode: gap repair

When `state.js --task` reports `MODE: auto`, a readiness stop that routes to `mano spec`, `mano ux`, or `mano ui` doesn't wait for the human to type the route. Typing `mano task "<item>"` approved this one item, and auto mode runs the commands the human would otherwise type next: the owner's command, then this task again. It removes typing, not decisions.

**All of these must hold:**

- `state.js --task` reported `MODE: auto` in this run, and nothing is pending: no unanswered clarify question, no script failure, no stop from the human.
- The stop is R2, R3, or R4's missing scaffold command, or R5 once the human has chosen the item's version: by answering its `❓ Decide:` for the item, or by stating that version in their own words in this conversation, which raises no `❓ Decide:`. An R5 `❓ Decide:` always pauses for its answer first; an answer for the artifact ends the run with the item untouched. An escalation (R4's stack decision included), a gap-type item, a done gate, and a failing check never chain. Their next step is `mano start`, a decision, or a fix, and those belong to the human.
- The item is written in `backlog.md` with its R1 outcome. The owner supplies a value, a flow, or a treatment, never the outcome.
- This run hasn't already run that owner. One attempt per owner per run.

**If eligible, in this same turn:**

1. Print the stop's `Why:` line and the owner command you're inserting as this action's log, with no `Next:` block. The item keeps its status: nothing has been edited, so don't mark it `in-task`.
2. Run exactly the command the manual `Next:` would have printed (`mano spec "<item title>: <each missing value, named>"`, `mano ux "<item title>: <the choice that needs a flow>"`, or R5's replacement), loading that skill's own contract and required rules. It keeps its own questions, `❓ Decide:` lines, and hook triage. The ban on editing `tech-spec.md`, `ux-flow.md`, and `design-brief.md` binds `mano task`, not the owner.
3. Once the owner and its hook triage finish, re-run `node _mano/scripts/state.js --task`. If `MODE` is now `manual`, or the human said stop, hand back with `Next: mano task "<item title>"`. Otherwise resume this item at step 4: reread what the owner changed, then run R2–R5 in full again before any edit.

**Pause instead** when the owner asks a question or raises `❓ Decide:`, routes the request somewhere else instead of writing it, or fails, and when the rerun gates stop again on an owner this run already ran. Print the chain's closing block (see Output) and wait. The human's answer resumes the chain in the same turn.

Apart from the mandatory documentation handoff in D3, nothing else chains. A finished task never chains into another one, and the chain never runs `mano start` or closes a `needs-human` item. Picking what to build next is the human's call.

A task chain keeps no `chain.js` record, because a task has no phase. The item in `backlog.md` is its durable state: if a session reset cuts the chain, `mano task "<item title>"` picks it up, and whatever the owner already wrote stays in its artifact.

## Rules

- Implement exactly one backlog item, and only after it is written in `backlog.md`.
- Read existing project context before implementation.
- Do not create a phase brief, stories, or a `progress.md` ledger.
- Do not edit `tech-spec.md`, `project-rules.md`, `ux-flow.md`, or `design-brief.md` directly as `mano task`. Invoke their owning skills to document implemented changes under D3; missing or conflicting decisions before implementation still follow the readiness gates.
- Do not expand the scope of the backlog item.
- Do not implement adjacent backlog items, even when they touch the same code.
- Do not introduce new architecture unless the item requires it.
- Do not add dependencies unless the item requires them.
- Follow existing architecture and project rules.
- Run relevant tests/checks. For declared tuning, use explicit fixture parameters for behaviour tests and check configuration wiring/overrides separately. Never assert that a non-normative seed must remain the current default. Retain checks of real configured outcomes where they protect a product promise.
- Report anything discovered that belongs in another backlog item. Report it only. Do not add it to `backlog.md` unless the user approves; once they do, use `node _mano/scripts/backlog.js add`.

## Done gates — before the status may change

A failure here leaves the status `in-task` and is reported. Keep the edits, and say they're partial.

<!-- mirrors _mano/rules/implement.md 10.1 -->
**D1 — Outcome evidence.** Reread the outcome you wrote for R1. For every part of it, point to concrete evidence from this turn (a test that exercises it, or a manual/runtime check you ran) showing the outcome happens through the route the item describes. A green suite is not enough if nothing in it exercises the outcome. Any assertion, fixture, comment, skipped test, or observed result that says the opposite (success expected as failure, available expected as unavailable) proves the item is **not done**, even if everything passes. If current code or an artifact deliberately keeps the opposite behaviour, stop and report the contradiction; do not invert the test or reword the outcome to match. If a visual or experiential part can't be checked, don't resolve: when every other part has evidence, the item becomes `needs-human`.

**`needs-human` is a handoff, not an escape hatch.** Use it only when every part of the outcome you *can* exercise has evidence from this turn, and what's left is inherently visual, experiential, or otherwise impossible for you to check honestly (how it looks, how it feels, a device you don't have). It is never for a missing test you could have written, a tool you didn't try, a failed check, or a contradiction. Those leave the status `in-task` and report the item as partial. The `Check:` line names one thing the human does and what they should see. When the item has a `Done when:` line, start from it, in the human's words, and keep only the part this turn couldn't verify.

<!-- mirrors _mano/rules/implement.md 10.2 -->
**D2 — Design-contract conformance.** If the item produced or changed a user-visible surface and `_mano_output/design-brief.md` names components for that surface, confirm from **this turn's edits** that the surface uses each named one: its name, or the file that defines it, appears in what you wrote. A shared theme, matching colour, copied style, or hand-built lookalike is not the component. A missing one means not done.

## Document implemented changes

**D3 — Documentation through the owner.** Every task that changes implementation must document what changed before becoming `resolved` or `needs-human`, including work resumed from `in-task`. This is part of completing the requested task in **both manual and auto mode**, not an optional next step. Never say “run `mano spec` if you want this documented.”

For an authorised tuning-only change, verify the existing delegation and constraints locally and report `Documented: existing tuning delegation verified; no artifact change`. Do not invoke an artifact owner merely to synchronise its seed. Changes to meaning, ownership, constraints, or promised outcomes still need documentation.

Compare the other actual changes with the canonical artifacts and invoke the relevant owner with a concrete, bounded account of the implemented result:

- `mano spec` → technical contracts, layers and their responsibilities (for example a new Player layer), data models, dependencies, and behaviour-driving values.
- `mano rules` → project conventions and file-structure rules.
- `mano ux` → user actions, flows, feedback, and recovery.
- `mano ui` → visual treatments and component decisions.

Load each selected skill's contract and required rules and execute it in this turn. Pass the item title, grounded outcome, exact implemented changes, relevant declarations/values, and affected artifact sections as **task documentation sync** context. This supplies the no-phase context; a title alone is insufficient. Document only this item's changes, and keep implementation detail out of artifacts that do not own it. If existing documentation already covers the result (such as a bug fix restoring the documented behavior), invoke the relevant owner to verify coverage; report its no-change finding rather than manufacturing an artifact edit.

Return to this task after each owner and its hooks finish; do not follow its unrelated `Next:` suggestions. The readiness repair's once-per-owner limit does not prevent this post-implementation sync. Preserve owner questions and conflicts: if an owner cannot finish, leave the item `in-task`, report the documentation blocker, and resume it after the answer. Documentation cannot ratify a readiness violation after the fact. If verification failed, still sync the changes being kept when possible, explicitly describing them as partial rather than promising a completed outcome.

Reread the affected sections to confirm they match the implementation. In the final task log include `Documented: <owner → artifact and sections updated, or coverage verified with no edit>`. A suggested command or an unsupported claim of documentation does not pass D3.

## Closing a `needs-human` item

The human answers the `Check:` line, either by replying in this conversation or by running `mano task "<title>"` again later. Don't re-implement and don't re-run the gates. Every write goes through `backlog.js task-status`, which refuses any other move.

- **No answer yet** (a bare re-run): print the item's `Check:` line and ask once: works, broken, or do you want it different?
- **Works** → `--to resolved`. The `Check:` line stays on the item as the record of how it was verified.
- **Broken: \<what\>** → `--to backlog --failed "<their words, verbatim>"`.
- **Works, but I want it different: \<what\>** → `--to backlog --redirect "<their words, verbatim>"`. This is a new outcome, not a fix, so the next run clarifies it again before any code.
- **Didn't check** → no write; it stays `needs-human`.

After `broken` or a redirect, hand back with `Next: mano task "<title>"`. The next run starts from the human's words now in the item's context.

## Output

```
[mano task]: <item title> → resolved
Outcome: <the R1 outcome, one line>
Changed: <files>
Checks: <command — pass, one per line>
Discovered (not added): <one line each, or "none">
```

Add `Added: <title> (new backlog item)` or `Updated: <title> (context)` under the first line when step 3 wrote the item.

When the item needs clarification (nothing written):

```
[mano task]: <item title or "new item"> — needs clarification
The item says: <its context, at most five lines — omit for new work drafted from the human's words>
Outcome so far: <the parts already grounded, one line>
1. What will you do to check it works, and what should you see?   ← only when their words don't say what they'll see yet
2. <question>
Before code: <each stop R2–R5 already found: the missing value or flow, or "<item's version> (replaces: <statement>)" — omit when none>
❓ Decide: <R5 on item text the human hasn't restated only: keep the artifact's version, or replace it with the item's?>
```

When the gate refuses (nothing written):

```
[mano task]: refused — <OPEN_PHASE> is open
Why: <REASON, one line>
Next: <the command REASON names for that phase>
```

When a readiness gate stops or escalation fires (no edits made):

```
[mano task]: <item title> — not implemented
Why: <R2/R3/R4/R5 or escalation trigger> — <what's missing, or both statements for R5, one line>
❓ Decide: <R5 on item text the human hasn't restated only: keep the artifact's version, or replace it with the item's?>
Next: <mano start | mano spec "<item>: <what's missing>" | mano ux "<item>: <what's missing>" | R5: mano <ux|ui|spec> "<item>: <item's version> (replaces: <statement>)">
```

When the only gap is a human-only check (D1, `needs-human`):

```
[mano task]: <item title> → needs-human
Outcome: <the R1 outcome, one line>
Changed: <files>
Checks: <command — pass, one per line>
Check: <what to try, one line> — reply "works", what's broken, or how you want it different
```

When a done gate or verification fails (edits kept, status unchanged):

```
[mano task]: <item title> — partial, still in-task
Why: <D1/D2/D3 or failing check> — <one line>
Changed: <files>
Next: mano task "<item title>" to finish it
```

When an auto-mode run inserted an owner (see **Auto mode: gap repair**), add one closing block after the last action's own log. A run that inserted none ends at its own block.

```
[mano auto]: task "<item title>" — <first action> → … → <last action>
- Ran: <actions, in order>
- Stopped: <resolved | needs-human, check above | partial, still in-task | waiting on the question above | <gate>, not repairable>
- Remaining: task "<item title>" — omit when none
⚠ Verify: <every advisory flag collected across the run, one per line — omit if none>

Next: <the final block's Next:, or reply to the question above — the task resumes automatically>
```
