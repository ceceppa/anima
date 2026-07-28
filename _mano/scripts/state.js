#!/usr/bin/env node
"use strict";

/**
 * mano state — a read-only projection of a project's _mano_output/ state.
 *
 * Replaces the in-prompt file-scanning `mano start` does to decide its path.
 * The agent runs this once and reads a deterministic verdict instead of
 * grepping the backlog / stories index / reviews by hand (which is unreliable —
 * the backlog Status line is `- **Status:** backlog`, and bare `grep "Status:
 * backlog"` misses it).
 *
 * IMPORTANT — this script is a *projection*, not a source of truth. It only
 * reads. It must never write a "current phase" or any state file: the
 * filesystem under _mano_output/ stays the single source of truth. The verdict
 * is a projection consumed by the skill. Human decisions resolve the condition
 * it reports (for example by closing or repairing a phase); the script never
 * changes state or silently advances past a gate.
 *
 * Usage:
 *   node state.js                 scan ./_mano_output
 *   node state.js <projectRoot>   scan <projectRoot>/_mano_output
 *   node state.js --scope         on a PROCEED to scope-backlog or resume-draft,
 *                                 also print the relevant backlog items,
 *                                 principles, and latest review
 *   node state.js --next          for mano dev: the active phase + next pending
 *                                 story (#, file) + ordered story list, so the
 *                                 implementer needn't ls or reopen the index
 *   node state.js --json          machine-readable output
 *   node state.js --help
 *
 * Exit code is always 0 on a successful scan (including "no project") — a
 * verdict is data, not a failure. Non-zero only on an unexpected I/O error.
 */

const fs = require("node:fs");
const path = require("node:path");

function parseArgs(argv) {
  const args = { root: process.cwd(), json: false, verbose: false, scope: false, next: false, help: false };
  for (const a of argv) {
    if (a === "--json") args.json = true;
    else if (a === "--verbose" || a === "-v") args.verbose = true;
    else if (a === "--scope") args.scope = true;
    else if (a === "--next") args.next = true;
    else if (a === "--help" || a === "-h") args.help = true;
    else if (!a.startsWith("-")) args.root = path.resolve(a);
  }
  return args;
}

const HELP = `mano state — read-only projection of _mano_output/ for mano start / mano dev

Usage:
  node state.js [projectRoot] [--scope | --next] [--verbose] [--json]

  projectRoot   directory containing _mano_output/ (default: current dir)
  --scope       on a PROCEED to scope-backlog or resume-draft, also print the
                relevant backlog items, core principles, and latest review
  --next        for mano dev: the active phase, the next pending story (its #
                and file path) and the ordered story list, computed fresh from
                disk so the implementer needn't ls or reopen the index
  --verbose     also print the evidence (phase, stories, reviewed, backlog)
  --json        emit the full structured state as JSON

By default prints a go/no-go for mano start: a DECISION (PROCEED | STOP), a
NEXT hint when proceeding (scope-backlog | conversation | resume-draft), a PHASE
number (the phase to scope or resume, so the skill needn't ls for it), and a
one-line reason. Run with --verbose to see why. Read-only: writes nothing.`;

// ---- small fs helpers (never throw on missing) ----------------------------

function exists(p) {
  try { return fs.existsSync(p); } catch { return false; }
}

function readText(p) {
  try { return fs.readFileSync(p, "utf8"); } catch { return null; }
}

function listDirs(p) {
  try {
    return fs.readdirSync(p, { withFileTypes: true })
      .filter((e) => e.isDirectory())
      .map((e) => e.name);
  } catch { return []; }
}

// ---- parsers (one per format, kept tiny and faithful) ---------------------

// Highest-numbered phase-[N] folder. Returns null if none.
function latestPhase(outputDir) {
  let max = null;
  for (const name of listDirs(outputDir)) {
    const m = /^phase-(\d+)$/.exec(name);
    if (m) {
      const n = Number(m[1]);
      if (max === null || n > max) max = n;
    }
  }
  return max;
}

