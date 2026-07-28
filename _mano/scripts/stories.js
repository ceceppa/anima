#!/usr/bin/env node
"use strict";

/**
 * mano stories-index — the deterministic writer for a phase's stories README
 * index (`_mano_output/phase-<N>/stories/README.md`).
 *
 * Sibling to backlog.js. Same contract, different file:
 *
 *   1. It owns the index *row format* (`| # | Story | File | Status |`). The
 *      same table is parsed by state.js (readStories) to decide whether a phase
 *      is built; writer and reader must agree on the shape, so the shape lives
 *      in exactly one writer.
 *   2. It performs only mechanical edits already decided elsewhere — appending a
 *      row mano stories just authored, or flipping a status mano dev just earned
 *      by implementing a story. It never decides what to build or when a story
 *      is done; the skill and the human own that. Format-correct executor, not
 *      an autonomous agent.
 *
 * Why a script: the status flip is the stories-index twin of `backlog.js
 * assign`. It runs on mano dev — the small-context coding model — which today
 * hand-edits a markdown table that state.js parses and mano review gates on. A
 * mis-aligned pipe or fat-fingered cell corrupts a file two other skills
 * depend on. A deterministic flip removes that, and the positional row insert
 * (story-3a between 3 and 4) is exactly the table edit a weak model botches.
 *
 * Commands:
 *   add-row     append/insert a story row (creates the index if absent)
 *   set-status  flip one or more rows to a new status (e.g. pending -> done)
 *
 * Usage:
 *   node stories.js add-row --phase 9 --story 3 --title "Widget layout" \
 *        --file story-3-widget-layout.md [--status pending] [--project "App"]
 *   node stories.js set-status --phase 9 --story 3 --status done
 *   node stories.js set-status --phase 9 --story 2 --story 3 --status done
 *   node stories.js --help
 *
 * A `--story` value is an integer (`3`) or a sub-numbered insertion (`3a`). A
 * trailing positional arg is the project root (default: current dir).
 *
 * Exit code 0 on success (including "no matching row", which is reported).
 * Non-zero only on bad input (missing flags, no index for set-status).
 */

const fs = require("node:fs");
const path = require("node:path");

const HEADER_ROW = "| # | Story | File | Status |";
const SEPARATOR_ROW = "|---|-------|------|--------|";
// A row whose first cell is an integer optionally followed by letters (3, 3a).
const STORY_NUM = /^\d+[a-z]*$/i;

const HELP = `mano stories-index — deterministic writer for phase-<N>/stories/README.md

Commands:
  add-row     append/insert a story row (creates the index if absent)
  set-status  flip one or more rows to a new status (e.g. pending -> done)

add-row:
  --phase N         the phase whose index to write (required)
  --story <n>       row number: an integer (3) or sub-insertion (3a) (required)
  --title "..."     the story's short title (required)
  --file "..."      the story filename, e.g. story-3-widget-layout.md (required)
  --status <s>      optional (default: pending)
  --project "..."   optional; used only in the header when the index is created
  Rows are inserted in numeric order (3a sorts right after 3). A row whose
  number already exists is skipped.

set-status:
  --phase N         the phase whose index to edit (required)
  --story <n>       row number to flip, repeatable (required)
  --status <s>      the new status, e.g. done (required)
  Reports any --story it can't find, and rows already at that status.

A trailing positional argument = project root (default: current dir).

This script writes. It owns the index row format and performs only edits
already decided by the skill and the human — it never decides scope or done.`;

// ---- args -----------------------------------------------------------------

function parseArgs(argv) {
  const args = {
    command: null, root: process.cwd(), help: false,
    phase: null, stories: [], title: null, file: null, status: null, project: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--help" || a === "-h") args.help = true;
    else if (a === "--phase") args.phase = argv[++i];
    else if (a === "--story" || a === "--num") args.stories.push(argv[++i]);
    else if (a === "--title") args.title = argv[++i];
    else if (a === "--file") args.file = argv[++i];
    else if (a === "--status") args.status = argv[++i];
    else if (a === "--project") args.project = argv[++i];
    else if (a === "--root") args.root = path.resolve(argv[++i]);
    else if (!a.startsWith("-")) {
      if (!args.command) args.command = a;
      else args.root = path.resolve(a); // second positional = projectRoot
    }
  }
  return args;
}

