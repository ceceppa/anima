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
 *   node state.js --scope --amend-current
 *                                 may the current phase's brief still be amended?
 *                                 AMEND_CURRENT only while no ledger exists
 *   node state.js --next          for mano dev / mano build: the active phase +
 *                                 the next unit of work — the next pending story
 *                                 (#, file) on the stories path, or the next
 *                                 non-done ledger row on the build path
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
const Ledger = require("./ledger.js");

const GAP_TYPES = ["spec-gap", "rule-gap"];

// Post-skill hook slots and the optional project-level artifacts, projected so
// skills never probe the filesystem for hooks or open artifacts merely to see
// whether they exist.
const HOOK_SKILLS = ["import", "start", "spec", "rules", "ux", "ui", "stories", "review"];
const OPTIONAL_ARTIFACTS = ["tech-spec", "ux-flow", "design-brief", "project-rules"];

function parseArgs(argv) {
  const args = {
    root: process.cwd(), json: false, verbose: false,
    scope: false, next: false, ui: false, current: false,
    spec: false, gaps: null, source: null, track: null, help: false,
    amendCurrent: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--json") args.json = true;
    else if (a === "--verbose" || a === "-v") args.verbose = true;
    else if (a === "--scope") args.scope = true;
    else if (a === "--amend-current") args.amendCurrent = true;
    else if (a === "--next") args.next = true;
    else if (a === "--ui") args.ui = true;
    else if (a === "--current") args.current = true;
    else if (a === "--spec") args.spec = true;
    else if (a === "--source") {
      const candidate = argv[i + 1];
      if (candidate == null || candidate.startsWith("-")) args.source = "";
      else { args.source = candidate; i++; }
    }
    else if (a === "--track") {
      const candidate = argv[i + 1];
      if (candidate == null || candidate.startsWith("-")) args.track = "";
      else { args.track = candidate; i++; }
    }
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
  node state.js [projectRoot] [--scope [--source <text>] [--track <name>] | --next | --ui | --current | --spec | --gaps <type>] [--verbose] [--json]

  projectRoot   directory containing _mano_output/ (default: current dir)
  --amend-current  with --scope only: ask whether the *current* phase's brief may
                still be amended in place. AMEND_CURRENT only when this exact
                owner and phase have a brief and neither ledger exists.
  --scope       on a PROCEED to scope-backlog or resume-draft, also print the
                relevant backlog items, core principles, and latest review
  --source      with --scope only: case-insensitive substring filter for an
                item's optional top-level Source provenance field
  --track       with --scope only: case-insensitive exact filter for an item's
                optional top-level Track; otherwise uses the active local track
  --next        for mano dev and mano build: the active phase and the next unit
                of work, computed fresh from disk — the next pending story (its
                # and file path) plus the ordered story list, or, when the phase
                has a progress.md ledger, its next non-done Scope row plus both
                ledger tables. On the build path it also reports the optional
                artifact inventory (ARTIFACTS) and any pending review findings
                (REWORK), before the ledger exists as well as after
  --ui          for mano ui: report the current phase brief and phase-local
                design preview paths without exposing backlog content or
                scanning phase folders in the prompt
  --current     report the configured owner and exact current phase identity,
                directory, brief, stories index or build ledger, backlog status,
                and review heading without exposing artifact contents
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

/**
 * Read the build ledger through the shared parser in `ledger.js`.
 *
 * Returns one of three states, and they are never collapsed:
 *
 *   missing   the file does not exist on disk. Nothing else means missing.
 *   invalid   the file exists and does not validate. A hard stop with one
 *             repair instruction; there is no v1 migration path because no v1
 *             ledger was ever released.
 *   present   the file exists and validates.
 *
 * B4 was the collapse: a malformed or empty ledger read as *no ledger*, which
 * routed build to create one and skipped the dual-ledger refusal entirely,
 * because that check only fired when progress parsed.
 */
function readProgress(progressFile, briefText = null) {
  const text = readText(progressFile);
  if (text === null) return { status: "missing", errors: [] };

  const parsed = Ledger.parseLedger(text);
  if (!parsed.ok) return { status: "invalid", errors: parsed.errors };

  const ledger = parsed.ledger;
  if (briefText !== null) {
    // D12: every row address points into the addressed brief, so an edit there
    // invalidates the ledger rather than silently repointing rows.
    const digest = Ledger.contractDigest(briefText);
    if (digest !== ledger.contract) {
      return {
        status: "invalid",
        errors: [
          `the phase brief changed after this ledger was created (contract ${ledger.contract} -> ${digest})`,
        ],
      };
    }
  }

  const rollUps = Ledger.rollUpIds(ledger.scope);
  const scopeLeaves = ledger.scope.filter((r) => !rollUps.has(r.id));
  const exitRollUps = Ledger.rollUpIds(ledger.exit);
  const exitLeaves = ledger.exit.filter((r) => !exitRollUps.has(r.id));
  const scope = {
    rows: ledger.scope,
    total: scopeLeaves.length,
    closed: scopeLeaves.filter((r) => r.status === "done").length,
  };
  const exit = {
    rows: ledger.exit,
    total: exitLeaves.length,
    closed: exitLeaves.filter((r) => r.status === "met").length,
  };
  const needsHuman = exitLeaves.filter((r) => r.status === "needs-human");
  return {
    status: "present",
    errors: [],
    ledger,
    scope,
    exit,
    rework: ledger.rework,
    openRework: ledger.rework.filter((r) => r.status === "pending"),
    needsHuman,
    // B2: the deepest open leaf, in comparator order — never the roll-up parent
    // that a file-order scan returns.
    next: Ledger.nextActionableRow(ledger.scope),
    allDone: scope.total > 0 && scope.closed === scope.total,
    allMet: exit.total > 0 && exit.closed === exit.total,
  };
}

/**
 * The exact contract text for one row, whatever kind it is.
 *
 * A normal row's contract is its brief item or leaf, re-derived through the
 * same parser `init` used — which is what makes B1 fixable, because a nested
 * leaf's full behaviour line is recoverable instead of reduced to its bolded
 * lead. A correction or split carries its own text in `## Row Contracts`.
 */
function rowContractText(progress, briefText, row) {
  if (!row) return null;
  if (row.parsed.kind !== "normal") {
    const body = progress.ledger.contracts.get(row.id);
    return body && body.text ? body.text : null;
  }
  if (briefText === null) return null;
  const source = row.parsed.table === "S" ? Ledger.parseScope(briefText) : Ledger.parseExitCriteria(briefText);
  if (source.error) return null;
  const match = source.rows.find((r) => r.id === row.id);
  return match ? match.text : null;
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
// matching the requested status/type/source/track filters, in file order. `source`
// is a case-insensitive substring match against the optional top-level Source
// provenance field. Only `###`
// blocks under `## Items` count as backlog items; headings in Core Product
// Principles or other sections are never exposed.
function extractBacklogItems(text, options = {}) {
  if (text === null) return [];
  const wantStatus = options.status ? options.status.toLowerCase() : null;
  const wantType = options.type ? options.type.toLowerCase() : null;
  const wantSource = options.source ? options.source.trim().toLowerCase() : null;
  const wantTrack = options.track ? options.track.trim().toLowerCase() : null;
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
    const sourceMatches = [...block.matchAll(/^-\s*\*\*Source:\*\*\s*(.+?)\s*$/gim)];
    // Accept the canonical `**Track:**` form and the common Markdown
    // `**Track**:` form. backlog.js always writes the canonical form, but
    // human-edited and older backlogs may place the colon outside the bold.
    const trackMatches = [...block.matchAll(/^-\s*\*\*Track(?::\*\*|\*\*\s*:)\s*(.+?)\s*$/gim)];
    const valid = statusMatches.length === 1 && typeMatches.length === 1;
    const status = valid ? statusMatches[0][1].trim().toLowerCase() : null;
    const type = valid ? typeMatches[0][1].trim().toLowerCase() : null;
    const source = sourceMatches.length === 1 ? sourceMatches[0][1].trim().toLowerCase() : null;
    const track = trackMatches.length === 1 ? trackMatches[0][1].trim().toLowerCase() : null;
    if (valid &&
        (!wantStatus || status === wantStatus) &&
        (!wantType || type === wantType) &&
        (!wantSource || (source && source.includes(wantSource))) &&
        (!wantTrack || track === wantTrack) &&
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
    const sources = [...block.matchAll(/^-\s*\*\*Source:\*\*\s*(.+?)\s*$/gim)];
    const tracks = [...block.matchAll(/^-\s*\*\*Track(?::\*\*|\*\*\s*:)\s*(.+?)\s*$/gim)];
    if (types.length !== 1 || statuses.length !== 1 || sources.length > 1 || tracks.length > 1) {
      throw new Error(
        `malformed backlog item "${current.title}": expected exactly one top-level Type and Status field, ` +
        "with at most one Source and Track field",
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

function backlogItemTrack(block) {
  const match = /^-\s*\*\*Track(?::\*\*|\*\*\s*:)\s*(.+?)\s*$/im.exec(block);
  return match ? match[1].trim() : null;
}

// An interrupted phase owns its planning context. A newly selected local Track
// must not silently relabel items already assigned to that phase. Older drafts
// may have no Track metadata; in that case the current selection remains usable.
function resumeDraftTrack(assignedItems, selectedTrack, phaseId) {
  const values = assignedItems.map(backlogItemTrack);
  const named = new Map();
  let untracked = false;
  for (const value of values) {
    if (value === null) untracked = true;
    else if (!named.has(value.toLowerCase())) named.set(value.toLowerCase(), value);
  }
  if (named.size > 1 || (named.size === 1 && untracked)) {
    throw new Error(
      `${phaseId} has assigned backlog items with conflicting Track values; ` +
      "repair their top-level Track fields before resuming the draft",
    );
  }
  return named.size === 1 ? [...named.values()][0] : selectedTrack;
}

// Active post-skill hooks with their declared mode, as `mode:post-skill`
// entries. Hooks are repo-level — never owner-namespaced. The `## Mode`
// section's first non-empty line decides; a missing or unrecognised mode is
// `suggest` (back-compat with hooks written before the other modes existed).
function scanHooks(projectRoot) {
  const out = [];
  for (const skill of HOOK_SKILLS) {
    const hookPath = path.join(projectRoot, "_mano", "hooks", `post-${skill}.md`);
    if (!exists(hookPath)) continue;
    const text = readText(hookPath) || "";
    let mode = "suggest";
    const match = /^##\s+Mode\s*\r?\n+[ \t]*(\S+)/im.exec(text);
    if (match) {
      const declared = match[1].trim().toLowerCase();
      if (declared === "command" || declared === "check" || declared === "suggest") mode = declared;
    }
    out.push(`${mode}:post-${skill}`);
  }
  return out;
}

// Existence of the four optional project-level artifacts, as `name=present|absent`.
function scanArtifacts(projectRoot) {
  const outputDir = path.join(projectRoot, "_mano_output");
  return OPTIONAL_ARTIFACTS.map(
    (name) => `${name}=${exists(path.join(outputDir, `${name}.md`)) ? "present" : "absent"}`,
  );
}

/**
 * Planning artifacts whose mtime is newer than the ledger's — advisory only.
 *
 * D9: mtime is weaker than a digest, and a `touch` or a git checkout trips it.
 * That is acceptable precisely because the signal routes nothing: it prints one
 * line, review surfaces it, and the human decides. A false positive costs a
 * line and no behaviour.
 */
function staleInputs(outputDir, progressFile) {
  const ledgerTime = mtimeOf(progressFile);
  if (ledgerTime === null) return [];
  const stale = [];
  for (const name of OPTIONAL_ARTIFACTS) {
    const when = mtimeOf(path.join(outputDir, `${name}.md`));
    if (when !== null && when > ledgerTime) stale.push(`${name}.md`);
  }
  return stale;
}

function mtimeOf(file) {
  try { return fs.statSync(file).mtimeMs; } catch { return null; }
}

/**
 * May the current phase's brief still be amended in place?
 *
 * Only while **no ledger exists**. A ledger's row addresses point into the
 * brief's `## Phase Scope` and `## Exit Criteria`, and `init` fingerprints them
 * — so once one exists, editing the brief is not an amendment, it is a
 * migration nobody asked for. Before that point there is nothing addressing the
 * brief, and re-approving a revised scope costs one exchange.
 *
 * This closes the loop the documented route used to have: build sent the user
 * to `mano start`, which sent them to `mano stories`, which saw `progress.md`
 * and sent them back to `mano start`.
 */
function renderAmendCurrent(s) {
  const L = ["--- AMEND CURRENT (from the state script — do NOT scan phase folders) ---"];
  L.push(`OWNER: ${s.owner || "none (legacy phase-N mode)"}`);
  L.push(`MODE: ${s.runMode}`);
  L.push(`TRACK: ${s.track || "none"}`);

  const reason = amendBlocker(s);
  L.push(`DECISION: ${reason ? "REFUSE" : "AMEND_CURRENT"}`);
  if (s.phaseId) {
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    L.push(`PHASE_DIR: ${s.phaseDir}`);
    L.push(`BRIEF: ${s.phaseDir}/phase-brief.md`);
  }
  L.push(`STORIES_STATUS: ${s.storiesExists ? "present" : "missing"}`);
  L.push(`PROGRESS_STATUS: ${s.progressStatus}`);
  if (reason) {
    L.push(`REASON: ${reason}`);
  } else {
    L.push("The brief may be revised in place. Show the complete proposed scope and write");
    L.push("nothing until the human approves it; that approval is the approval of the revised");
    L.push("contract. Re-check this projection immediately before writing.");
  }
  L.push("--- END AMEND CURRENT ---");
  return L.join("\n");
}

function amendBlocker(s) {
  if (!s.outputExists || s.phase === null) {
    return "no phase exists for this owner — mano start scopes one; there is nothing to amend";
  }
  if (!s.briefExists) {
    return `${s.phaseId} has no phase-brief.md — finish the draft rather than amending it`;
  }
  if (s.storiesExists && s.progressExists) {
    return `${s.phaseId} holds both ledgers — resolve that first`;
  }
  if (s.storiesExists) {
    return `${s.phaseId} already has a stories index; its stories address this brief. `
      + "An in-goal change is a lettered story via mano stories; a distinct outcome goes to the backlog or the next phase";
  }
  if (s.progressExists) {
    return `${s.phaseId} already has a build ledger; its rows address this brief and init fingerprinted it. `
      + "An in-goal change is a correction row via mano build; a distinct outcome goes to the backlog or the next phase";
  }
  return null;
}

function hookLine(hooks) {
  return `HOOK: ${hooks.length ? hooks.join(" ") : "none"}`;
}

function artifactsLine(artifacts) {
  return `ARTIFACTS: ${artifacts.join(" ")}`;
}

// A narrow gap-only projection. It intentionally bypasses scan(): only
// backlog.md is read, and only matching open gap blocks are returned.
function scanGaps(projectRoot, type) {
  const backlog = readGapText(path.join(projectRoot, "_mano_output", "backlog.md"));
  assertBacklogItemsWellFormed(backlog);
  const items = extractBacklogItems(backlog, { status: "backlog", type });
  const run = resolveConfiguredMode(projectRoot);
  return {
    projectRoot,
    runMode: run.mode,
    runModeSource: run.source,
    hooks: scanHooks(projectRoot),
    artifacts: scanArtifacts(projectRoot),
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
    hooks: scanHooks(projectRoot),
    artifacts: scanArtifacts(projectRoot),
    track: routing.track,
    trackSource: routing.trackSource,
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
    hooks: projectState.hooks,
    artifacts: projectState.artifacts,
    track: projectState.track,
    trackSource: projectState.trackSource,
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

function scan(projectRoot, options = {}) {
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
    hooks: scanHooks(projectRoot),
    artifacts: scanArtifacts(projectRoot),
    track: null,
    trackSource: null,
    otherOwners: [],
    phase: null,            // latest phase number, or null
    phaseId: null,
    phaseDir: null,
    phaseRef: null,
    inPhaseStatus: null,
    reviewHeading: null,
    briefExists: false,
    stories: null,          // { total, done, openTitles } or null
    storiesExists: false,   // physical existence, independent of parsing
    progressExists: false,  // physical existence, independent of parsing
    progress: { status: "missing", errors: [] }, // shared-parser ledger read
    progressStatus: "missing", // missing | present | invalid — never collapsed
    brief: null,            // the active phase brief's text, when it exists
    staleInputs: [],        // advisory: planning artifacts newer than the ledger
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
  s.track = routing.track;
  s.trackSource = routing.trackSource;
  s.otherOwners = routing.otherOwners;

  if (!s.outputExists) return finalize(s, options);

  s._backlogText = readText(path.join(outputDir, "backlog.md"));
  s._reviewsText = readText(path.join(outputDir, "reviews.md"));
  assertBacklogItemsWellFormed(s._backlogText);
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
    const briefFile = path.join(phaseDir, "phase-brief.md");
    const storiesFile = path.join(phaseDir, "stories", "README.md");
    const progressFile = path.join(phaseDir, "progress.md");
    s.briefExists = exists(briefFile);
    s.brief = s.briefExists ? readText(briefFile) : null;
    // One ledger per phase, decided on **physical existence**. Deciding it on
    // whether a file parsed is B4: a malformed progress.md read as no ledger,
    // so a phase holding both skipped this refusal entirely.
    s.storiesExists = exists(storiesFile);
    s.progressExists = exists(progressFile);
    if (s.storiesExists && s.progressExists) {
      throw new Error(
        `${ref.id} holds both stories/README.md and progress.md. ` +
        "A phase has one ledger: mano stories + mano dev, or mano build. " +
        "Keep the one that matches how this phase was planned and remove the other.",
      );
    }
    s.stories = readStories(storiesFile);
    s.progress = readProgress(progressFile, s.brief);
    s.progressStatus = s.progress.status;
    s.staleInputs = s.progressExists ? staleInputs(outputDir, progressFile) : [];
    s.reviewEntry = hasReviewEntry(s._reviewsText, ref);
    s.inPhaseRemaining = s.backlog[ref.inPhaseStatus] || 0;
  }

  return finalize(s, options);
}

// Derive the verdict from raw signals, faithful to mano start's gate.
function finalize(s, options = {}) {
  const storiesAllDone = !!(s.stories && s.stories.total > 0 && s.stories.done === s.stories.total);
  const storiesMissing = !s.stories || s.stories.total === 0;
  // The build path's ledger answers the same two questions the stories index
  // does, with one addition: built means every Scope row done AND every Exit
  // Criterion met. A phase has one ledger or the other (scan refuses both).
  const building = s.progressStatus === "present";
  // D4: a confirmed review finding is durable state, not conversation. While one
  // is pending the phase routes back to build even though every row reads done —
  // that is the whole reason the finding is in the ledger and not in the chat.
  const openRework = building ? s.progress.openRework.length : 0;
  const buildAllDone = !!(building && s.progress.allDone && s.progress.allMet && openRework === 0);
  const ledgerMissing = storiesMissing && !s.progressExists;
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
  } else if (s.progressStatus === "invalid") {
    // A hard stop with one repair instruction. No migration path exists, and
    // none is needed: no v1 ledger was ever released (D2).
    verdict = "LEDGER_INVALID";
    action =
      `${s.phaseId}/progress.md exists but is not a valid v2 ledger ` +
      `(${s.progress.errors.join("; ")}). Delete ${s.phaseDir}/progress.md and re-run mano build. ` +
      "Do NOT hand-repair it, and do NOT treat this phase as unstarted.";
  } else if (ledgerMissing) {
    verdict = "PHASE_IN_PROGRESS";
    // The one state where the run mode decides the implementation entry: with
    // no ledger both paths are still open, so an armed auto chain must not be
    // offered a branch it is forbidden to choose (its terminal action is
    // mano build), and a manual user must not be handed one path as if the
    // other did not exist. Every other state is decided by the ledger itself.
    action = s.runMode === "auto"
      ? `${s.phaseId} has a brief but no stories or build ledger yet. Not complete — the armed chain's terminal action is mano build, which creates the ledger from this brief. mano start must NOT scope a next phase.`
      : `${s.phaseId} has a brief but no stories or build ledger yet. Not complete — run mano stories (then mano dev) for story files, or mano build to build straight from the brief. Both are valid; the human picks. mano start must NOT scope a next phase.`;
  } else if (building && !buildAllDone) {
    verdict = "PHASE_IN_PROGRESS";
    action = openRework
      ? `${s.phaseId} has ${openRework} pending review finding(s) in its ledger. Not complete — run mano build to work the first pending R… event. mano start must NOT scope a next phase.`
      : `${s.phaseId} is being built (${s.progress.scope.closed}/${s.progress.scope.total} scope rows done, ${s.progress.exit.closed}/${s.progress.exit.total} exit criteria met). Not complete — run mano build. mano start must NOT scope a next phase.`;
  } else if (!building && !storiesAllDone) {
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
    const proof = building ? "every scope row done, every exit criterion met" : "stories all done";
    action = `${s.phaseId} is built (${proof}) but not closed — ${blockers.join("; ")}. ${repair} mano start must NOT scope a next phase.`;
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
  s.buildAllDone = buildAllDone;
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
  // backlog.md / reviews.md itself. A resume-draft includes open candidates plus
  // every item already assigned to that exact interrupted phase. It excludes
  // resolved, rejected, and other phases so recovery cannot reopen old work.
  s.scope = null;
  const source = options.source || null;
  const track = options.track !== undefined && options.track !== null ? options.track : s.track;
  if (s.next === "scope-backlog") {
    s.scope = {
      mode: "scope-backlog",
      source,
      track,
      coreProductPrinciples: extractCoreProductPrinciples(s._backlogText),
      backlogItems: extractBacklogItems(s._backlogText, {
        status: "backlog",
        excludeTypes: GAP_TYPES,
        source,
        track,
      }),
      latestReview: extractLatestReview(s._reviewsText, s.phaseRef, s.owner),
    };
  } else if (s.next === "resume-draft") {
    const assignedItems = extractBacklogItems(s._backlogText, {
      status: s.targetInPhaseStatus,
      excludeTypes: GAP_TYPES,
    });
    const phaseTrack = resumeDraftTrack(assignedItems, track, s.targetPhaseId);
    const openCandidates = extractBacklogItems(s._backlogText, {
      status: "backlog",
      excludeTypes: GAP_TYPES,
      source,
      track: phaseTrack,
    });
    s.scope = {
      mode: "resume-draft",
      source,
      track: phaseTrack,
      coreProductPrinciples: extractCoreProductPrinciples(s._backlogText),
      backlogItems: [...assignedItems, ...openCandidates],
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
  // A one-off `--scope --track` is the selected planning context even when it
  // differs from this clone's saved default. Start consumes this decision
  // before the scope payload, so show the effective value here too.
  const effectiveTrack = s.scope ? s.scope.track : s.track;
  L.push(`TRACK: ${effectiveTrack || "none"}`);
  L.push(hookLine(s.hooks));
  L.push(artifactsLine(s.artifacts));
  if (s.targetPhase != null) {
    L.push(`PHASE: ${s.targetPhase}`);
    L.push(`PHASE_ID: ${s.targetPhaseId}`);
    L.push(`PHASE_DIR: ${s.targetPhaseDir}`);
    L.push(`IN_PHASE_STATUS: ${s.targetInPhaseStatus}`);
    L.push(`REVIEW_HEADING_PREFIX: ${s.targetReviewHeading}`);
  }
  // Gap items never enter scope selection, so a phase-scopeable backlog hides
  // them from the human entirely — including a stated directive intake homed
  // here precisely so it would not be lost. Surfacing the routes costs one
  // line and never changes the decision.
  const openGapRoutes = [];
  if (s.gaps && s.gaps["spec-gap"] > 0) openGapRoutes.push(`${s.gaps["spec-gap"]} spec-gap → mano spec`);
  if (s.gaps && s.gaps["rule-gap"] > 0) openGapRoutes.push(`${s.gaps["rule-gap"]} rule-gap → mano rules`);
  if (openGapRoutes.length) L.push(`OPEN_GAPS: ${openGapRoutes.join("; ")}`);
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
    } else if (s.progressStatus === "invalid") {
      L.push(`  build ledger:          INVALID — delete ${s.phaseDir}/progress.md and re-run mano build`);
      for (const problem of s.progress.errors) L.push(`                           ${problem}`);
    } else if (s.progressStatus === "present") {
      L.push(`  build ledger:          ${s.progress.scope.closed}/${s.progress.scope.total} scope rows done, ${s.progress.exit.closed}/${s.progress.exit.total} exit criteria met`);
      for (const r of s.progress.scope.rows) {
        if (r.status !== "done") L.push(`                           open: ${r.id} ${r.label} (${r.status || "—"})`);
      }
      for (const r of s.progress.openRework) {
        L.push(`                           rework: ${r.id} ${r.label}`);
      }
      for (const artifact of s.staleInputs) {
        L.push(`                           ⚠ ${artifact} changed after the ledger was last written`);
      }
    } else {
      L.push(`  stories:               none (no stories/README.md, no progress.md)`);
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
// backlog items for a new scope, or exact-phase assignments plus open candidates
// for a resumed draft, plus core principles and latest review.
function renderScope(s) {
  if (!s.scope) return "";
  const L = ["--- SCOPE INPUT (from the state script — do NOT reopen these files) ---"];
  if (s.scope.coreProductPrinciples) {
    L.push("");
    L.push(s.scope.coreProductPrinciples);
  }
  L.push("");
  const resuming = s.scope.mode === "resume-draft";
  const itemLabel = resuming
    ? `Status: ${s.targetInPhaseStatus} (always included) plus phase-scopeable Status: backlog`
    : "phase-scopeable Status: backlog";
  const filters = [];
  if (s.scope.source) filters.push(`Source contains ${JSON.stringify(s.scope.source)}`);
  if (s.scope.track) filters.push(`Track is ${JSON.stringify(s.scope.track)}`);
  const filterLabel = filters.length
    ? `${resuming ? "; open candidates: " : "; "}${filters.join("; ")}`
    : "";
  L.push(`## Backlog items — ${itemLabel}${filterLabel} (${s.scope.backlogItems.length})`);
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
  L.push(hookLine(g.hooks));
  L.push(artifactsLine(g.artifacts));
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
  L.push(hookLine(spec.hooks));
  L.push(artifactsLine(spec.artifacts));
  L.push(`TRACK: ${spec.track || "none"}`);
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
  L.push(hookLine(ui.hooks));
  L.push(artifactsLine(ui.artifacts));
  L.push(`TRACK: ${ui.track || "none"}`);
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
  L.push(hookLine(s.hooks));
  L.push(artifactsLine(s.artifacts));
  L.push(`TRACK: ${s.track || "none"}`);
  L.push(`PHASE: ${s.phase === null ? "none" : s.phase}`);
  L.push(`PHASE_ID: ${s.phaseId || "none"}`);
  L.push(`PHASE_DIR: ${s.phaseDir || "missing"}`);
  L.push(`BRIEF: ${s.phaseDir ? `${s.phaseDir}/phase-brief.md` : "missing"}`);
  L.push(`BRIEF_STATUS: ${s.briefExists ? "present" : "missing"}`);
  L.push(`STORIES: ${s.phaseDir ? `${s.phaseDir}/stories/README.md` : "missing"}`);
  L.push(`STORIES_STATUS: ${s.stories ? "present" : "missing"}`);
  L.push(`PROGRESS: ${s.phaseDir ? `${s.phaseDir}/progress.md` : "missing"}`);
  // missing | present | invalid, never collapsed: `missing` means the file is
  // not on disk and nothing else does (B4).
  L.push(`PROGRESS_STATUS: ${s.progressStatus}`);
  if (s.progressStatus === "invalid") {
    for (const problem of s.progress.errors) L.push(`  - ${problem}`);
    L.push(`Delete ${s.phaseDir}/progress.md and re-run mano build. Do NOT hand-repair it.`);
  }
  if (s.progressStatus === "present") {
    L.push(`SCOPE: ${s.progress.scope.closed}/${s.progress.scope.total} done`);
    L.push(`EXIT_CRITERIA: ${s.progress.exit.closed}/${s.progress.exit.total} met`);
    if (s.progress.needsHuman.length) L.push(`NEEDS_HUMAN: ${s.progress.needsHuman.map((r) => r.id).join(" ")}`);
    if (s.progress.openRework.length) L.push(`REWORK: ${s.progress.openRework.length} pending`);
    for (const artifact of s.staleInputs) {
      L.push(`⚠ ${artifact} changed after the ledger was last written`);
    }
  }
  L.push(`IN_PHASE_STATUS: ${s.inPhaseStatus || "unavailable"}`);
  L.push(`REVIEW_HEADING_PREFIX: ${s.reviewHeading || "unavailable"}`);
  return L.join("\n");
}

// The mano dev projection: what to implement right now, computed fresh from
// disk. Surfaces the active phase, the FIRST pending story (in file order) with
// its file path, and the ordered story list — so the implementer needn't ls for
// the phase or reopen the index, and can't be fooled by a stale phase carried in
// the chat. It only *reports* the next pending row; it never decides to skip an
// earlier pending one (that bypass stays the user's call — dev.md step 5).
function renderNext(s) {
  const L = [];
  L.push(`OWNER: ${s.owner || "none (legacy phase-N mode)"}`);
  L.push(`MODE: ${s.runMode}`);
  L.push(`TRACK: ${s.track || "none"}`);

  // No HOOK/ARTIFACTS lines here: mano dev has no hook slot and reads
  // artifacts only where its contract's steps direct it to.

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

  // A ledger that exists and does not validate is a hard stop, never a phase
  // to start building. Collapsing this into "no ledger" is B4.
  if (s.progressStatus === "invalid") {
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    L.push(`PHASE_DIR: ${s.phaseDir}`);
    L.push(`PROGRESS: ${s.phaseDir}/progress.md`);
    L.push("PROGRESS_STATUS: invalid");
    for (const problem of s.progress.errors) L.push(`  - ${problem}`);
    L.push(`Delete ${s.phaseDir}/progress.md and re-run mano build. Do NOT hand-repair it, do NOT`);
    L.push("treat this phase as unstarted, and do NOT write any row or status until it is gone.");
    return L.join("\n");
  }

  // Build path: this phase's ledger is progress.md, not a stories index. Same
  // projection contract — what to work on right now, computed fresh from disk.
  if (s.progressStatus === "present") {
    const next = s.progress.next;
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    L.push(`PHASE_DIR: ${s.phaseDir}`);
    L.push(`BRIEF: ${s.phaseDir}/phase-brief.md`);
    L.push(`PROGRESS: ${s.phaseDir}/progress.md`);
    L.push("PROGRESS_STATUS: present");
    // B7: build had no whole-brief artifact discovery, so it could not tell a
    // missing input from an input it simply had not opened.
    L.push(artifactsLine(s.artifacts));
    L.push(`SCOPE: ${s.progress.scope.closed}/${s.progress.scope.total} done`);
    L.push(`EXIT_CRITERIA: ${s.progress.exit.closed}/${s.progress.exit.total} met`);
    if (s.progress.openRework.length) L.push(`REWORK: ${s.progress.openRework.length} pending`);
    // D9: advisory only. No routing hangs off it; the human decides.
    for (const artifact of s.staleInputs) {
      L.push(`⚠ ${artifact} changed after the ledger was last written`);
    }
    if (next) {
      L.push(`ROW: ${next.id}`);
      // The row's exact contract, inline. A normal row's is re-derived from the
      // brief through the same parser init used; a correction or a split carries
      // its own. Either way the implementer no longer opens the brief to read
      // one line — the resident-context term that dominates cost.
      const contract = rowContractText(s.progress, s.brief, next);
      if (contract === null) {
        L.push("ROW_CONTRACT: unavailable — the row's text could not be recovered. Stop and report this.");
      } else {
        L.push("ROW_CONTRACT:");
        for (const line of contract.split("\n")) L.push(`  ${line}`);
        L.push("END_ROW_CONTRACT");
      }
    } else if (s.progress.openRework.length) {
      L.push("ROW: none");
      L.push(`Every scope row is done, but ${s.progress.openRework.length} review finding(s) are still pending. Work the first pending R… event in order; each one keeps its own exact text in \`## Row Contracts\`. The phase does not go back to review until none is pending.`);
    } else if (!s.progress.allMet) {
      L.push("ROW: none");
      L.push("Every scope row is done but not every Exit Criterion is met. Prove the remaining ones or reopen the row that owes the evidence; the phase is not built until both tables are closed.");
    } else {
      L.push("ROW: none");
      L.push("Every scope row is done and every Exit Criterion is met. The phase is built but NOT closed — run mano review. Do NOT scope or start a new phase before review closes this one.");
    }
    const rollUps = Ledger.rollUpIds(s.progress.scope.rows);
    L.push("");
    L.push("Scope (Status is the only signal; → = next row, = marks a roll-up whose status is derived):");
    for (const r of s.progress.scope.rows) {
      const mark = next && r.id === next.id ? "→" : (rollUps.has(r.id) ? "=" : " ");
      L.push(`${mark} ${r.id.padEnd(8)} ${r.status.padEnd(11)} ${r.label}`);
    }
    L.push("");
    L.push("Exit Criteria (every leaf must be met before review):");
    for (const r of s.progress.exit.rows) {
      L.push(`  ${r.id.padEnd(8)} ${r.status.padEnd(11)} ${r.label}`);
    }
    if (s.progress.rework.length) {
      L.push("");
      L.push("Rework (review findings; build routes here while any is pending):");
      for (const r of s.progress.rework) {
        L.push(`  ${r.id.padEnd(8)} ${r.status.padEnd(11)} ${r.label}`);
      }
    }
    return L.join("\n");
  }

  if (!s.stories || s.stories.total === 0) {
    L.push(
      s.runMode === "auto"
        ? `DEV: ${s.phaseId} has a brief but no stories yet — in auto the implementation entry is mano build, which builds straight from the brief. Nothing for mano dev yet.`
        : `DEV: ${s.phaseId} has a brief but no stories yet — run mano stories for story files, or mano build to build straight from the brief. Nothing for mano dev yet.`,
    );
    L.push(`PHASE: ${s.phase}`);
    L.push(`PHASE_ID: ${s.phaseId}`);
    L.push(`PHASE_DIR: ${s.phaseDir}`);
    L.push(`BRIEF: ${s.phaseDir}/phase-brief.md`);
    L.push(`PROGRESS: ${s.phaseDir}/progress.md`);
    L.push("PROGRESS_STATUS: missing");
    // B7 again, on the branch that matters most: this is the projection
    // `mano build` reads on its FIRST run, when pre-flight 0b has to open every
    // present artifact and nothing has been written yet. Reporting the
    // inventory only once a ledger exists gives build the list one run too
    // late.
    L.push(artifactsLine(s.artifacts));
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
    L.push("Read that story file first, then follow _mano/skills/dev.md steps 6-10 for any required tech-spec or project-rules context; implement only its acceptance criteria; then mark it done via stories.js set-status (step 11).");
  }

  // The ordered list, so honouring story order (dev.md steps 4-5) for a
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
    hooks: s.hooks,
    artifacts: s.artifacts,
    track: s.track,
    trackSource: s.trackSource,
    otherOwners: s.otherOwners,
    phase: s.phase,
    phaseId: s.phaseId,
    phaseDir: s.phaseDir,
    inPhaseStatus: s.inPhaseStatus,
    reviewHeading: s.reviewHeading,
    briefExists: s.briefExists,
    stories: s.stories,
    storiesAllDone: s.storiesAllDone,
    progress: s.progress,
    progressStatus: s.progressStatus,
    progressExists: s.progressExists,
    storiesExists: s.storiesExists,
    staleInputs: s.staleInputs,
    buildAllDone: s.buildAllDone,
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
  if (args.amendCurrent && !args.scope) {
    process.stderr.write("[mano state] --amend-current can only be used with --scope.\n");
    process.exit(1);
  }
  if ((args.source !== null && (!args.scope || !String(args.source).trim())) ||
      (args.track !== null && (!args.scope || !String(args.track).trim()))) {
    process.stderr.write("[mano state] --source and --track require non-empty text and can only be used with --scope.\n");
    process.exit(1);
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
    s = scan(args.root, { source: args.source, track: args.track });
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
  } else if (args.scope && args.amendCurrent) {
    out = renderAmendCurrent(s);
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
  readProgress,
  countBacklogStatuses,
  extractBacklogItems,
  assertBacklogItemsWellFormed,
  backlogItemTrack,
  resumeDraftTrack,
  extractCoreProductPrinciples,
  extractLatestReview,
  hasReviewEntry,
  scanHooks,
  scanArtifacts,
  scanGaps,
  scanSpec,
  scanUi,
  scan,
  renderAmendCurrent,
  amendBlocker,
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
