#!/usr/bin/env node
"use strict";

/**
 * mano backlog — the deterministic writer for _mano_output/backlog.md.
 *
 * Unlike state.js (a read-only projection), this script WRITES. Two things make
 * that safe and worth it:
 *
 *   1. It is the single source of truth for the backlog item *format*. mano
 *      start / import / review used to each re-spell the `### title /
 *      **Type:** / **Status:**` block, and those copies drifted. Now they emit
 *      content and this script owns the shape.
 *   2. It performs only mechanical edits the human has already approved during
 *      scoping. It never decides what to scope or what to defer — the skill and
 *      the human own every decision. This is a format-correct executor, not an
 *      autonomous agent.
 *
 * Commands:
 *   add      append item(s) under `## Items`
 *   assign   move approved items from `Status: backlog` to `in-phase-<N>`
 *   resolve  mano review's close sweep: `in-phase-<N>` -> `resolved` (whole phase)
 *
 * Usage:
 *   node backlog.js add --title "X" --type feature --context "..." [--source "..."]
 *   node backlog.js add --file items.json        (JSON array, for bulk)
 *   node backlog.js assign --phase 9 --title "X" --title "Y"
 *   node backlog.js resolve --phase 9
 *   node backlog.js --help
 *
 * The `add` input is a single item from flags (the shell-safe path — no JSON to
 * quote, works the same in bash and fish), or a JSON array via --file / stdin
 * for bulk. In a --context value, a literal `\n` becomes a line break. A
 * trailing positional arg is the project root (default: current dir).
 *
 * Exit code 0 on success (including "nothing matched", which is reported).
 * Non-zero only on bad input (malformed JSON, unknown type, missing --phase).
 */

const fs = require("node:fs");
const path = require("node:path");

const VALID_TYPES = ["bug", "refinement", "feature", "tech-debt", "test", "spec-gap", "rule-gap"];
const ITEMS_HEADING = "## Items";

const HELP = `mano backlog — deterministic writer for _mano_output/backlog.md

Commands:
  add      append item(s) under '## Items'
  assign   move approved items from 'Status: backlog' to 'in-phase-<N>'
  resolve  mano review's close sweep: flip every 'in-phase-<N>' to 'resolved'

add — one item from flags (the shell-safe path):
  --title "..."     required
  --type <type>     required: ${VALID_TYPES.join(", ")}
  --context "..."   required; a literal \\n becomes a line break (max 5 lines)
  --source "..."    optional provenance
  --status <s>      optional (default: backlog)
add — many items at once:
  --file items.json   a JSON array of { title, type, context, source?, status? }
                      (or pipe that JSON array on stdin)
  Items whose title already exists are skipped (exact, case-insensitive).

assign:
  --phase N         the phase the approved items enter (required)
  --title "..."     one per approved item, repeatable
  Flips only items currently 'Status: backlog'; reports anything it can't.

resolve:
  --phase N         the phase being closed (required)
  Flips every item currently 'Status: in-phase-<N>' to 'resolved'. Not
  title-scoped — it sweeps the whole phase. Matches only 'in-phase-<N>', so
  items still 'Status: backlog' (e.g. this review's freshly triaged items) are
  never touched.

A trailing positional argument = project root (default: current dir).

This script writes. It owns the item *format* and performs only edits already
approved during scoping — it never decides scope.`;

// ---- args -----------------------------------------------------------------

function parseArgs(argv) {
  const args = {
    command: null, root: process.cwd(), help: false,
    phase: null, titles: [],
    title: null, type: null, context: null, source: null, status: null, file: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--help" || a === "-h") args.help = true;
    else if (a === "--phase") args.phase = argv[++i];
    else if (a === "--title") { const v = argv[++i]; args.title = v; args.titles.push(v); }
    else if (a === "--type") args.type = argv[++i];
    else if (a === "--context") args.context = argv[++i];
    else if (a === "--source") args.source = argv[++i];
    else if (a === "--status") args.status = argv[++i];
    else if (a === "--file") args.file = argv[++i];
    else if (a === "--root") args.root = path.resolve(argv[++i]);
    else if (!a.startsWith("-")) {
      if (!args.command) args.command = a;
      else args.root = path.resolve(a); // second positional = projectRoot
    }
  }
  return args;
}

function backlogPath(root) {
  return path.join(root, "_mano_output", "backlog.md");
}

function readText(p) {
  try { return fs.readFileSync(p, "utf8"); } catch { return null; }
}

function fail(msg) {
  process.stderr.write(`[mano backlog] ${msg}\n`);
  process.exit(1);
}

// ---- shared format --------------------------------------------------------

