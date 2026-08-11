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
 *   node state.js --ui            for mano ui: the active phase's exact brief
 *                                 and phase-local preview paths
 *   node state.js --current       exact owner-scoped phase identity and paths
 *                                 for planning skills such as stories/review
 *   node state.js --spec          for mano spec: print current-phase source
 *                                 items plus open spec-gap items
 *   node state.js --gaps <type>   narrow gap-only diagnostic projection for
 *                                 spec-gap or rule-gap backlog items
 *   node state.js --json          machine-readable output
 *   node state.js --help
 *
 * Exit code is always 0 on a successful scan (including "no project") — a
 * verdict is data, not a failure. Non-zero only on an unexpected I/O error.
 */

const fs = require("node:fs");
const path = require("node:path");
const {
  phaseRef,
  phaseRouting,
  resolveConfiguredMode,
  reviewHeadingPattern,
} = require("./phase.js");

const GAP_TYPES = ["spec-gap", "rule-gap"];

function parseArgs(argv) {
  const args = {
    root: process.cwd(), json: false, verbose: false,
    scope: false, next: false, ui: false, current: false,
    spec: false, gaps: null, help: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--json") args.json = true;
    else if (a === "--verbose" || a === "-v") args.verbose = true;
    else if (a === "--scope") args.scope = true;
    else if (a === "--next") args.next = true;
    else if (a === "--ui") args.ui = true;
    else if (a === "--current") args.current = true;
    else if (a === "--spec") args.spec = true;
    else if (a === "--gaps") {
      const candidate = argv[i + 1];
      if (candidate == null || candidate.startsWith("-")) args.gaps = "";
      else { args.gaps = candidate; i++; }
    }
    else if (a === "--help" || a === "-h") args.help = true;
    else if (!a.startsWith("-")) args.root = path.resolve(a);
  }
  return args;
}

const HELP = `mano state — read-only projections of _mano_output/

Usage:
  node state.js [projectRoot] [--scope | --next | --ui | --current | --spec | --gaps <type>] [--verbose] [--json]

  projectRoot   directory containing _mano_output/ (default: current dir)
  --scope       on a PROCEED to scope-backlog or resume-draft, also print the
                relevant backlog items, core principles, and latest review
  --next        for mano dev: the active phase, the next pending story (its #
                and file path) and the ordered story list, computed fresh from
                disk so the implementer needn't ls or reopen the index
  --ui          for mano ui: report the current phase brief and phase-local
                design preview paths without exposing backlog content or
                scanning phase folders in the prompt
  --current     report the configured owner and exact current phase identity,
                directory, brief, stories index, backlog status, and review
                heading without exposing artifact contents
  --spec        for mano spec: report the current phase brief path, exact
                in-phase-N backlog items, and open spec-gap items without
                exposing the rest of backlog.md
  --gaps <type> read only backlog.md and print unresolved items of exact type
                spec-gap or rule-gap (mano rules uses the rule-gap projection)
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

// Gap projection distinguishes an absent backlog (a valid empty result before
// any phase exists) from a real read failure. --spec additionally rejects an
// absent backlog once a phase exists. Reporting either condition as empty in an
// active phase would make an incomplete projection look authoritative.
function readGapText(p) {
  try {
    return fs.readFileSync(p, "utf8");
  } catch (error) {
    if (error && error.code === "ENOENT") return null;
    throw error;
  }
}

// ---- parsers (one per format, kept tiny and faithful) ---------------------

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
  let inItems = false;
  for (const line of text.split("\n")) {
    if (/^##\s+Items\s*$/i.test(line)) {
      inItems = true;
      continue;
    }
    if (/^##\s+/.test(line)) {
      inItems = false;
      continue;
    }
    if (!inItems) continue;
    const match = /^-\s*\*\*Status:\*\*\s*(.+?)\s*$/i.exec(line);
    if (match) {
      const value = match[1].trim().toLowerCase();
      counts[value] = (counts[value] || 0) + 1;
    }
  }
  return counts;
}

// Backlog items are `### title` blocks, each carrying a `- **Status:** <value>`
// and `- **Type:** <value>` line. Returns the full text block of every item
// matching the requested exact status/type filters, in file order. Only `###`
// blocks under `## Items` count as backlog items; headings in Core Product
// Principles or other sections are never exposed.
function extractBacklogItems(text, options = {}) {
  if (text === null) return [];
  const wantStatus = options.status ? options.status.toLowerCase() : null;
  const wantType = options.type ? options.type.toLowerCase() : null;
  const excludeTypes = new Set((options.excludeTypes || []).map((t) => t.toLowerCase()));
  const out = [];
  let cur = null; // { lines: [] }
  let inItems = false;
  const flush = () => {
    if (!cur) return;
    const block = cur.lines.join("\n").replace(/\s+$/, "");
    // Metadata fields are top-level (`- **Field:**` at column 0). Context is
    // indented, and may legitimately contain a metadata-shaped example.
    const statusMatches = [...block.matchAll(/^-\s*\*\*Status:\*\*\s*(.+?)\s*$/gim)];
    const typeMatches = [...block.matchAll(/^-\s*\*\*Type:\*\*\s*(.+?)\s*$/gim)];
    const valid = statusMatches.length === 1 && typeMatches.length === 1;
    const status = valid ? statusMatches[0][1].trim().toLowerCase() : null;
    const type = valid ? typeMatches[0][1].trim().toLowerCase() : null;
    if (valid &&
        (!wantStatus || status === wantStatus) &&
        (!wantType || type === wantType) &&
        !excludeTypes.has(type)) {
      out.push(block);
    }
    cur = null;
  };
  for (const line of text.split("\n")) {
    if (/^##\s+Items\s*$/i.test(line)) {
      flush();
      inItems = true;
    } else if (/^##\s+/.test(line)) {
      flush();
      inItems = false;
    } else if (inItems && /^###\s+/.test(line)) {
      flush();
      cur = { lines: [line] };
    }
    else if (cur) cur.lines.push(line);
  }
  flush();
  return out;
}