function indexPath(root, phase) {
  return path.join(root, "_mano_output", `phase-${phase}`, "stories", "README.md");
}

function readText(p) {
  try { return fs.readFileSync(p, "utf8"); } catch { return null; }
}

function fail(msg) {
  process.stderr.write(`[mano stories] ${msg}\n`);
  process.exit(1);
}

function requirePhase(args) {
  if (args.phase == null || !/^\d+$/.test(String(args.phase))) {
    fail(`${args.command} needs --phase <N> (an integer).`);
  }
}

// ---- shared row parsing (must round-trip with state.js readStories) --------

// Split a markdown table line into trimmed cells with the outer pipes dropped.
// Returns null if the line is not a table row at all.
function rowCells(line) {
  if (!line.includes("|")) return null;
  const cells = line.split("|").map((c) => c.trim());
  while (cells.length && cells[0] === "") cells.shift();
  while (cells.length && cells[cells.length - 1] === "") cells.pop();
  return cells;
}

// A data row = a table row whose first cell is a story number. Returns the
// number string (e.g. "3", "3a") or null.
function rowStoryNum(line) {
  const cells = rowCells(line);
  if (!cells || cells.length < 4) return null;
  return STORY_NUM.test(cells[0]) ? cells[0] : null;
}

function formatRow(num, title, file, status) {
  return `| ${num} | ${title} | ${file} | ${status} |`;
}

// Sort key so 3 < 3a < 3b < 4 < 10.
function numKey(numStr) {
  const m = /^(\d+)([a-z]*)$/i.exec(String(numStr).trim());
  if (!m) return [Number.MAX_SAFE_INTEGER, String(numStr)];
  return [parseInt(m[1], 10), m[2].toLowerCase()];
}

function keyLess(a, b) {
  const ka = numKey(a), kb = numKey(b);
  if (ka[0] !== kb[0]) return ka[0] < kb[0];
  return ka[1] < kb[1];
}

// ---- add-row --------------------------------------------------------------

function freshIndex(project, phase, row) {
  const title = project && String(project).trim()
    ? `# Stories — ${String(project).trim()} — Phase ${phase}`
    : `# Stories — Phase ${phase}`;
  return `${title}\n\n${HEADER_ROW}\n${SEPARATOR_ROW}\n${row}\n`;
}