// Stories index: | # | Story | File | Status |. A row counts as a story when
// its first cell is a story number — an integer or a sub-row like 3a. Returns
// { total, done, openTitles, rows } or null if the index is absent. `rows` is
// every story row in file order ({ num, title, file, status }) — the ordered
// list mano dev needs to pick the next pending story and honour story order.
function readStories(storiesReadme) {
  const text = readText(storiesReadme);
  if (text === null) return null;
  const rows = [];
  for (const line of text.split("\n")) {
    if (!line.includes("|")) continue;
    const cells = line.split("|").map((c) => c.trim());
    // Drop leading/trailing empties from the outer pipes.
    while (cells.length && cells[0] === "") cells.shift();
    while (cells.length && cells[cells.length - 1] === "") cells.pop();
    if (cells.length < 4) continue;
    if (!/^\d+[a-z]*$/i.test(cells[0])) continue; // header / separator / non-story row (allows sub-rows like 3a)
    rows.push({
      num: cells[0],
      title: cells[1],
      file: cells[2],
      status: cells[cells.length - 1].toLowerCase(),
    });
  }
  let total = 0, done = 0;
  const openTitles = [];
  for (const r of rows) {
    total++;
    if (r.status === "done") done++;
    else openTitles.push(`${r.num} ${r.title} (${r.status || "—"})`);
  }
  return { total, done, openTitles, rows };
}

// Backlog Status counts. Matches `- **Status:** <value>` exactly (the format
// that bare greps miss). Takes the file's text; returns counts keyed by raw
// status value ({} when the backlog is absent).
function countBacklogStatuses(text) {
  const counts = {}; // e.g. { backlog: 1, "in-phase-8": 0, resolved: 24 }
  if (text === null) return counts;
  const re = /^\s*-\s*\*\*Status:\*\*\s*(.+?)\s*$/gim;
  let m;
  while ((m = re.exec(text)) !== null) {
    const v = m[1].trim().toLowerCase();
    counts[v] = (counts[v] || 0) + 1;
  }
  return counts;
}

