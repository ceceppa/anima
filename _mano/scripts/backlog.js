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
 *   2. It performs only mechanical edits already authorized by the owning Mano
 *      skill's contract (and, where required, human approval). It never decides
 *      what to scope, defer, or consider addressed. This is a format-correct
 *      executor, not an autonomous agent.
 *
 * Commands:
 *   add      append item(s) under `## Items`
 *   assign   move approved items from `Status: backlog` to `in-phase-<N>`
 *   resolve  mano review's close sweep: `in-phase-<N>` -> `resolved` (whole phase)
 *   resolve-gap  mark one exact spec-gap / rule-gap item resolved
 *   reject   mark named open items `rejected` (premise invalidated, won't do)
 *
 * Usage:
 *   node backlog.js add --title "X" --type feature --context "..." [--source "..."] [--track "..."]
 *   node backlog.js add --file items.json        (JSON array, for bulk)
 *   node backlog.js assign --phase 9 --title "X" --title "Y"
 *   node backlog.js resolve --phase 9
 *   node backlog.js resolve-gap --type spec-gap --title "Exact title"
 *   node backlog.js reject --title "X" --title "Y"
 *   node backlog.js --help
 *
 * The `add` input is a single item from flags (the shell-safe path — no JSON to
 * quote, works the same in bash and fish), or a JSON array via --file / stdin
 * for bulk. In a --context value, a literal `\n` becomes a line break. A
 * trailing positional arg is the project root (default: current dir).
 *
 * Exit code 0 on success. Non-zero on bad input or when resolve-gap cannot
 * identify one safe exact target; failed targeted resolves never write.
 */

const fs = require("node:fs");
const path = require("node:path");
const { phaseRef, phaseRouting, validateTrack } = require("./phase.js");

const VALID_TYPES = ["bug", "refinement", "feature", "tech-debt", "test", "spec-gap", "rule-gap"];
const GAP_TYPES = ["spec-gap", "rule-gap"];
const ITEMS_HEADING = "## Items";

const HELP = `mano backlog — deterministic writer for _mano_output/backlog.md

Commands:
  add      append item(s) under '## Items'
  assign   move approved items from 'Status: backlog' to the configured phase
  resolve  mano review's close sweep for the configured phase identity
  resolve-gap  flip one exact open spec-gap / rule-gap item to 'resolved'
  reject   flip named open items to 'rejected' (premise invalidated, won't do)

add — one item from flags (the shell-safe path):
  --title "..."     required
  --type <type>     required: ${VALID_TYPES.join(", ")}
  --context "..."   required; a literal \\n becomes a line break (max 5 lines)
  --source "..."    optional provenance
  --track "..."     optional work track / experiment
  --status <s>      optional (default: backlog)
add — many items at once:
  --file items.json   a JSON array of { title, type, context, source?, track?, status? }
                      (or pipe that JSON array on stdin)
  Items whose title already exists are skipped (exact, case-insensitive).
  Output prints each item's Track. Missing or empty tracks print as 'undefined'.

assign:
  --phase N         the configured owner's phase number (required)
  --title "..."     one per approved item, repeatable
  Uses phase-N by default; owner opt-in uses <owner>-phase-N.
  Flips only non-gap items currently 'Status: backlog'; reports anything it
  can't. spec-gap / rule-gap items stay backlog-owned by mano spec / mano rules.

resolve:
  --phase N         the configured owner's phase being closed (required)
  Flips every item with that exact phase identity's in-phase status to
  'resolved'. Not title-scoped — it never sweeps another owner's phase, so
  items still 'Status: backlog' (e.g. this review's freshly triaged items) are
  never touched.

resolve-gap:
  --type <type>      required: spec-gap or rule-gap
  --title "..."      required: one exact item title
  Resolves only the unique item with that exact title, exact type, and
  'Status: backlog'. An already-resolved matching item is an idempotent success.
  Ambiguous, missing, malformed, wrong-type, or in-phase targets fail without
  changing the file.

reject:
  --title "..."     one per human-approved item, repeatable
  Flips each exact-titled item from 'Status: backlog' to 'Status: rejected' —
  the item's premise was invalidated (e.g. its feature was rejected in review),
  distinct from 'resolved' (shipped/fixed). Only open 'backlog' items flip;
  in-phase, resolved, ambiguous, or missing targets are reported and left
  unchanged. Already-rejected items are an idempotent success.

A trailing positional argument = project root (default: current dir).

This script writes. It owns the item *format* and performs only edits authorized
by the owning skill's contract — it never decides scope or whether a gap was
addressed.`;

// ---- args -----------------------------------------------------------------

function parseArgs(argv) {
  const args = {
    command: null, root: process.cwd(), help: false,
    phase: null, titles: [],
    title: null, type: null, context: null, source: null, track: null, status: null, file: null,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--help" || a === "-h") args.help = true;
    else if (a === "--phase") args.phase = argv[++i];
    else if (a === "--title") { const v = argv[++i]; args.title = v; args.titles.push(v); }
    else if (a === "--type") args.type = argv[++i];
    else if (a === "--context") args.context = argv[++i];
    else if (a === "--source") args.source = argv[++i];
    else if (a === "--track") args.track = argv[++i];
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

function configuredPhase(args, command) {
  if (args.phase == null || !/^\d+$/.test(String(args.phase)) || Number(args.phase) < 1) {
    fail(`${command} needs --phase <N> (a positive integer).`);
  }
  try {
    return phaseRef(phaseRouting(args.root).owner, Number(args.phase));
  } catch (error) {
    fail(`${command}: ${error.message}`);
  }
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
  if (it.track != null && String(it.track).trim() !== "") {
    L.push(`- **Track:** ${String(it.track).trim()}`);
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
  if (it.track != null && String(it.track).trim() !== "") {
    try {
      validateTrack(it.track);
    } catch (error) {
      return `${where}: ${error.message}`;
    }
  }
  const contextLines = String(it.context).replace(/\r/g, "").split("\n");
  while (contextLines.length && contextLines[0].trim() === "") contextLines.shift();
  while (contextLines.length && contextLines[contextLines.length - 1].trim() === "") contextLines.pop();
  if (contextLines.length > 5) return `${where}: context has ${contextLines.length} lines (max 5)`;
  return null;
}

function displayTrack(it) {
  if (it.track == null || String(it.track).trim() === "") return "undefined";
  return String(it.track).trim();
}

function printAddItem(marker, it, note = "") {
  process.stdout.write(`  ${marker} ${String(it.title).trim()}${note}\n`);
  process.stdout.write(`    Track: ${displayTrack(it)}\n`);
}

// Item titles already present under the canonical `## Items` section.
function existingTitles(text) {
  const set = new Set();
  if (text == null) return set;
  for (const record of parseItemRecords(text).records) {
    set.add(record.title.toLowerCase());
  }
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
      track: args.track,
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
  const lines = trimmed.split("\n");

  const itemsIdx = lines.findIndex((l) => new RegExp(`^${ITEMS_HEADING}\\s*$`, "i").test(l));
  if (itemsIdx === -1) {
    // File exists (e.g. only Core Product Principles so far) but no Items section.
    return `${trimmed}\n\n${ITEMS_HEADING}\n\n${body}\n`;
  }

  // Insert before the next top-level section after "## Items" (or at EOF).
  let insertAt = lines.length;
  for (let i = itemsIdx + 1; i < lines.length; i++) {
    if (/^##\s+/.test(lines[i])) {
      insertAt = i;
      break;
    }
  }

  const before = lines.slice(0, insertAt).join("\n").replace(/\s+$/, "");
  const after = lines.slice(insertAt).join("\n").replace(/^\s+/, "");
  return after ? `${before}\n\n${body}\n\n${after}\n` : `${before}\n\n${body}\n`;
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
    if (present.has(key) || seen.has(key)) { skipped.push(it); continue; }
    seen.add(key);
    kept.push(it);
  }

  if (kept.length === 0) {
    process.stdout.write(`[mano backlog] add → 0 written, ${skipped.length} skipped (duplicate title)\n`);
    skipped.forEach((it) => printAddItem("~", it, " (duplicate, skipped)"));
    return;
  }

  const blocks = kept.map(formatItem);
  const next = buildWithItems(existing, blocks);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, next);

  process.stdout.write(`[mano backlog] add → ${kept.length} written` + (skipped.length ? `, ${skipped.length} skipped (duplicate title)` : "") + "\n");
  kept.forEach((it) => printAddItem("+", it));
  skipped.forEach((it) => printAddItem("~", it, " (duplicate, skipped)"));
}

// ---- assign ---------------------------------------------------------------

function cmdAssign(args) {
  const ref = configuredPhase(args, "assign");
  if (args.titles.length === 0) fail("assign needs at least one --title.");
  if (args.titles.some((title) => typeof title !== "string" || !title.trim())) {
    fail("assign needs a non-empty value after every --title.");
  }
  const file = backlogPath(args.root);
  const text = readText(file);
  if (text == null) fail(`assign: no backlog at ${file}.`);

  // Defense in depth: state.js --scope excludes gaps, but the writer also
  // refuses them if a caller names one directly. Read only canonical top-level
  // Type fields; an indented metadata-shaped Context line is not item metadata.
  const protectedGaps = new Map();
  const parsedItems = parseItemRecords(text);
  for (const record of parsedItems.records) {
    for (let i = record.start + 1; i < record.end; i++) {
      const typeMatch = /^-\s*\*\*Type:\*\*\s*(.+?)\s*$/i.exec(parsedItems.lines[i]);
      if (!typeMatch) continue;
      const type = typeMatch[1].trim().toLowerCase();
      if (GAP_TYPES.includes(type)) {
        protectedGaps.set(record.title.toLowerCase(), type);
      }
    }
  }

  // Track outcome per requested title.
  const want = new Map();
  for (const t of args.titles) {
    want.set(t.trim().toLowerCase(), {
      title: t.trim(), outcome: "not-found", status: null, type: null,
    });
  }

  const lines = text.split("\n");
  let curKey = null;
  let inItems = false;
  for (let i = 0; i < lines.length; i++) {
    if (/^##\s+Items\s*$/i.test(lines[i])) {
      inItems = true;
      curKey = null;
      continue;
    }
    if (/^##\s+/.test(lines[i])) {
      inItems = false;
      curKey = null;
      continue;
    }
    if (!inItems) continue;
    const h = /^###\s+(.+?)\s*$/.exec(lines[i]);
    if (h) { curKey = h[1].trim().toLowerCase(); continue; }
    if (curKey && want.has(curKey)) {
      const m = /^(-\s*\*\*Status:\*\*\s*)(.+?)\s*$/i.exec(lines[i]);
      if (m) {
        const cur = m[2].trim().toLowerCase();
        const rec = want.get(curKey);
        rec.status = cur;
        if (protectedGaps.has(curKey)) {
          rec.type = protectedGaps.get(curKey);
          rec.outcome = "gap";
        }
        else if (cur === "backlog") { lines[i] = `${m[1]}${ref.inPhaseStatus}`; rec.outcome = "assigned"; }
        else rec.outcome = "skipped";
      }
    }
  }

  const results = [...want.values()];
  const assigned = results.filter((r) => r.outcome === "assigned");
  if (assigned.length) fs.writeFileSync(file, lines.join("\n"));

  process.stdout.write(`[mano backlog] assign → ${ref.id}: ${assigned.length} assigned` +
    (results.length - assigned.length ? `, ${results.length - assigned.length} unchanged` : "") + "\n");
  for (const r of results) {
    if (r.outcome === "assigned") process.stdout.write(`  + ${r.title}\n`);
    else if (r.outcome === "gap") {
      const owner = r.type === "spec-gap" ? "mano spec" : "mano rules";
      process.stdout.write(`  ~ ${r.title} (${r.type}; route to ${owner}, left as '${r.status}')\n`);
    }
    else if (r.outcome === "skipped") process.stdout.write(`  ~ ${r.title} (already '${r.status}', left as-is)\n`);
    else process.stdout.write(`  ? ${r.title} (no matching item — check the title, or split first)\n`);
  }
}

// ---- resolve --------------------------------------------------------------

// mano review's close sweep and the twin of assign: flip every item currently
// carrying the configured phase's exact in-phase status to `Status: resolved`.
// Freshly-added `Status: backlog` items (the items review triaged this same
// turn) are never touched. Not title-scoped — it sweeps the whole phase.
function cmdResolve(args) {
  const ref = configuredPhase(args, "resolve");
  const want = ref.inPhaseStatus;

  const file = backlogPath(args.root);
  const text = readText(file);
  if (text == null) fail(`resolve: no backlog at ${file}.`);

  const lines = text.split("\n");
  let curTitle = null;
  let inItems = false;
  const flipped = [];
  for (let i = 0; i < lines.length; i++) {
    if (/^##\s+Items\s*$/i.test(lines[i])) {
      inItems = true;
      curTitle = null;
      continue;
    }
    if (/^##\s+/.test(lines[i])) {
      inItems = false;
      curTitle = null;
      continue;
    }
    if (!inItems) continue;
    const h = /^###\s+(.+?)\s*$/.exec(lines[i]);
    if (h) { curTitle = h[1].trim(); continue; }
    const m = /^(-\s*\*\*Status:\*\*\s*)(.+?)\s*$/i.exec(lines[i]);
    if (m && m[2].trim().toLowerCase() === want) {
      lines[i] = `${m[1]}resolved`;
      flipped.push(curTitle || "(untitled)");
    }
  }

  if (flipped.length) fs.writeFileSync(file, lines.join("\n"));
  process.stdout.write(`[mano backlog] resolve → ${ref.id}: ${flipped.length} item(s) marked resolved\n`);
  if (flipped.length === 0) process.stdout.write(`  (no items with Status: ${want})\n`);
  for (const t of flipped) process.stdout.write(`  + ${t}\n`);
}

// ---- resolve-gap ----------------------------------------------------------

// Parse only `###` item blocks under the canonical `## Items` section. Ranges
// are line-index based and end-exclusive so a validated status line can be
// changed without re-rendering any other backlog content.
function parseItemRecords(text) {
  const lines = text.split("\n");
  const records = [];
  let inItems = false;
  let cur = null;
  const flush = (end) => {
    if (!cur) return;
    cur.end = end;
    records.push(cur);
    cur = null;
  };

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (/^##\s+Items\s*$/i.test(line)) {
      flush(i);
      inItems = true;
    } else if (/^##\s+/.test(line)) {
      flush(i);
      inItems = false;
    } else if (inItems) {
      const heading = /^###\s+(.+?)\s*$/.exec(line);
      if (heading) {
        flush(i);
        cur = { title: heading[1].trim(), start: i, end: null };
      }
    }
  }
  flush(lines.length);
  return { lines, records };
}

function itemField(lines, record, label) {
  const re = label === "Type"
    ? /^(-\s*\*\*Type:\*\*\s*)(.+?)(\s*)$/i
    : /^(-\s*\*\*Status:\*\*\s*)(.+?)(\s*)$/i;
  const found = [];
  for (let i = record.start + 1; i < record.end; i++) {
    const match = re.exec(lines[i]);
    if (match) {
      found.push({
        line: i,
        prefix: match[1],
        value: match[2].trim().toLowerCase(),
        trailing: match[3],
      });
    }
  }
  if (found.length !== 1) {
    return {
      error: `${record.title}: expected exactly one **${label}:** line, found ${found.length}`,
    };
  }
  return found[0];
}

// A deliberately stricter writer than the phase-wide resolve. Gap owners name
// one projected item and its expected type; every condition is validated before
// the sole status line is changed.
function cmdResolveGap(args) {
  if (!GAP_TYPES.includes(String(args.type || "").trim())) {
    fail(`resolve-gap needs --type ${GAP_TYPES.join(" or ")}.`);
  }
  if (args.titles.length !== 1) {
    fail("resolve-gap needs exactly one --title.");
  }

  const expectedType = String(args.type).trim();
  if (typeof args.titles[0] !== "string" || !args.titles[0].trim()) {
    fail("resolve-gap needs a non-empty value after --title.");
  }
  const requestedTitle = args.titles[0].trim();

  const file = backlogPath(args.root);
  const text = readText(file);
  if (text == null) fail(`resolve-gap: no backlog at ${file}.`);

  const parsed = parseItemRecords(text);
  const key = requestedTitle.toLowerCase();
  const matches = parsed.records.filter((record) => record.title.toLowerCase() === key);
  if (matches.length === 0) {
    fail(`resolve-gap: no item has the exact title "${requestedTitle}".`);
  }
  if (matches.length > 1) {
    fail(`resolve-gap: title "${requestedTitle}" is ambiguous (${matches.length} exact matches).`);
  }

  const record = matches[0];
  const type = itemField(parsed.lines, record, "Type");
  const status = itemField(parsed.lines, record, "Status");
  if (type.error) fail(`resolve-gap: malformed item — ${type.error}.`);
  if (status.error) fail(`resolve-gap: malformed item — ${status.error}.`);
  if (type.value !== expectedType) {
    fail(`resolve-gap: "${record.title}" is type "${type.value}", not "${expectedType}".`);
  }
  if (status.value === "resolved") {
    process.stdout.write(`[mano backlog] resolve-gap → ${expectedType}: already resolved\n`);
    process.stdout.write(`  ~ ${record.title} (already 'resolved', left as-is)\n`);
    return;
  }
  if (status.value !== "backlog") {
    fail(`resolve-gap: "${record.title}" has Status: ${status.value}; only backlog gaps can be resolved here.`);
  }

  parsed.lines[status.line] = `${status.prefix}resolved${status.trailing}`;
  fs.writeFileSync(file, parsed.lines.join("\n"));
  process.stdout.write(`[mano backlog] resolve-gap → ${expectedType}: 1 item marked resolved\n`);
  process.stdout.write(`  + ${record.title}\n`);
}

// ---- reject ---------------------------------------------------------------

// mano review's scope-retirement writer: flip each human-approved title from
// `Status: backlog` to `Status: rejected`. Title-scoped and backlog-only —
// in-phase items belong to their phase's resolve sweep, and `rejected` stays
// distinct from `resolved` (shipped/fixed) so backlog history reads honestly.
function cmdReject(args) {
  if (args.titles.length === 0) fail("reject needs at least one --title.");
  if (args.titles.some((title) => typeof title !== "string" || !title.trim())) {
    fail("reject needs a non-empty value after every --title.");
  }

  const file = backlogPath(args.root);
  const text = readText(file);
  if (text == null) fail(`reject: no backlog at ${file}.`);

  const parsed = parseItemRecords(text);
  const results = [];
  const seen = new Set();
  for (const raw of args.titles) {
    const requested = raw.trim();
    const key = requested.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    const matches = parsed.records.filter((record) => record.title.toLowerCase() === key);
    if (matches.length === 0) {
      results.push({ title: requested, outcome: "not-found" });
      continue;
    }
    if (matches.length > 1) {
      results.push({ title: requested, outcome: "ambiguous", count: matches.length });
      continue;
    }
    const record = matches[0];
    const status = itemField(parsed.lines, record, "Status");
    if (status.error) {
      results.push({ title: record.title, outcome: "malformed", error: status.error });
      continue;
    }
    if (status.value === "rejected") {
      results.push({ title: record.title, outcome: "already" });
      continue;
    }
    if (status.value !== "backlog") {
      results.push({ title: record.title, outcome: "skipped", status: status.value });
      continue;
    }
    parsed.lines[status.line] = `${status.prefix}rejected${status.trailing}`;
    results.push({ title: record.title, outcome: "rejected" });
  }

  const rejected = results.filter((r) => r.outcome === "rejected");
  if (rejected.length) fs.writeFileSync(file, parsed.lines.join("\n"));

  process.stdout.write(`[mano backlog] reject → ${rejected.length} item(s) marked rejected` +
    (results.length - rejected.length ? `, ${results.length - rejected.length} unchanged` : "") + "\n");
  for (const r of results) {
    if (r.outcome === "rejected") process.stdout.write(`  + ${r.title}\n`);
    else if (r.outcome === "already") process.stdout.write(`  ~ ${r.title} (already 'rejected', left as-is)\n`);
    else if (r.outcome === "skipped") process.stdout.write(`  ~ ${r.title} (Status: ${r.status}; only open 'backlog' items can be rejected, left as-is)\n`);
    else if (r.outcome === "ambiguous") process.stdout.write(`  ? ${r.title} (ambiguous — ${r.count} exact matches, left as-is)\n`);
    else if (r.outcome === "malformed") process.stdout.write(`  ? ${r.title} (malformed item — ${r.error})\n`);
    else process.stdout.write(`  ? ${r.title} (no matching item — check the title)\n`);
  }
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
  else if (args.command === "resolve-gap") cmdResolveGap(args);
  else if (args.command === "reject") cmdReject(args);
  else fail(`unknown command "${args.command}". Use add, assign, resolve, resolve-gap, or reject (--help for usage).`);
}

if (require.main === module) main();

module.exports = {
  VALID_TYPES,
  GAP_TYPES,
  ITEMS_HEADING,
  parseArgs,
  backlogPath,
  formatItem,
  validateItem,
  displayTrack,
  existingTitles,
  parseItemRecords,
  itemField,
  buildWithItems,
  collectAddItems,
  main,
};