// A narrow projection cannot silently treat an unparseable item as irrelevant:
// its missing/duplicate metadata may be the very status or type being filtered.
// Validate the item envelope before --spec claims its result is authoritative.
function assertBacklogItemsWellFormed(text) {
  if (text === null) return;
  let current = null;
  let inItems = false;
  const validate = () => {
    if (!current) return;
    const block = current.lines.join("\n");
    const types = [...block.matchAll(/^-\s*\*\*Type:\*\*\s*(.+?)\s*$/gim)];
    const statuses = [...block.matchAll(/^-\s*\*\*Status:\*\*\s*(.+?)\s*$/gim)];
    if (types.length !== 1 || statuses.length !== 1) {
      throw new Error(
        `malformed backlog item "${current.title}": expected exactly one top-level Type and Status field`,
      );
    }
    current = null;
  };

  for (const line of text.split("\n")) {
    if (/^##\s+Items\s*$/i.test(line)) {
      validate();
      inItems = true;
    } else if (/^##\s+/.test(line)) {
      validate();
      inItems = false;
    } else if (inItems && /^###\s+/.test(line)) {
      validate();
      current = {
        title: line.replace(/^###\s+/, "").trim(),
        lines: [line],
      };
    } else if (current) {
      current.lines.push(line);
    }
  }
  validate();
}

// A narrow gap-only projection. It intentionally bypasses scan(): only
// backlog.md is read, and only matching open gap blocks are returned.
function scanGaps(projectRoot, type) {
  const backlog = readGapText(path.join(projectRoot, "_mano_output", "backlog.md"));
  const items = extractBacklogItems(backlog, { status: "backlog", type });
  const run = resolveConfiguredMode(projectRoot);
  return {
    projectRoot,
    runMode: run.mode,
    runModeSource: run.source,
    type,
    status: "backlog",
    count: items.length,
    items,
  };
}

// The narrow projection used by mano spec. It carries source requirements that
// mano start assigned to the current phase, plus unresolved spec-gap blocks.
// No other backlog status/type enters the projection.
function scanSpec(projectRoot) {
  const outputDir = path.join(projectRoot, "_mano_output");
  const backlog = readGapText(path.join(outputDir, "backlog.md"));
  const routing = phaseRouting(projectRoot, outputDir);
  const ref = routing.latest;
  const phase = ref ? ref.number : null;
  if (ref && backlog === null) {
    throw new Error(
      `active phase ${phase} (${ref.id}) exists but _mano_output/backlog.md is missing; ` +
      "cannot produce authoritative current-phase input",
    );
  }
  if (ref && !/^##\s+Items\s*$/im.test(backlog)) {
    throw new Error(
      `active phase ${phase} (${ref.id}) exists but _mano_output/backlog.md has no canonical ## Items section; ` +
      "cannot produce authoritative current-phase input",
    );
  }
  assertBacklogItemsWellFormed(backlog);
  const briefPath = ref === null
    ? null
    : `${ref.relativeDir}/phase-brief.md`;
  const briefExists = briefPath !== null && exists(path.join(projectRoot, briefPath));
  const briefStatus = briefExists ? "present" : "missing";
  const inPhaseStatus = ref === null ? "unavailable" : ref.inPhaseStatus;
  const inPhaseItems = ref === null
    ? []
    : extractBacklogItems(backlog, { status: inPhaseStatus });
  const specGapItems = extractBacklogItems(backlog, {
    status: "backlog", type: "spec-gap",
  });

  return {
    projectRoot,
    // READY means the projection completed authoritatively. Phase/brief
    // availability is separate and does not make a valid projection fail.
    status: "READY",
    owner: routing.owner,
    ownerSource: routing.ownerSource,
    runMode: routing.runMode,
    runModeSource: routing.runModeSource,
    phase,
    phaseId: ref ? ref.id : null,
    phaseDir: ref ? ref.relativeDir : null,
    briefPath,
    briefExists,
    briefStatus,
    inPhaseStatus,
    inPhaseCount: inPhaseItems.length,
    inPhaseItems,
    specGapStatus: "backlog",
    specGapCount: specGapItems.length,
    specGapItems,
  };
}

// The narrow projection used by mano ui. It reuses project-state signals only
// to reject a phase that is already reviewed and has no reopened story work;
// it never exposes backlog content or opens prior/root preview contents.
function scanUi(projectRoot) {
  const projectState = scan(projectRoot);
  const phase = projectState.phase;
  const designBriefPath = "_mano_output/design-brief.md";
  const legacyPreviewPath = "_mano_output/design-preview.html";
  const ui = {
    projectRoot,
    status: "BLOCKED",
    owner: projectState.owner,
    runMode: projectState.runMode,
    runModeSource: projectState.runModeSource,
    phase,
    phaseId: projectState.phaseId,
    phaseDir: projectState.phaseDir,
    briefPath: null,
    previewPath: null,
    previewExists: false,
    designBriefPath,
    designBriefExists: exists(path.join(projectRoot, designBriefPath)),
    legacyPreviewPath,
    legacyPreviewExists: exists(path.join(projectRoot, legacyPreviewPath)),
    route: "mano start — scope and approve a phase before running mano ui.",
  };

  if (phase === null) return ui;

  ui.briefPath = `${projectState.phaseDir}/phase-brief.md`;
  ui.previewPath = `${projectState.phaseDir}/design-preview.html`;
  const briefExists = exists(path.join(projectRoot, ui.briefPath));
  ui.previewExists = exists(path.join(projectRoot, ui.previewPath));
  if (!briefExists) {
    ui.route = `mano start — finish the draft for ${projectState.phaseId}; its phase-brief.md is missing.`;
    return ui;
  }

  const reopenedStoryWork = !!(
    projectState.stories
    && projectState.stories.rows.some((row) => row.status !== "done")
  );
  if (projectState.reviewEntry && !reopenedStoryWork) {
    ui.route = projectState.closed
      ? `mano start — ${projectState.phaseId} is already reviewed; scope the next phase before running mano ui.`
      : `mano review — ${projectState.phaseId} has a review entry but its close sweep still needs repair.`;
    return ui;
  }

  ui.status = "READY";
  ui.route = null;
  return ui;
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

// The latest review in the configured owner's namespace. Owned review headings
// are `## Phase N Review — Owner: <slug>`; legacy headings remain supported.
function extractLatestReview(text, ref, selectedOwner = null) {
  if (text === null) return null;
  const heading = /^##\s+Phase\s+(\d+)\s+Review(?:\s+—\s+Owner:\s+([a-z0-9][a-z0-9-]*))?(?:\s+—\s+.+)?\s*$/i;
  const sections = [];
  let cur = null;
  for (const line of text.split("\n")) {
    const m = heading.exec(line);
    if (m) {
      if (cur) sections.push(cur);
      cur = { phase: Number(m[1]), owner: m[2] ? m[2].toLowerCase() : null, lines: [line] };
    }
    else if (cur) {
      if (/^##\s+/.test(line)) { sections.push(cur); cur = null; } // non-review h2 ends it
      else cur.lines.push(line);
    }
  }
  if (cur) sections.push(cur);
  const owner = ref ? ref.owner : selectedOwner;
  const matchingOwner = sections.filter((section) => section.owner === owner);
  if (matchingOwner.length === 0) return null;
  let pick = ref
    ? matchingOwner.find((section) => section.phase === ref.number)
    : null;
  if (!pick) pick = matchingOwner.reduce((a, b) => (b.phase >= a.phase ? b : a));
  return pick.lines.join("\n").replace(/\s+$/, "");
}

// True if reviews.md has the exact heading for this phase identity.
function hasReviewEntry(text, ref) {
  if (text === null) return false;
  return reviewHeadingPattern(ref).test(text);
}

// ---- state assembly -------------------------------------------------------

function scan(projectRoot) {
  const outputDir = path.join(projectRoot, "_mano_output");
  const s = {
    projectRoot,
    outputDir,
    outputExists: exists(outputDir),
    owner: null,
    ownerSource: null,
    ownerMode: "legacy",
    runMode: "manual",
    runModeSource: null,
    otherOwners: [],
    phase: null,            // latest phase number, or null
    phaseId: null,
    phaseDir: null,
    phaseRef: null,
    inPhaseStatus: null,
    reviewHeading: null,
    briefExists: false,
    stories: null,          // { total, done, openTitles } or null
    reviewEntry: false,
    backlog: null,          // status counts, or null
    backlogItems: 0,        // all Status: backlog lines (backward-compatible field)
    unresolvedItems: 0,     // canonical open item count, including gap types
    scopeableBacklogItems: 0, // open items eligible for phase scope
    gaps: { "spec-gap": 0, "rule-gap": 0 },
    inPhaseRemaining: 0,    // Status: in-phase-<phase> count
    _backlogText: null,     // raw text, kept for scope extraction; not serialized
    _reviewsText: null,
  };

  const routing = phaseRouting(projectRoot, outputDir);
  s.owner = routing.owner;
  s.ownerSource = routing.ownerSource;
  s.ownerMode = routing.mode;
  s.runMode = routing.runMode;
  s.runModeSource = routing.runModeSource;
  s.otherOwners = routing.otherOwners;

  if (!s.outputExists) return finalize(s);

  s._backlogText = readText(path.join(outputDir, "backlog.md"));
  s._reviewsText = readText(path.join(outputDir, "reviews.md"));
  s.backlog = countBacklogStatuses(s._backlogText);
  const openItems = extractBacklogItems(s._backlogText, { status: "backlog" });
  const scopeableItems = extractBacklogItems(s._backlogText, {
    status: "backlog",
    excludeTypes: GAP_TYPES,
  });
  s.backlogItems = s.backlog["backlog"] || 0;
  s.unresolvedItems = openItems.length;
  s.scopeableBacklogItems = scopeableItems.length;
  s.gaps["spec-gap"] = extractBacklogItems(s._backlogText, {
    status: "backlog", type: "spec-gap",
  }).length;
  s.gaps["rule-gap"] = extractBacklogItems(s._backlogText, {
    status: "backlog", type: "rule-gap",
  }).length;

  const ref = routing.latest;
  s.phaseRef = ref;
  s.phase = ref ? ref.number : null;
  s.phaseId = ref ? ref.id : null;
  s.phaseDir = ref ? ref.relativeDir : null;
  s.inPhaseStatus = ref ? ref.inPhaseStatus : null;
  s.reviewHeading = ref ? ref.reviewHeading : null;

  if (ref) {
    const phaseDir = path.join(projectRoot, ref.relativeDir);
    s.briefExists = exists(path.join(phaseDir, "phase-brief.md"));
    s.stories = readStories(path.join(phaseDir, "stories", "README.md"));
    s.reviewEntry = hasReviewEntry(s._reviewsText, ref);
    s.inPhaseRemaining = s.backlog[ref.inPhaseStatus] || 0;
  }

  return finalize(s);
}

// Derive the verdict from raw signals, faithful to mano start's gate.
function finalize(s) {
  const storiesAllDone = !!(s.stories && s.stories.total > 0 && s.stories.done === s.stories.total);
  const storiesMissing = !s.stories || s.stories.total === 0;
  // Gate condition 3: reviewed/closed — review is mandatory, and its close sweep
  // must have moved every item for this exact phase identity off its in-phase status.
  const closed = s.reviewEntry && s.inPhaseRemaining === 0;

  let verdict, action;

  if (!s.outputExists) {
    verdict = "NEW_PROJECT";
    action = "No project yet. mano start takes Path B (conversation) — or run `mano import <doc>` first if a PRD/document exists, then Path A.";
  } else if (s.phase === null) {
    // Output dir exists but no phase folder (e.g. fresh `mano import`).
    if (s.scopeableBacklogItems > 0) {
      verdict = "READY_FIRST_PHASE";
      action = `Backlog has ${s.scopeableBacklogItems} phase-scopeable item(s) and no phase exists yet for ${s.owner || "legacy routing"}. mano start scopes phase 1 (Path A).`;
    } else if (s.gaps["spec-gap"] > 0 || s.gaps["rule-gap"] > 0) {
      verdict = "GAPS_ONLY";
      const routes = [];
      if (s.gaps["spec-gap"] > 0) routes.push(`${s.gaps["spec-gap"]} spec-gap → mano spec`);
      if (s.gaps["rule-gap"] > 0) routes.push(`${s.gaps["rule-gap"]} rule-gap → mano rules`);
      action = `No phase-scopeable backlog items. Open gaps remain (${routes.join("; ")}). Address them with their owning skill; mano start has nothing to scope.`;
    } else {
      verdict = "NEW_PROJECT";
      action = "An _mano_output/ scaffold exists but the backlog is empty and no phase started. mano start takes Path B (conversation), or `mano import <doc>` to populate the backlog first.";
    }
  } else if (!s.briefExists) {
    // Edge case: phase folder without a brief — a prior start didn't finalise.
    verdict = "RESUME_DRAFT";
    action = `${s.phaseId}/ exists without phase-brief.md — a previous mano start didn't finalise. Resume drafting ${s.phaseId}; do NOT start a new phase.`;
  } else if (storiesMissing) {
    verdict = "PHASE_IN_PROGRESS";
    action = `${s.phaseId} has a brief but no stories yet. Not complete — run mano stories. mano start must NOT scope a next phase.`;
  } else if (!storiesAllDone) {
    verdict = "PHASE_IN_PROGRESS";
    action = `${s.phaseId} has open stories (${s.stories.done}/${s.stories.total} done). Not complete — run mano dev. mano start must NOT scope a next phase.`;
  } else if (!closed) {
    verdict = "PHASE_BUILT_NOT_CLOSED";
    const blockers = [];
    if (!s.reviewEntry) blockers.push("no review entry");
    if (s.inPhaseRemaining > 0) blockers.push(`${s.inPhaseRemaining} item(s) still ${s.inPhaseStatus}`);
    const repair = s.reviewEntry
      ? "The review entry exists but its backlog close sweep is incomplete — re-run mano review to repair it."
      : "Run mano review.";
    action = `${s.phaseId} is built (stories all done) but not closed — ${blockers.join("; ")}. ${repair} mano start must NOT scope a next phase.`;
  } else {
    // Phase complete.
    if (s.scopeableBacklogItems > 0) {
      verdict = "READY_NEXT_PHASE";
      action = `${s.phaseId} is complete. mano start may scope phase ${s.phase + 1} for ${s.owner || "legacy routing"} from the ${s.scopeableBacklogItems} phase-scopeable backlog item(s) (Path A).`;
    } else {
      verdict = "COMPLETE_BACKLOG_EMPTY";
      const routes = [];
      if (s.gaps["spec-gap"] > 0) routes.push(`${s.gaps["spec-gap"]} spec-gap → mano spec`);
      if (s.gaps["rule-gap"] > 0) routes.push(`${s.gaps["rule-gap"]} rule-gap → mano rules`);
      action = routes.length
        ? `${s.phaseId} is complete and no phase-scopeable backlog items remain. Open gaps: ${routes.join("; ")}. Address them with their owning skill; mano start has nothing to scope.`
        : `${s.phaseId} is complete and no items have Status: backlog. Nothing to scope — add backlog items (or mano import a doc) before mano start.`;
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
  else if (s.next === "conversation") s.targetPhase = 1;
  else s.targetPhase = null;
  const targetRef = s.targetPhase === null
    ? null
    : phaseRef(s.owner, s.targetPhase);
  s.targetPhaseId = targetRef ? targetRef.id : null;
  s.targetPhaseDir = targetRef ? targetRef.relativeDir : null;
  s.targetInPhaseStatus = targetRef ? targetRef.inPhaseStatus : null;
  s.targetReviewHeading = targetRef ? targetRef.reviewHeading : null;

  // Attach the exact material mano start needs so the skill never has to reopen
  // backlog.md / reviews.md itself. A resume-draft includes every phase-scopeable
  // item status (gap types remain excluded) because interrupted finalisation may
  // have stopped before assignment recorded the approved subset; the human must
  // confirm that subset again.
  s.scope = null;
  if (s.next === "scope-backlog") {
    s.scope = {
      mode: "scope-backlog",
      coreProductPrinciples: extractCoreProductPrinciples(s._backlogText),
      backlogItems: extractBacklogItems(s._backlogText, {
        status: "backlog",
        excludeTypes: GAP_TYPES,
      }),
      latestReview: extractLatestReview(s._reviewsText, s.phaseRef, s.owner),
    };
  } else if (s.next === "resume-draft") {
    s.scope = {
      mode: "resume-draft",
      coreProductPrinciples: extractCoreProductPrinciples(s._backlogText),
      backlogItems: extractBacklogItems(s._backlogText, {
        excludeTypes: GAP_TYPES,
      }),
      latestReview: extractLatestReview(s._reviewsText, s.phaseRef, s.owner),
    };
  }
  return s;
}

// ---- rendering ------------------------------------------------------------

// Default output: the go/no-go plus the exact owner-scoped destination.
function renderDecision(s) {
  const L = [];
  L.push(`DECISION: ${s.decision}`);
  if (s.next) L.push(`NEXT: ${s.next}`);
  L.push(`OWNER: ${s.owner || "none (legacy phase-N mode)"}`);
  L.push(`MODE: ${s.runMode}`);
  if (s.targetPhase != null) {
    L.push(`PHASE: ${s.targetPhase}`);
    L.push(`PHASE_ID: ${s.targetPhaseId}`);
    L.push(`PHASE_DIR: ${s.targetPhaseDir}`);
    L.push(`IN_PHASE_STATUS: ${s.targetInPhaseStatus}`);
    L.push(`REVIEW_HEADING_PREFIX: ${s.targetReviewHeading}`);
  }
  L.push(s.action);
  return L.join("\n");
}

// The "why", printed only with --verbose. The skill never needs this; the
// human does, when they want to expand the decision.
function renderEvidence(s) {
  const L = [];
  L.push("mano · project state");
  L.push(`root: ${s.projectRoot}` + (s.outputExists ? "  (_mano_output/ found)" : "  (no _mano_output/)"));
  L.push(`owner: ${s.owner || "none (legacy phase-N mode)"}` + (s.ownerSource ? `  (${s.ownerSource})` : ""));
  if (s.otherOwners.length) L.push(`other owner namespaces: ${s.otherOwners.join(", ")}`);
  L.push("");

  if (s.outputExists && s.phase !== null) {
    L.push(`latest phase: ${s.phaseId}`);
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
    L.push(`  ${s.inPhaseStatus} items:      ${s.inPhaseRemaining} remaining`);
    L.push("");
  }

  if (s.outputExists) {
    const b = s.backlog || {};
    const keys = Object.keys(b).sort();
    L.push("backlog status counts:");
    if (keys.length === 0) L.push("  (no items)");
    for (const k of keys) L.push(`  ${k}: ${b[k]}`);
    L.push(`  phase-scopeable backlog items: ${s.scopeableBacklogItems}`);
    L.push(`  open spec-gap items: ${s.gaps["spec-gap"]}`);
    L.push(`  open rule-gap items: ${s.gaps["rule-gap"]}`);
    L.push("");
  }

  L.push(`detail: ${s.verdict}`);
  return L.join("\n");
}

// The scope input mano start consumes on a PROCEED: phase-scopeable Status:
// backlog items for a new scope, or all phase-scopeable statuses for a resumed
// draft, plus core principles and latest review. Empty when no payload exists.
function renderScope(s) {
  if (!s.scope) return "";
  const L = ["--- SCOPE INPUT (from the state script — do NOT reopen these files) ---"];
  if (s.scope.coreProductPrinciples) {
    L.push("");
    L.push(s.scope.coreProductPrinciples);
  }
  L.push("");
  const itemLabel = s.scope.mode === "resume-draft"
    ? "all phase-scopeable statuses"
    : "phase-scopeable Status: backlog";
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

// A gap-only backlog projection. The sentinel makes the boundary explicit to
// an agent tool trace: the script has already performed the read, so opening
// backlog.md is both unnecessary and forbidden.
function renderGaps(g) {
  const L = ["--- GAP INPUT (from the state script — do NOT open _mano_output/backlog.md) ---"];
  L.push(`MODE: ${g.runMode}`);
  L.push(`TYPE: ${g.type}`);
  L.push(`STATUS: ${g.status}`);
  L.push(`COUNT: ${g.count}`);
  if (g.items.length === 0) {
    L.push("");
    L.push("(none)");
  } else {
    for (const item of g.items) {
      L.push("");
      L.push(item);
    }
  }
  return L.join("\n");
}

function renderGapsJson(g) {
  return JSON.stringify(g, null, 2);
}

// The complete backlog-derived input for mano spec. Sentinels are deliberately
// stable so the skill can reject a malformed/partial projection before reading
// any artifact. Item blocks are emitted verbatim.
function renderSpec(spec) {
  const L = ["--- SPEC INPUT (from the state script — do NOT open _mano_output/backlog.md) ---"];
  L.push(`STATUS: ${spec.status}`);
  L.push(`OWNER: ${spec.owner || "none (legacy phase-N mode)"}`);
  L.push(`MODE: ${spec.runMode}`);
  L.push(`PHASE: ${spec.phase === null ? "none" : spec.phase}`);
  L.push(`PHASE_ID: ${spec.phaseId || "none"}`);
  L.push(`PHASE_DIR: ${spec.phaseDir || "missing"}`);
  L.push(`BRIEF: ${spec.briefPath || "missing"}`);
  L.push(`BRIEF_STATUS: ${spec.briefStatus}`);
  L.push(`IN_PHASE_STATUS: ${spec.inPhaseStatus}`);
  L.push(`IN_PHASE_COUNT: ${spec.inPhaseCount}`);
  L.push(`SPEC_GAP_STATUS: ${spec.specGapStatus}`);
  L.push(`SPEC_GAP_COUNT: ${spec.specGapCount}`);
  L.push("");
  L.push("## Current phase source items");
  if (spec.inPhaseItems.length === 0) L.push("(none)");
  else {
    for (const [index, item] of spec.inPhaseItems.entries()) {
      L.push("");
      L.push(`--- BEGIN IN-PHASE ITEM ${index + 1}/${spec.inPhaseCount} ---`);
      L.push(item);
      L.push(`--- END IN-PHASE ITEM ${index + 1}/${spec.inPhaseCount} ---`);
    }
  }
  L.push("");
  L.push("## Open spec gaps");
  if (spec.specGapItems.length === 0) L.push("(none)");
  else {
    for (const [index, item] of spec.specGapItems.entries()) {
      L.push("");
      L.push(`--- BEGIN SPEC-GAP ITEM ${index + 1}/${spec.specGapCount} ---`);
      L.push(item);
      L.push(`--- END SPEC-GAP ITEM ${index + 1}/${spec.specGapCount} ---`);
    }
  }
  L.push("");
  L.push(`END_IN_PHASE_COUNT: ${spec.inPhaseCount}`);
  L.push(`END_SPEC_GAP_COUNT: ${spec.specGapCount}`);
  L.push("--- END SPEC INPUT ---");
  return L.join("\n");
}

function renderSpecJson(spec) {
  return JSON.stringify(spec, null, 2);
}

// The only phase-discovery input mano ui receives. Paths are explicit so the
// skill never has to list phase folders or guess whether a root preview belongs
// to the current phase.
function renderUi(ui) {
  const L = ["--- UI INPUT (from the state script — do not scan phase folders) ---"];
  L.push(`STATUS: ${ui.status}`);
  L.push(`OWNER: ${ui.owner || "none (legacy phase-N mode)"}`);
  L.push(`MODE: ${ui.runMode}`);
  L.push(`PHASE: ${ui.phase === null ? "none" : ui.phase}`);
  L.push(`PHASE_ID: ${ui.phaseId || "none"}`);
  L.push(`PHASE_DIR: ${ui.phaseDir || "missing"}`);
  L.push(`BRIEF: ${ui.briefPath || "missing"}`);
  L.push(`PREVIEW: ${ui.previewPath || "unavailable"}`);
  L.push(`PREVIEW_STATUS: ${ui.previewExists ? "present" : "missing"}`);
  L.push(`DESIGN_BRIEF: ${ui.designBriefPath}`);
  L.push(`DESIGN_BRIEF_STATUS: ${ui.designBriefExists ? "present" : "missing"}`);
  L.push(`LEGACY_ROOT_PREVIEW: ${ui.legacyPreviewExists ? "present" : "absent"} — ${ui.legacyPreviewPath}; leave untouched`);
  if (ui.route) L.push(`ROUTE: ${ui.route}`);
  return L.join("\n");
}

function renderUiJson(ui) {
  return JSON.stringify(ui, null, 2);
}

// Exact phase routing for skills that need paths but not artifact contents.
function renderCurrent(s) {
  const L = ["--- CURRENT PHASE (from the state script — do not scan phase folders) ---"];
  L.push(`STATUS: ${s.phaseRef ? "READY" : "NO_PHASE"}`);
  L.push(`OWNER: ${s.owner || "none (legacy phase-N mode)"}`);
  L.push(`OWNER_MODE: ${s.ownerMode}`);
  L.push(`MODE: ${s.runMode}`);
  L.push(`PHASE: ${s.phase === null ? "none" : s.phase}`);
  L.push(`PHASE_ID: ${s.phaseId || "none"}`);
  L.push(`PHASE_DIR: ${s.phaseDir || "missing"}`);
  L.push(`BRIEF: ${s.phaseDir ? `${s.phaseDir}/phase-brief.md` : "missing"}`);
  L.push(`BRIEF_STATUS: ${s.briefExists ? "present" : "missing"}`);
  L.push(`STORIES: ${s.phaseDir ? `${s.phaseDir}/stories/README.md` : "missing"}`);
  L.push(`STORIES_STATUS: ${s.stories ? "present" : "missing"}`);
  L.push(`IN_PHASE_STATUS: ${s.inPhaseStatus || "unavailable"}`);
  L.push(`REVIEW_HEADING_PREFIX: ${s.reviewHeading || "unavailable"}`);
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
  L.push(`OWNER: ${s.owner || "none (legacy phase-N mode)"}`);
  L.push(`MODE: ${s.runMode}`);

  // Nothing to implement: no project / no phase folder.
  if (!s.outputExists || s.phase === null) {
    L.push("DEV: no phase started — nothing to implement.");
    L.push("Run mano start to scope a phase (or mano import a doc to populate the backlog first). Do NOT invent work.");
    return L.join("\n");
  }
  // Phase exists but isn't ready for dev — point at the skill that owns the gap.
  if (!s.briefExists) {
    L.push(`DEV: ${s.phaseId} draft is unfinished — no phase-brief.md. Finish mano start. Nothing for mano dev yet.`);
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    return L.join("\n");
  }
  if (!s.stories || s.stories.total === 0) {
    L.push(`DEV: ${s.phaseId} has a brief but no stories yet — run mano stories. Nothing for mano dev yet.`);
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    return L.join("\n");
  }

  const next = s.stories.rows.find((r) => r.status !== "done") || null;
  if (!next) {
    L.push(`DEV: ${s.phaseId} — nothing to implement.`);
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    L.push(`All ${s.stories.total} stories are done. The phase is built but NOT closed — run mano review. Do NOT scope or start a new phase before review closes this one.`);
  } else {
    L.push(`DEV: ${s.phaseId} — next pending story.`);
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    L.push(`STORY: ${next.num}`);
    L.push(`FILE: ${s.phaseDir}/stories/${next.file}`);
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
    owner: s.owner,
    ownerSource: s.ownerSource,
    ownerMode: s.ownerMode,
    runMode: s.runMode,
    runModeSource: s.runModeSource,
    otherOwners: s.otherOwners,
    phase: s.phase,
    phaseId: s.phaseId,
    phaseDir: s.phaseDir,
    inPhaseStatus: s.inPhaseStatus,
    reviewHeading: s.reviewHeading,
    briefExists: s.briefExists,
    stories: s.stories,
    storiesAllDone: s.storiesAllDone,
    reviewEntry: s.reviewEntry,
    inPhaseRemaining: s.inPhaseRemaining,
    backlog: s.backlog,
    backlogItems: s.backlogItems,
    unresolvedItems: s.unresolvedItems,
    scopeableBacklogItems: s.scopeableBacklogItems,
    gaps: s.gaps,
    closed: s.closed,
    decision: s.decision,
    next: s.next,
    targetPhase: s.targetPhase,
    targetPhaseId: s.targetPhaseId,
    targetPhaseDir: s.targetPhaseDir,
    targetInPhaseStatus: s.targetInPhaseStatus,
    targetReviewHeading: s.targetReviewHeading,
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
  if (args.spec) {
    if (args.scope || args.next || args.ui || args.current || args.gaps !== null || args.verbose) {
      process.stderr.write("[mano state] --spec cannot be combined with --scope, --next, --ui, --current, --gaps, or --verbose.\n");
      process.exit(1);
    }
    let spec;
    try {
      spec = scanSpec(args.root);
    } catch (error) {
      process.stderr.write(`[mano state] cannot project spec input — ${error.message}\n`);
      process.exit(1);
    }
    process.stdout.write((args.json ? renderSpecJson(spec) : renderSpec(spec)) + "\n");
    process.exit(0);
  }
  if (args.ui) {
    if (args.scope || args.next || args.current || args.spec || args.gaps !== null || args.verbose) {
      process.stderr.write("[mano state] --ui cannot be combined with --scope, --next, --current, --spec, --gaps, or --verbose.\n");
      process.exit(1);
    }
    let ui;
    try {
      ui = scanUi(args.root);
    } catch (error) {
      process.stderr.write(`[mano state] cannot resolve current phase — ${error.message}\n`);
      process.exit(1);
    }
    process.stdout.write((args.json ? renderUiJson(ui) : renderUi(ui)) + "\n");
    process.exit(0);
  }
  if (args.current) {
    if (args.scope || args.next || args.ui || args.spec || args.gaps !== null || args.verbose) {
      process.stderr.write("[mano state] --current cannot be combined with --scope, --next, --ui, --spec, --gaps, or --verbose.\n");
      process.exit(1);
    }
    let current;
    try {
      current = scan(args.root);
    } catch (error) {
      process.stderr.write(`[mano state] cannot resolve current phase — ${error.message}\n`);
      process.exit(1);
    }
    process.stdout.write((args.json ? renderJson(current) : renderCurrent(current)) + "\n");
    process.exit(0);
  }
  if (args.gaps !== null) {
    if (!GAP_TYPES.includes(args.gaps)) {
      process.stderr.write(`[mano state] --gaps requires exactly one of: ${GAP_TYPES.join(", ")}.\n`);
      process.exit(1);
    }
    if (args.scope || args.next || args.ui || args.current || args.spec || args.verbose) {
      process.stderr.write("[mano state] --gaps cannot be combined with --scope, --next, --ui, --current, --spec, or --verbose.\n");
      process.exit(1);
    }
    let gaps;
    try {
      gaps = scanGaps(args.root, args.gaps);
    } catch (error) {
      process.stderr.write(`[mano state] cannot read _mano_output/backlog.md — ${error.message}\n`);
      process.exit(1);
    }
    process.stdout.write((args.json ? renderGapsJson(gaps) : renderGaps(gaps)) + "\n");
    process.exit(0);
  }
  let s;
  try {
    s = scan(args.root);
  } catch (error) {
    process.stderr.write(`[mano state] cannot resolve current phase — ${error.message}\n`);
    process.exit(1);
  }
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

if (require.main === module) main();

module.exports = {
  GAP_TYPES,
  parseArgs,
  readStories,
  countBacklogStatuses,
  extractBacklogItems,
  assertBacklogItemsWellFormed,
  extractCoreProductPrinciples,
  extractLatestReview,
  hasReviewEntry,
  scanGaps,
  scanSpec,
  scanUi,
  scan,
  finalize,
  renderDecision,
  renderEvidence,
  renderScope,
  renderGaps,
  renderGapsJson,
  renderSpec,
  renderSpecJson,
  renderUi,
  renderUiJson,
  renderCurrent,
  renderNext,
  renderJson,
  main,
};