// Backlog items are `### title` blocks, each carrying a `- **Status:** <value>`
// line. Returns the full text block of every item whose status matches
// `wantStatus` (e.g. "backlog"), in file order. A `##` heading (e.g. the
// Core Product Principles section) ends the preceding item.
function extractBacklogItems(text, wantStatus) {
  if (text === null) return [];
  const out = [];
  let cur = null; // { lines: [] }
  const flush = () => {
    if (!cur) return;
    const block = cur.lines.join("\n").replace(/\s+$/, "");
    const m = /^\s*-\s*\*\*Status:\*\*\s*(.+?)\s*$/im.exec(block);
    const status = m ? m[1].trim().toLowerCase() : null;
    if (!wantStatus || status === wantStatus) out.push(block);
    cur = null;
  };
  for (const line of text.split("\n")) {
    if (/^###\s+/.test(line)) { flush(); cur = { lines: [line] }; }
    else if (/^##\s+/.test(line)) { flush(); }   // a higher heading ends an item
    else if (cur) cur.lines.push(line);
  }
  flush();
  return out;
}

// The `## Core Product Principles` section (heading + body up to the next `##`
// heading), or null if absent.
function extractCoreProductPrinciples(text) {
  if (text === null) return null;
  let out = null;
  for (const line of text.split("\n")) {
    if (out === null) {
      if (/^##\s+Core Product Principles\b/i.test(line)) out = [line];
    } else if (/^##\s+/.test(line)) {
      break; // next section
    } else {
      out.push(line);
    }
  }
  return out ? out.join("\n").replace(/\s+$/, "") : null;
}

// The latest `## Phase N Review` section's text. Prefers the section for phase
// `n` (the phase just closed); falls back to the highest-numbered review.
// null when reviews.md has none.
function extractLatestReview(text, n) {
  if (text === null) return null;
  const heading = /^##\s+Phase\s+(\d+)\s+Review\b/i;
  const sections = [];
  let cur = null;
  for (const line of text.split("\n")) {
    const m = heading.exec(line);
    if (m) { if (cur) sections.push(cur); cur = { phase: Number(m[1]), lines: [line] }; }
    else if (cur) {
      if (/^##\s+/.test(line)) { sections.push(cur); cur = null; } // non-review h2 ends it
      else cur.lines.push(line);
    }
  }
  if (cur) sections.push(cur);
  if (sections.length === 0) return null;
  let pick = n !== null ? sections.find((sec) => sec.phase === n) : null;
  if (!pick) pick = sections.reduce((a, b) => (b.phase >= a.phase ? b : a));
  return pick.lines.join("\n").replace(/\s+$/, "");
}

// True if reviews.md text has a `## Phase N Review` heading.
function hasReviewEntry(text, n) {
  if (text === null) return false;
  const re = new RegExp(`^##\\s+Phase\\s+${n}\\s+Review\\b`, "im");
  return re.test(text);
}

// ---- state assembly -------------------------------------------------------

function scan(projectRoot) {
  const outputDir = path.join(projectRoot, "_mano_output");
  const s = {
    projectRoot,
    outputDir,
    outputExists: exists(outputDir),
    phase: null,            // latest phase number, or null
    briefExists: false,
    stories: null,          // { total, done, openTitles } or null
    reviewEntry: false,
    backlog: null,          // status counts, or null
    backlogItems: 0,        // Status: backlog count
    inPhaseRemaining: 0,    // Status: in-phase-<phase> count
    _backlogText: null,     // raw text, kept for scope extraction; not serialized
    _reviewsText: null,
  };

  if (!s.outputExists) return finalize(s);

  s._backlogText = readText(path.join(outputDir, "backlog.md"));
  s._reviewsText = readText(path.join(outputDir, "reviews.md"));
  s.backlog = countBacklogStatuses(s._backlogText);
  s.backlogItems = s.backlog["backlog"] || 0;

  const n = latestPhase(outputDir);
  s.phase = n;

  if (n !== null) {
    const phaseDir = path.join(outputDir, `phase-${n}`);
    s.briefExists = exists(path.join(phaseDir, "phase-brief.md"));
    s.stories = readStories(path.join(phaseDir, "stories", "README.md"));
    s.reviewEntry = hasReviewEntry(s._reviewsText, n);
    s.inPhaseRemaining = s.backlog[`in-phase-${n}`] || 0;
  }

  return finalize(s);
}

// Derive the verdict from raw signals, faithful to mano start's gate.
function finalize(s) {
  const storiesAllDone = !!(s.stories && s.stories.total > 0 && s.stories.done === s.stories.total);
  const storiesMissing = !s.stories || s.stories.total === 0;
  // Gate condition 3: reviewed/closed — review is mandatory, and its close sweep
  // must have moved every item for this phase off `in-phase-<N>`.
  const closed = s.reviewEntry && s.inPhaseRemaining === 0;

  let verdict, action;

  if (!s.outputExists) {
    verdict = "NEW_PROJECT";
    action = "No project yet. mano start takes Path B (conversation) — or run `mano import <doc>` first if a PRD/document exists, then Path A.";
  } else if (s.phase === null) {
    // Output dir exists but no phase folder (e.g. fresh `mano import`).
    if (s.backlogItems > 0) {
      verdict = "READY_FIRST_PHASE";
      action = `Backlog has ${s.backlogItems} item(s) and no phase exists yet. mano start scopes phase 1 (Path A).`;
    } else {
      verdict = "NEW_PROJECT";
      action = "An _mano_output/ scaffold exists but the backlog is empty and no phase started. mano start takes Path B (conversation), or `mano import <doc>` to populate the backlog first.";
    }
  } else if (!s.briefExists) {
    // Edge case: phase folder without a brief — a prior start didn't finalise.
    verdict = "RESUME_DRAFT";
    action = `phase-${s.phase}/ exists without phase-brief.md — a previous mano start didn't finalise. Resume drafting phase ${s.phase}; do NOT start a new phase.`;
  } else if (storiesMissing) {
    verdict = "PHASE_IN_PROGRESS";
    action = `Phase ${s.phase} has a brief but no stories yet. Not complete — run mano stories. mano start must NOT scope a next phase.`;
  } else if (!storiesAllDone) {
    verdict = "PHASE_IN_PROGRESS";
    action = `Phase ${s.phase} has open stories (${s.stories.done}/${s.stories.total} done). Not complete — run mano dev. mano start must NOT scope a next phase.`;
  } else if (!closed) {
    verdict = "PHASE_BUILT_NOT_CLOSED";
    const blockers = [];
    if (!s.reviewEntry) blockers.push("no review entry");
    if (s.inPhaseRemaining > 0) blockers.push(`${s.inPhaseRemaining} item(s) still in-phase-${s.phase}`);
    const repair = s.reviewEntry
      ? "The review entry exists but its backlog close sweep is incomplete — re-run mano review to repair it."
      : "Run mano review.";
    action = `Phase ${s.phase} is built (stories all done) but not closed — ${blockers.join("; ")}. ${repair} mano start must NOT scope a next phase.`;
  } else {
    // Phase complete.
    if (s.backlogItems > 0) {
      verdict = "READY_NEXT_PHASE";
      action = `Phase ${s.phase} is complete. mano start may scope phase ${s.phase + 1} from the ${s.backlogItems} backlog item(s) (Path A).`;
    } else {
      verdict = "COMPLETE_BACKLOG_EMPTY";
      action = `Phase ${s.phase} is complete and no items have Status: backlog. Nothing to scope — add backlog items (or mano import a doc) before mano start.`;
    }
  }

  // Collapse the verdict to the only thing mano start branches on: go/no-go,
  // plus which path to take when going. The verdict + evidence remain for the
  // human (and --json), but the skill consumes just decision + next.
  const NEXT_BY_VERDICT = {
    READY_FIRST_PHASE: "scope-backlog",
    READY_NEXT_PHASE: "scope-backlog",
    RESUME_DRAFT: "resume-draft",
    NEW_PROJECT: "conversation",
  };
  const proceeds = Object.prototype.hasOwnProperty.call(NEXT_BY_VERDICT, verdict);

  s.storiesAllDone = storiesAllDone;
  s.closed = closed;
  s.verdict = verdict;
  s.action = action;
  s.decision = proceeds ? "PROCEED" : "STOP";
  s.next = proceeds ? NEXT_BY_VERDICT[verdict] : null;

  // The phase folder mano start will create or finish, so the skill needn't ls
  // to re-derive it at finalisation. scope-backlog opens the next phase;
  // resume-draft finishes the current one.
  if (s.next === "scope-backlog") s.targetPhase = (s.phase || 0) + 1;
  else if (s.next === "resume-draft") s.targetPhase = s.phase;
  else s.targetPhase = null;

  // Attach the exact material mano start needs so the skill never has to reopen
  // backlog.md / reviews.md itself. A resume-draft includes every item because
  // an interrupted finalisation may have stopped before assignment recorded the
  // approved subset; the human must confirm that subset again.
  s.scope = null;
  if (s.next === "scope-backlog") {
    s.scope = {
      mode: "scope-backlog",
      coreProductPrinciples: extractCoreProductPrinciples(s._backlogText),
      backlogItems: extractBacklogItems(s._backlogText, "backlog"),
      latestReview: extractLatestReview(s._reviewsText, s.phase),
    };
  } else if (s.next === "resume-draft") {
    s.scope = {
      mode: "resume-draft",
      coreProductPrinciples: extractCoreProductPrinciples(s._backlogText),
      backlogItems: extractBacklogItems(s._backlogText, null),
      latestReview: extractLatestReview(s._reviewsText, s.phase),
    };
  }
  return s;
}

// ---- rendering ------------------------------------------------------------

// Default output: the go/no-go the skill acts on. Three lines, nothing more.
function renderDecision(s) {
  const L = [];
  L.push(`DECISION: ${s.decision}`);
  if (s.next) L.push(`NEXT: ${s.next}`);
  if (s.targetPhase != null) L.push(`PHASE: ${s.targetPhase}`);
  L.push(s.action);
  return L.join("\n");
}

// The "why", printed only with --verbose. The skill never needs this; the
// human does, when they want to expand the decision.
function renderEvidence(s) {
  const L = [];
  L.push("mano · project state");
  L.push(`root: ${s.projectRoot}` + (s.outputExists ? "  (_mano_output/ found)" : "  (no _mano_output/)"));
  L.push("");

  if (s.outputExists && s.phase !== null) {
    L.push(`latest phase: ${s.phase}`);
    L.push(`  phase-brief.md:        ${s.briefExists ? "present" : "MISSING"}`);
    if (s.stories) {
      L.push(`  stories:               ${s.stories.done}/${s.stories.total} done`);
      if (s.stories.openTitles.length) {
        for (const t of s.stories.openTitles) L.push(`                           open: ${t}`);
      }
    } else {
      L.push(`  stories:               none (no stories/README.md)`);
    }
    L.push(`  reviewed (reviews.md): ${s.reviewEntry ? "yes" : "no"}`);
    L.push(`  in-phase-${s.phase} items:      ${s.inPhaseRemaining} remaining`);
    L.push("");
  }

  if (s.outputExists) {
    const b = s.backlog || {};
    const keys = Object.keys(b).sort();
    L.push("backlog status counts:");
    if (keys.length === 0) L.push("  (no items)");
    for (const k of keys) L.push(`  ${k}: ${b[k]}`);
    L.push("");
  }

  L.push(`detail: ${s.verdict}`);
  return L.join("\n");
}

// The scope input the skill consumes on a PROCEED to scope-backlog: the exact
// Status: backlog items + core principles + latest review, so it needn't reopen
// any file. Empty string when there's no scope payload.
function renderScope(s) {
  if (!s.scope) return "";
  const L = ["--- SCOPE INPUT (from the state script — do NOT reopen these files) ---"];
  if (s.scope.coreProductPrinciples) {
    L.push("");
    L.push(s.scope.coreProductPrinciples);
  }
  L.push("");
  const itemLabel = s.scope.mode === "resume-draft" ? "all statuses" : "Status: backlog";
  L.push(`## Backlog items — ${itemLabel} (${s.scope.backlogItems.length})`);
  if (s.scope.backlogItems.length === 0) {
    L.push("(none)");
  } else {
    for (const item of s.scope.backlogItems) {
      L.push("");
      L.push(item);
    }
  }
  L.push("");
  L.push("## Latest review");
  L.push(s.scope.latestReview || "(none)");
  return L.join("\n");
}

// The mano dev projection: what to implement right now, computed fresh from
// disk. Surfaces the active phase, the FIRST pending story (in file order) with
// its file path, and the ordered story list — so the implementer needn't ls for
// the phase or reopen the index, and can't be fooled by a stale phase carried in
// the chat. It only *reports* the next pending row; it never decides to skip an
// earlier pending one (that bypass stays the user's call — AGENTS.md step 5).
function renderNext(s) {
  const L = [];

  // Nothing to implement: no project / no phase folder.
  if (!s.outputExists || s.phase === null) {
    L.push("DEV: no phase started — nothing to implement.");
    L.push("Run mano start to scope a phase (or mano import a doc to populate the backlog first). Do NOT invent work.");
    return L.join("\n");
  }
  // Phase exists but isn't ready for dev — point at the skill that owns the gap.
  if (!s.briefExists) {
    L.push(`DEV: phase ${s.phase} draft is unfinished — no phase-brief.md. Finish mano start. Nothing for mano dev yet.`);
    L.push(`PHASE: ${s.phase}`);
    return L.join("\n");
  }
  if (!s.stories || s.stories.total === 0) {
    L.push(`DEV: phase ${s.phase} has a brief but no stories yet — run mano stories. Nothing for mano dev yet.`);
    L.push(`PHASE: ${s.phase}`);
    return L.join("\n");
  }

  const next = s.stories.rows.find((r) => r.status !== "done") || null;
  if (!next) {
    L.push(`DEV: phase ${s.phase} — nothing to implement.`);
    L.push(`PHASE: ${s.phase}`);
    L.push(`All ${s.stories.total} stories are done. The phase is built but NOT closed — run mano review. Do NOT scope or start a new phase before review closes this one.`);
  } else {
    L.push(`DEV: phase ${s.phase} — next pending story.`);
    L.push(`PHASE: ${s.phase}`);
    L.push(`STORY: ${next.num}`);
    L.push(`FILE: _mano_output/phase-${s.phase}/stories/${next.file}`);
    L.push("Read that story file first, then follow AGENTS.md steps 6-10 for any required tech-spec or project-rules context; implement only its acceptance criteria; then mark it done via stories.js set-status (step 11).");
  }

  // The ordered list, so honouring story order (AGENTS.md steps 4-5) for a
  // user-named story needs no index reopen. `→` marks the next pending row.
  L.push("");
  L.push("Stories (Status is the only signal; → = next pending):");
  for (const r of s.stories.rows) {
    const mark = next && r.num === next.num ? "→" : " ";
    L.push(`${mark} ${r.num.padEnd(3)} ${r.status.padEnd(8)} ${r.title}`);
  }
  return L.join("\n");
}

function renderJson(s) {
  return JSON.stringify({
    projectRoot: s.projectRoot,
    outputExists: s.outputExists,
    phase: s.phase,
    briefExists: s.briefExists,
    stories: s.stories,
    storiesAllDone: s.storiesAllDone,
    reviewEntry: s.reviewEntry,
    inPhaseRemaining: s.inPhaseRemaining,
    backlog: s.backlog,
    backlogItems: s.backlogItems,
    closed: s.closed,
    decision: s.decision,
    next: s.next,
    targetPhase: s.targetPhase,
    verdict: s.verdict,
    action: s.action,
    scope: s.scope,
  }, null, 2);
}

// ---- main -----------------------------------------------------------------

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(HELP + "\n");
    process.exit(0);
  }
  const s = scan(args.root);
  let out;
  if (args.json) {
    out = renderJson(s);
  } else if (args.next) {
    out = renderNext(s);
    if (args.verbose) out += "\n\n" + renderEvidence(s);
  } else {
    out = renderDecision(s);
    if (args.scope && s.scope) out += "\n\n" + renderScope(s);
    if (args.verbose) out += "\n\n" + renderEvidence(s);
  }
  process.stdout.write(out + "\n");
  process.exit(0);
}

main();