function cmdAddRow(args) {
  requirePhase(args);
  if (args.stories.length !== 1) fail("add-row needs exactly one --story <n>.");
  const num = String(args.stories[0]).trim();
  if (!STORY_NUM.test(num)) fail(`add-row: --story "${num}" is not a valid number (e.g. 3 or 3a).`);
  if (!args.title || !String(args.title).trim()) fail("add-row needs --title.");
  if (!args.file || !String(args.file).trim()) fail("add-row needs --file.");

  const status = (args.status && String(args.status).trim()) || "pending";
  const row = formatRow(num, String(args.title).trim(), String(args.file).trim(), status);

  const file = indexPath(args.root, args.phase);
  const existing = readText(file);

  if (existing == null) {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, freshIndex(args.project, args.phase, row));
    process.stdout.write(`[mano stories] add-row → created index, 1 row\n  + ${num} ${String(args.title).trim()}\n`);
    return;
  }

  const lines = existing.split("\n");

  // Duplicate guard: a row with this number already exists.
  const dataIdx = [];
  for (let i = 0; i < lines.length; i++) {
    const n = rowStoryNum(lines[i]);
    if (n != null) {
      if (n.toLowerCase() === num.toLowerCase()) {
        process.stdout.write(`[mano stories] add-row → 0 written, 1 skipped\n  ~ ${num} (already in index, skipped)\n`);
        return;
      }
      dataIdx.push(i);
    }
  }

  let insertAt;
  if (dataIdx.length === 0) {
    // Table header exists but no data rows yet: insert after the separator, or
    // after the header row, or (no table at all) append a fresh table.
    const sepIdx = lines.findIndex((l) => /^\s*\|?[\s:|-]+\|?\s*$/.test(l) && l.includes("-") && l.includes("|"));
    if (sepIdx !== -1) insertAt = sepIdx + 1;
    else {
      const trimmed = existing.replace(/\s+$/, "");
      fs.writeFileSync(file, `${trimmed}\n\n${HEADER_ROW}\n${SEPARATOR_ROW}\n${row}\n`);
      process.stdout.write(`[mano stories] add-row → added table + 1 row\n  + ${num} ${String(args.title).trim()}\n`);
      return;
    }
  } else {
    // Insert before the first existing row whose number is greater; else after
    // the last data row.
    const after = dataIdx.find((i) => keyLess(num, rowStoryNum(lines[i])));
    insertAt = after !== undefined ? after : dataIdx[dataIdx.length - 1] + 1;
  }

  lines.splice(insertAt, 0, row);
  fs.writeFileSync(file, lines.join("\n"));
  process.stdout.write(`[mano stories] add-row → 1 written\n  + ${num} ${String(args.title).trim()}\n`);
}

// ---- set-status -----------------------------------------------------------

function cmdSetStatus(args) {
  requirePhase(args);
  if (args.stories.length === 0) fail("set-status needs at least one --story <n>.");
  if (!args.status || !String(args.status).trim()) fail("set-status needs --status <s>.");
  const status = String(args.status).trim();

  const file = indexPath(args.root, args.phase);
  const text = readText(file);
  if (text == null) fail(`set-status: no stories index at ${file}.`);

  const want = new Map();
  for (const s of args.stories) want.set(String(s).trim().toLowerCase(), { story: String(s).trim(), outcome: "not-found", was: null });

  const lines = text.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const num = rowStoryNum(lines[i]);
    if (num == null) continue;
    const key = num.toLowerCase();
    if (!want.has(key)) continue;
    const cells = rowCells(lines[i]);
    const rec = want.get(key);
    rec.was = cells[cells.length - 1];
    if (rec.was.toLowerCase() === status.toLowerCase()) { rec.outcome = "same"; continue; }
    // Rebuild canonically: num | title | file | status. Middle cells preserved.
    const title = cells[1] != null ? cells[1] : "";
    const fileCell = cells[2] != null ? cells[2] : "";
    lines[i] = formatRow(cells[0], title, fileCell, status);
    rec.outcome = "set";
  }

  const results = [...want.values()];
  const changed = results.filter((r) => r.outcome === "set");
  if (changed.length) fs.writeFileSync(file, lines.join("\n"));

  process.stdout.write(`[mano stories] set-status → ${changed.length} set to '${status}'` +
    (results.length - changed.length ? `, ${results.length - changed.length} unchanged` : "") + "\n");
  for (const r of results) {
    if (r.outcome === "set") process.stdout.write(`  + ${r.story} (${r.was} → ${status})\n`);
    else if (r.outcome === "same") process.stdout.write(`  ~ ${r.story} (already '${status}', left as-is)\n`);
    else process.stdout.write(`  ? ${r.story} (no matching row — check the number)\n`);
  }
}

// ---- main -----------------------------------------------------------------

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || !args.command) {
    process.stdout.write(HELP + "\n");
    process.exit(args.help ? 0 : 1);
  }
  if (args.command === "add-row") cmdAddRow(args);
  else if (args.command === "set-status") cmdSetStatus(args);
  else fail(`unknown command "${args.command}". Use add-row or set-status (--help for usage).`);
}

main();