// Render one item exactly as the spec defines it. This is the only place the
// block shape lives.
function formatItem(it) {
  const L = [`### ${String(it.title).trim()}`];
  L.push(`- **Type:** ${String(it.type).trim()}`);
  if (it.source != null && String(it.source).trim() !== "") {
    L.push(`- **Source:** ${String(it.source).trim()}`);
  }
  L.push(`- **Context:**`);
  const ctx = String(it.context).replace(/\r/g, "").split("\n").map((l) => l.replace(/\s+$/, ""));
  while (ctx.length && ctx[0] === "") ctx.shift();
  while (ctx.length && ctx[ctx.length - 1] === "") ctx.pop();
  for (const line of ctx) L.push(`  ${line}`);
  L.push(`- **Status:** ${String(it.status || "backlog").trim()}`);
  return L.join("\n");
}

function validateItem(it, idx) {
  const where = `item ${idx + 1}`;
  if (!it || typeof it !== "object") return `${where}: not an object`;
  if (!it.title || !String(it.title).trim()) return `${where}: missing "title"`;
  if (!it.type || !String(it.type).trim()) return `${where}: missing "type"`;
  if (!VALID_TYPES.includes(String(it.type).trim())) {
    return `${where}: type "${it.type}" is not one of ${VALID_TYPES.join(", ")}`;
  }
  if (it.context == null || !String(it.context).trim()) return `${where}: missing "context"`;
  const contextLines = String(it.context).replace(/\r/g, "").split("\n");
  while (contextLines.length && contextLines[0].trim() === "") contextLines.shift();
  while (contextLines.length && contextLines[contextLines.length - 1].trim() === "") contextLines.pop();
  if (contextLines.length > 5) return `${where}: context has ${contextLines.length} lines (max 5)`;
  return null;
}

// Titles already present in the file (lowercased), from `### ` headings.
function existingTitles(text) {
  const set = new Set();
  if (text == null) return set;
  const re = /^###\s+(.+?)\s*$/gm;
  let m;
  while ((m = re.exec(text)) !== null) set.add(m[1].trim().toLowerCase());
  return set;
}

// ---- add ------------------------------------------------------------------

function readStdin() {
  try { return fs.readFileSync(0, "utf8"); } catch { return ""; }
}

function parseJsonArray(raw, where) {
  let parsed;
  try { parsed = JSON.parse(raw); } catch (e) { fail(`add: ${where} is not valid JSON — ${e.message}`); }
  const items = Array.isArray(parsed) ? parsed : [parsed];
  if (items.length === 0) fail(`add: ${where} has no items.`);
  return items;
}

// Where add's items come from: a single item from flags (shell-safe), a JSON
// array from --file, or a JSON array piped on stdin.
function collectAddItems(args) {
  if (args.title != null) {
    return [{
      title: args.title,
      type: args.type,
      context: args.context != null ? args.context.replace(/\\n/g, "\n") : args.context,
      source: args.source,
      status: args.status,
    }];
  }
  if (args.file != null) {
    const raw = readText(path.resolve(args.file));
    if (raw == null) fail(`add: cannot read --file ${args.file}`);
    return parseJsonArray(raw.trim(), `--file ${args.file}`);
  }
  if (process.stdin.isTTY) {
    fail("add: pass --title (one item) or --file <json> (bulk). Nothing was piped on stdin.");
  }
  const raw = readStdin().trim();
  if (!raw) fail("add: no input. Pass --title (one item), --file <json>, or pipe a JSON array.");
  return parseJsonArray(raw, "stdin");
}

function buildWithItems(existing, blocks) {
  const body = blocks.join("\n\n");
  if (existing == null) {
    return `# Backlog\n\n${ITEMS_HEADING}\n\n${body}\n`;
  }
  const trimmed = existing.replace(/\s+$/, "");
  if (!new RegExp(`^${ITEMS_HEADING}\\s*$`, "m").test(trimmed)) {
    // File exists (e.g. only Core Product Principles so far) but no Items section.
    return `${trimmed}\n\n${ITEMS_HEADING}\n\n${body}\n`;
  }
  return `${trimmed}\n\n${body}\n`;
}

function cmdAdd(args) {
  const items = collectAddItems(args);

  const errors = [];
  items.forEach((it, i) => { const e = validateItem(it, i); if (e) errors.push(e); });
  if (errors.length) fail("add: invalid input —\n  " + errors.join("\n  "));

  const file = backlogPath(args.root);
  const existing = readText(file);
  const present = existingTitles(existing);

  const kept = [];
  const skipped = [];
  const seen = new Set();
  for (const it of items) {
    const key = String(it.title).trim().toLowerCase();
    if (present.has(key) || seen.has(key)) { skipped.push(String(it.title).trim()); continue; }
    seen.add(key);
    kept.push(it);
  }

  if (kept.length === 0) {
    process.stdout.write(`[mano backlog] add → 0 written, ${skipped.length} skipped (duplicate title)\n`);
    skipped.forEach((t) => process.stdout.write(`  ~ ${t} (duplicate, skipped)\n`));
    return;
  }

  const blocks = kept.map(formatItem);
  const next = buildWithItems(existing, blocks);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, next);

  process.stdout.write(`[mano backlog] add → ${kept.length} written` + (skipped.length ? `, ${skipped.length} skipped (duplicate title)` : "") + "\n");
  kept.forEach((it) => process.stdout.write(`  + ${String(it.title).trim()}\n`));
  skipped.forEach((t) => process.stdout.write(`  ~ ${t} (duplicate, skipped)\n`));
}

// ---- assign ---------------------------------------------------------------

function cmdAssign(args) {
  if (args.phase == null || !/^\d+$/.test(String(args.phase))) {
    fail("assign needs --phase <N> (an integer).");
  }
  if (args.titles.length === 0) fail("assign needs at least one --title.");
  const phase = Number(args.phase);

  const file = backlogPath(args.root);
  const text = readText(file);
  if (text == null) fail(`assign: no backlog at ${file}.`);

  // Track outcome per requested title.
  const want = new Map();
  for (const t of args.titles) want.set(t.trim().toLowerCase(), { title: t.trim(), outcome: "not-found", status: null });

  const lines = text.split("\n");
  let curKey = null;
  for (let i = 0; i < lines.length; i++) {
    const h = /^###\s+(.+?)\s*$/.exec(lines[i]);
    if (h) { curKey = h[1].trim().toLowerCase(); continue; }
    if (/^##\s+/.test(lines[i])) { curKey = null; continue; }
    if (curKey && want.has(curKey)) {
      const m = /^(\s*-\s*\*\*Status:\*\*\s*)(.+?)\s*$/.exec(lines[i]);
      if (m) {
        const cur = m[2].trim().toLowerCase();
        const rec = want.get(curKey);
        rec.status = cur;
        if (cur === "backlog") { lines[i] = `${m[1]}in-phase-${phase}`; rec.outcome = "assigned"; }
        else rec.outcome = "skipped";
      }
    }
  }

  const results = [...want.values()];
  const assigned = results.filter((r) => r.outcome === "assigned");
  if (assigned.length) fs.writeFileSync(file, lines.join("\n"));

  process.stdout.write(`[mano backlog] assign → phase ${phase}: ${assigned.length} assigned` +
    (results.length - assigned.length ? `, ${results.length - assigned.length} unchanged` : "") + "\n");
  for (const r of results) {
    if (r.outcome === "assigned") process.stdout.write(`  + ${r.title}\n`);
    else if (r.outcome === "skipped") process.stdout.write(`  ~ ${r.title} (already '${r.status}', left as-is)\n`);
    else process.stdout.write(`  ? ${r.title} (no matching item — check the title, or split first)\n`);
  }
}

// ---- resolve --------------------------------------------------------------

// mano review's close sweep and the twin of assign: flip every item currently
// `Status: in-phase-<N>` to `Status: resolved`. It matches only in-phase-<N>,
// so freshly-added `Status: backlog` items (the items review triaged this same
// turn) are never touched. Not title-scoped — it sweeps the whole phase.
function cmdResolve(args) {
  if (args.phase == null || !/^\d+$/.test(String(args.phase))) {
    fail("resolve needs --phase <N> (an integer).");
  }
  const phase = Number(args.phase);
  const want = `in-phase-${phase}`;

  const file = backlogPath(args.root);
  const text = readText(file);
  if (text == null) fail(`resolve: no backlog at ${file}.`);

  const lines = text.split("\n");
  let curTitle = null;
  const flipped = [];
  for (let i = 0; i < lines.length; i++) {
    const h = /^###\s+(.+?)\s*$/.exec(lines[i]);
    if (h) { curTitle = h[1].trim(); continue; }
    if (/^##\s+/.test(lines[i])) { curTitle = null; continue; }
    const m = /^(\s*-\s*\*\*Status:\*\*\s*)(.+?)\s*$/.exec(lines[i]);
    if (m && m[2].trim().toLowerCase() === want) {
      lines[i] = `${m[1]}resolved`;
      flipped.push(curTitle || "(untitled)");
    }
  }

  if (flipped.length) fs.writeFileSync(file, lines.join("\n"));
  process.stdout.write(`[mano backlog] resolve → phase ${phase}: ${flipped.length} item(s) marked resolved\n`);
  if (flipped.length === 0) process.stdout.write(`  (no items with Status: in-phase-${phase})\n`);
  for (const t of flipped) process.stdout.write(`  + ${t}\n`);
}

// ---- main -----------------------------------------------------------------

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || !args.command) {
    process.stdout.write(HELP + "\n");
    process.exit(args.help ? 0 : 1);
  }
  if (args.command === "add") cmdAdd(args);
  else if (args.command === "assign") cmdAssign(args);
  else if (args.command === "resolve") cmdResolve(args);
  else fail(`unknown command "${args.command}". Use add, assign, or resolve (--help for usage).`);
}

main();
