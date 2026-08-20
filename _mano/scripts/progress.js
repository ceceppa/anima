#!/usr/bin/env node
"use strict";

/**
 * mano progress — the deterministic writer for a phase's build ledger
 * (`_mano_output/phase-<N>/progress.md`).
 *
 * Sibling to stories.js and backlog.js. Same contract, different file — with
 * one addition that is the whole point of this script:
 *
 *   `init` takes no content. It reads the phase brief and emits both tables
 *   itself. The ledger's rows are the human's own `## Phase Scope` items and
 *   `## Exit Criteria` leaves, addressed by their brief numbers. Verbatim
 *   copying stops being a rule a model can violate and becomes a property of a
 *   parser, which deletes a class of drift instead of testing for it.
 *
 * The other commands perform only mechanical edits already decided elsewhere:
 * a status flip `mano build` earned by implementing, a split of the row it is
 * currently building, a correction row carrying the user's own words, a rework
 * event carrying a review finding, or the human's sign-off at review. The
 * script never decides what to build or when something is done.
 *
 * The row grammar, the parser, the validator, and the renderer all live in
 * `ledger.js`, shared with `state.js`. Two copies of a row regex is how the
 * reader came to disagree with the writer about what a lettered row means.
 *
 * Three properties hold for every command here:
 *
 *   Fail closed. A ledger that does not validate is `invalid` and the only
 *   repair is to delete it and re-run `mano build`. Nothing is best-effort
 *   parsed, and no refusal writes a partial file.
 *
 *   Identity guarded. Every mutation takes `--expect-phase-id` and refuses when
 *   the owner or phase resolved now differs from the one the caller saw in the
 *   projection it is acting on.
 *
 *   Atomic. Every write goes through `writeAtomic`, so an interrupt leaves the
 *   previous ledger intact rather than a truncated one.
 *
 * Text never travels on the command line. Every text-bearing argument is a
 * `--*-file` path: quotes, backticks, `$()`, and newlines all break through a
 * shell, and `fish` expands sequences other shells do not.
 *
 * Usage:
 *   node progress.js init --phase 3 --expect-phase-id phase-3
 *   node progress.js set-status --phase 3 --expect-phase-id phase-3 --row S2 --status done
 *   node progress.js split --phase 3 --expect-phase-id phase-3 --row S2 --part-file a.txt
 *   node progress.js add-row --phase 3 --expect-phase-id phase-3 --parent S2 \
 *        --text-file words.txt --exit E1b
 *   node progress.js request-rework --phase 3 --expect-phase-id phase-3 --text-file f.txt
 *   node progress.js resolve-rework --phase 3 --expect-phase-id phase-3 --id R1 --status resolved
 *   node progress.js sign-off --phase 3 --expect-phase-id phase-3
 *   node progress.js --help
 *
 * A trailing positional arg is the project root (default: current dir).
 *
 * Exit code 0 only when every requested row was written or already correct. A
 * refusal writes nothing at all, so a caller can trust a successful run.
 */

const fs = require("node:fs");
const path = require("node:path");
const { phaseRef, phaseRouting, parsePhaseDirName } = require("./phase.js");
const { writeAtomic } = require("./atomic.js");
const L = require("./ledger.js");

const HELP = `mano progress — deterministic writer for the configured phase's progress.md

Commands:
  init            parse the phase brief and write both ledger tables (once per phase)
  set-status      flip one or more rows to a new status
  split           append dot-numbered sub-rows under the row being built
  add-row         append a human correction row under an existing item
  request-rework  append an ordered review finding
  resolve-rework  close one rework event
  sign-off        record the human's sign-off across the Exit Criteria

Every command takes:
  --phase N               the configured owner's phase number (required)
  --expect-phase-id ID    the PHASE_ID the caller saw in the state projection
                          (required on every mutation; refuses on mismatch)

init:
  Reads PHASE_DIR/phase-brief.md and emits a Scope row per '## Phase Scope'
  leaf and an Exit Criteria row per '## Exit Criteria' leaf. A two-level scope
  gives S1a/S1b/S2a, a flat one gives S1/S2/S3. Takes no content:
  the rows are the brief's own text. Refuses when a ledger already exists, when
  a stories index exists, and when either section has no list to parse.

set-status:
  --row <id>              row to flip, repeatable (S2, S2a, S2.1, S2a+1, E2c)
  --status <s>            S rows: pending|doing|done. E rows: pending|met|needs-human.
  --reopen                required for any backwards move
  --reason-file <path>    required for needs-human
  A --status applies to every --row before it that has none yet. A roll-up
  parent's status is derived from its children and cannot be written directly.

split:
  --row <id>              the row being built; must be actionable and 'doing'
  --part-file <path>      one sub-row's exact text, repeatable (required)

add-row:
  --parent <id>           an existing normal row (S2, S2a) — never a correction
  --text-file <path>      the user's own words, verbatim (required)
  --exit <E-id>           the Exit Criterion this correction changes (required)
  --exit-text-file <path> optional: exact wording for a new Exit leaf under --exit

request-rework:
  --text-file <path>      one finding's exact text, repeatable (required)

resolve-rework:
  --id R<n>               the event to close (required)
  --status <s>            resolved|dismissed
  --reason-file <path>    required for dismissed — the human's exact authorisation

sign-off:
  Flips every pending and needs-human Exit leaf to met and records who proved
  it. Typing 'close it' at review is a human attestation; this is its record.

A trailing positional argument = project root (default: current dir).

This script owns the ledger row format and performs only edits already decided
by the human and the skill — it never decides scope, or when work is done.`;

// ---- args -----------------------------------------------------------------

function parseArgs(argv) {
  const args = {
    command: null, root: process.cwd(), help: false,
    phase: null, expectPhaseId: null, entries: [], partFiles: [], textFiles: [],
    parent: null, exit: null, exitTextFile: null, reasonFile: null, id: null,
    status: null, legacyText: null, legacyParts: [],
  };
  let current = null;
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--help" || a === "-h") args.help = true;
    else if (a === "--phase") args.phase = argv[++i];
    else if (a === "--expect-phase-id") args.expectPhaseId = argv[++i];
    else if (a === "--row") {
      current = { row: argv[++i], status: null, reopen: false };
      args.entries.push(current);
    } else if (a === "--status") {
      const status = argv[++i];
      args.status = status;
      // Bind to every row that has no status yet, so a shared trailing
      // --status and per-row pairing both read the way they look.
      const open = args.entries.filter((e) => e.status === null);
      for (const e of open) e.status = status;
      if (open.length === 0 && args.entries.length) args.danglingStatus = status;
    } else if (a === "--reopen") {
      if (current) current.reopen = true;
      else args.danglingReopen = true;
    } else if (a === "--part-file") args.partFiles.push(argv[++i]);
    else if (a === "--text-file") args.textFiles.push(argv[++i]);
    else if (a === "--exit-text-file") args.exitTextFile = argv[++i];
    else if (a === "--reason-file") args.reasonFile = argv[++i];
    else if (a === "--parent") args.parent = argv[++i];
    else if (a === "--exit") args.exit = argv[++i];
    else if (a === "--id") args.id = argv[++i];
    else if (a === "--part") { args.legacyParts.push(argv[++i]); }
    else if (a === "--text") { args.legacyText = argv[++i]; }
    else if (a === "--root") args.root = path.resolve(argv[++i]);
    else if (!a.startsWith("-")) {
      if (!args.command) args.command = a;
      else args.root = path.resolve(a);
    }
  }
  return args;
}

function fail(msg) {
  process.stderr.write(`[mano build] ${msg}\n`);
  process.exit(1);
}

function out(msg) {
  process.stdout.write(msg);
}

function readText(p) {
  try { return fs.readFileSync(p, "utf8"); } catch { return null; }
}

/**
 * Read a text-bearing argument from a file, preserving it exactly.
 *
 * Only the trailing newline a text editor adds is dropped; nothing else is
 * touched, because this text is the human's own words and becomes the row's
 * authoritative contract.
 */
function readContractText(file, label) {
  if (!file) fail(`${label} is required and takes a file path, never inline text.`);
  const text = readText(path.resolve(file));
  if (text === null) fail(`${label}: cannot read ${file}`);
  const trimmed = text.replace(/\n$/, "");
  if (!trimmed.trim()) fail(`${label}: ${file} is empty.`);
  return trimmed;
}

function refuseInlineText(args) {
  if (args.legacyText !== null || args.legacyParts.length) {
    fail(
      "text arguments travel as files, not inline: use --text-file / --part-file. " +
      "Quotes, backticks, $(), and newlines do not survive a shell round-trip, " +
      "and the row's exact text is its contract.",
    );
  }
}

// ---- identity -------------------------------------------------------------

/**
 * Resolve the phase this command may touch, or refuse.
 *
 * B3: build wrote `done`/`met` and only afterwards checked owner and phase,
 * while the path was resolved from whatever owner was configured at invocation
 * time. An owner change mid-implementation therefore mutated a different
 * owner's same-numbered phase. The caller now passes the exact PHASE_ID it saw
 * in the projection it is acting on, and a mismatch writes nothing.
 */
function resolveRef(args, { requireExpect = true } = {}) {
  if (args.phase == null || !/^\d+$/.test(String(args.phase)) || Number(args.phase) < 1) {
    fail(`${args.command} needs --phase <N> (a positive integer).`);
  }
  const number = Number(args.phase);
  let configured;
  try {
    configured = phaseRouting(args.root).owner;
  } catch (error) {
    fail(`${args.command}: ${error.message}`);
  }

  if (!requireExpect && args.expectPhaseId == null) {
    return phaseRef(configured, number);
  }
  if (args.expectPhaseId == null) {
    fail(
      `${args.command} needs --expect-phase-id <PHASE_ID> — the exact PHASE_ID from the ` +
      "state projection you are acting on. Without it a mutation cannot tell that the " +
      "owner or phase changed underneath it.",
    );
  }
  const expected = parsePhaseDirName(String(args.expectPhaseId).trim());
  if (!expected) {
    fail(`${args.command}: "${args.expectPhaseId}" is not a phase id (phase-3, alice-phase-3).`);
  }
  if (expected.number !== number) {
    fail(
      `${args.command}: --phase ${number} and --expect-phase-id ${expected.id} disagree. ` +
      "Re-run state.js --next and use the values it printed.",
    );
  }
  if ((expected.owner || null) !== (configured || null)) {
    fail(
      `${args.command}: identity changed. You expected ${expected.id}, but the owner ` +
      `configured now is ${configured ? configured : "none (legacy phase-N mode)"}. ` +
      "Nothing was written. Re-run state.js --next and act on what it reports.",
    );
  }
  try {
    return phaseRef(expected.owner, number);
  } catch (error) {
    fail(`${args.command}: ${error.message}`);
  }
}

function progressPath(root, ref) {
  return path.join(root, ref.relativeDir, "progress.md");
}

function briefPath(root, ref) {
  return path.join(root, ref.relativeDir, "phase-brief.md");
}

function storiesPath(root, ref) {
  return path.join(root, ref.relativeDir, "stories", "README.md");
}

// ---- load -----------------------------------------------------------------

/**
 * Read, validate, and digest-check the ledger, or refuse.
 *
 * The digest check is D12: the addressed brief — Phase Goal, Phase Scope, Not
 * This Phase, Exit Criteria — is immutable once a ledger exists, because every
 * row address points into it. An edit there fails closed rather than silently
 * repointing rows at text that moved.
 */
function loadLedger(args, ref) {
  const file = progressPath(args.root, ref);
  const text = readText(file);
  if (text === null) {
    fail(
      `${args.command}: no ledger at ${ref.relativeDir}/progress.md. ` +
      `Run 'progress.js init --phase ${ref.number} --expect-phase-id ${ref.id}' first.`,
    );
  }
  const parsed = L.parseLedger(text);
  if (!parsed.ok) {
    fail(
      `${args.command}: ${ref.relativeDir}/progress.md is invalid and nothing was written:\n` +
      parsed.errors.map((e) => `  - ${e}`).join("\n") +
      "\n  Delete progress.md and re-run mano build. There is no repair-in-place path.",
    );
  }
  const brief = readText(briefPath(args.root, ref));
  if (brief === null) {
    fail(`${args.command}: no phase brief at ${ref.relativeDir}/phase-brief.md; nothing was written.`);
  }
  const digest = L.contractDigest(brief);
  if (digest !== parsed.ledger.contract) {
    fail(
      `${args.command}: the phase brief changed after this ledger was created ` +
      `(contract ${parsed.ledger.contract} → ${digest}); nothing was written.\n` +
      "  The addressed brief — Phase Goal, Phase Scope, Not This Phase, Exit Criteria — is\n" +
      "  immutable while a ledger exists, because every row address points into it. An\n" +
      "  in-goal nuance is a correction (add-row); a distinct outcome goes to the backlog\n" +
      "  or the next phase.",
    );
  }
  return { file, ledger: parsed.ledger, brief };
}

/**
 * Re-render the whole ledger from the parsed model.
 *
 * The ledger is script-owned, so a canonical render is always correct and
 * removes the line-index bookkeeping that a splice-in-place writer needs. Row
 * order comes from the comparator, never from incidental file order.
 */
function save(file, ledger) {
  ledger.scope.sort((a, b) => L.compareRows(a.parsed, b.parsed));
  ledger.exit.sort((a, b) => L.compareRows(a.parsed, b.parsed));
  ledger.rework.sort((a, b) => a.number - b.number);

  // Contracts render in row order so the section stays scannable beside the
  // tables it explains.
  const ordered = new Map();
  for (const row of [...ledger.scope, ...ledger.exit, ...ledger.rework]) {
    const body = ledger.contracts.get(row.id);
    if (body && (body.text !== null || Object.keys(body.attributes || {}).length)) {
      ordered.set(row.id, body);
    }
  }
  writeAtomic(file, L.renderLedger({
    title: ledger.title,
    contract: ledger.contract,
    scope: ledger.scope,
    exit: ledger.exit,
    rework: ledger.rework,
    contracts: ordered,
  }));
}

/** Roll-up parents are derived, never written. Recompute them after any change. */
function refreshRollUps(ledger) {
  const promoted = [];
  const parents = L.rollUpIds(ledger.scope);
  // Deepest first, so a parent of a parent sees its children already settled.
  const ids = [...parents].sort((a, b) => L.compareRows(L.parseRowId(b), L.parseRowId(a)));
  for (const id of ids) {
    const parent = ledger.byId.get(id);
    if (!parent) continue;
    const derived = L.derivedParentStatus(L.splitChildrenOf(ledger.scope, id));
    if (parent.status !== derived) {
      promoted.push({ id, was: parent.status, now: derived });
      parent.status = derived;
    }
  }
  return promoted;
}

function setContract(ledger, id, body) {
  const existing = ledger.contracts.get(id) || { attributes: {}, text: null };
  ledger.contracts.set(id, {
    attributes: { ...existing.attributes, ...(body.attributes || {}) },
    text: body.text === undefined ? existing.text : body.text,
  });
}

// ---- init -----------------------------------------------------------------

function cmdInit(args) {
  const ref = resolveRef(args);
  const file = progressPath(args.root, ref);
  const stories = storiesPath(args.root, ref);
  if (fs.existsSync(file)) {
    fail(
      `init: ${ref.relativeDir}/progress.md already exists — the ledger is written once and ` +
      "stays authoritative. Use set-status, split, or add-row.",
    );
  }
  // Independent of state.js's own dual-ledger refusal, and deliberately so: a
  // phase has one ledger, and neither script may rely on the other having
  // looked.
  if (fs.existsSync(stories)) {
    fail(
      `init: ${ref.relativeDir} already holds stories/README.md. A phase has one ledger — ` +
      "mano stories + mano dev, or mano build. Keep the one that matches how this phase " +
      "was planned and remove the other.",
    );
  }
  const brief = readText(briefPath(args.root, ref));
  if (brief === null) {
    fail(`init: no phase brief at ${ref.relativeDir}/phase-brief.md — run mano start first.`);
  }

  const scope = L.parseScope(brief);
  const exit = L.parseExitCriteria(brief);
  const problems = [scope.error, exit.error].filter(Boolean);
  if (problems.length) {
    fail(
      `init: cannot parse the brief — ${problems.join("; ")}. ` +
      "The ledger is the brief's own list; inventing the split is not this script's job or the build's. " +
      "Route it to mano start to give the brief a numbered Phase Scope and lettered Exit Criteria.",
    );
  }

  const text = L.renderLedger({
    project: L.projectName(brief),
    phaseNumber: ref.number,
    owner: ref.owner,
    contract: L.contractDigest(brief),
    scope: scope.rows,
    exit: exit.rows,
  });

  fs.mkdirSync(path.dirname(file), { recursive: true });
  // Re-check immediately before writing: between the checks above and here,
  // another session may have created either ledger.
  if (fs.existsSync(file) || fs.existsSync(stories)) {
    fail("init: a ledger appeared in this phase while init was running; nothing was written.");
  }
  writeAtomic(file, text);
  out(
    `[mano build] init → ${ref.relativeDir}/progress.md, ${scope.rows.length} scope row(s), ` +
    `${exit.rows.length} exit criterion row(s)\n`,
  );
  for (const r of [...scope.rows, ...exit.rows]) out(`  + ${r.id.padEnd(5)} ${r.label}\n`);
}

// ---- set-status -----------------------------------------------------------

function cmdSetStatus(args) {
  const ref = resolveRef(args);
  if (args.entries.length === 0) fail("set-status needs at least one --row <id>.");
  if (args.danglingStatus) fail("set-status: a --status must follow the --row it applies to.");

  const { file, ledger } = loadLedger(args, ref);
  const rollUps = L.rollUpIds(ledger.scope);

  // Validate every entry before writing any of them: a partial status write
  // would leave the ledger claiming something no caller asked for.
  const plan = [];
  const targets = new Set();
  for (const entry of args.entries) {
    const parsed = L.parseRowId(entry.row);
    if (!parsed) fail(`set-status: "${entry.row}" is not a row address (S2, S2a, S2.1, S2a+1, E2c).`);
    if (targets.has(parsed.id)) {
      fail(`set-status: ${parsed.id} appears twice in one call; nothing was written.`);
    }
    targets.add(parsed.id);
    if (entry.status === null) fail(`set-status: --row ${parsed.id} has no --status.`);
    const status = String(entry.status).trim().toLowerCase();
    const allowed = L.statusesFor(parsed.table);
    if (!allowed.includes(status)) {
      const other = parsed.table === "S" ? L.EXIT_STATUSES : L.SCOPE_STATUSES;
      const hint = other.includes(status)
        ? ` '${status}' belongs to the ${parsed.table === "S" ? "Exit Criteria" : "Scope"} table — built is not proven.`
        : "";
      fail(`set-status: ${parsed.id} takes ${allowed.join(" | ")}, not "${status}".${hint}`);
    }
    const row = ledger.byId.get(parsed.id);
    if (!row) fail(`set-status: no row ${parsed.id} in ${ref.relativeDir}/progress.md; no statuses changed.`);
    if (rollUps.has(parsed.id)) {
      fail(
        `set-status: ${parsed.id} is a roll-up over ${L.splitChildrenOf(ledger.scope, parsed.id).map((c) => c.id).join(", ")}. ` +
        "Its status is derived from its children and committed with the child that closes it; " +
        "flip the child instead. Nothing was written.",
      );
    }
    const backwards = L.rank(parsed.table, status) < L.rank(parsed.table, row.status);
    if (backwards && !entry.reopen) {
      fail(
        `set-status: ${parsed.id} would move backwards (${row.status} → ${status}) without --reopen. ` +
        "A reopened row is a deviation the human must see; pass --reopen and report it.",
      );
    }
    plan.push({ row, parsed, status, reopen: entry.reopen, was: row.status });
  }

  // `needs-human` is a terminal handoff (D1), not a mid-build escape hatch for
  // a missing test, unavailable tooling, or a failed check.
  const needsHuman = plan.filter((p) => p.status === "needs-human");
  if (needsHuman.length) {
    const openScope = ledger.scope.filter((r) => !rollUps.has(r.id) && r.status !== "done");
    if (openScope.length) {
      fail(
        `set-status: needs-human is a terminal handoff, but ${openScope.map((r) => r.id).join(", ")} ` +
        "is still open. Finish the build first; a criterion you cannot prove yet stays pending.",
      );
    }
    const pendingRework = ledger.rework.filter((r) => r.status === "pending");
    if (pendingRework.length) {
      fail(
        `set-status: needs-human is refused while ${pendingRework.map((r) => r.id).join(", ")} ` +
        "is still pending. Resolve the review findings first.",
      );
    }
    const reason = readContractText(args.reasonFile, "set-status --reason-file");
    for (const step of needsHuman) setContract(ledger, step.row.id, { attributes: { reason } });
  }

  const changed = [];
  for (const step of plan) {
    if (step.was.toLowerCase() === step.status) continue;
    step.row.status = step.status;
    changed.push(step);
  }
  const promoted = refreshRollUps(ledger);

  if (changed.length || promoted.length || needsHuman.length) save(file, ledger);

  out(
    `[mano build] set-status → ${changed.length} row(s) set` +
    (plan.length - changed.length ? `, ${plan.length - changed.length} unchanged` : "") + "\n",
  );
  for (const step of plan) {
    if (step.was.toLowerCase() === step.status) out(`  ~ ${step.row.id} (already '${step.status}', left as-is)\n`);
    else out(`  ${step.reopen ? "!" : "+"} ${step.row.id} (${step.was} → ${step.status})${step.reopen ? " [reopened — report this]" : ""}\n`);
  }
  for (const p of promoted) out(`  = ${p.id} (${p.was} → ${p.now}, derived from its children)\n`);
}

// ---- split ----------------------------------------------------------------

function cmdSplit(args) {
  refuseInlineText(args);
  const ref = resolveRef(args);
  if (args.entries.length !== 1) fail("split needs exactly one --row <id>.");
  const parsed = L.parseRowId(args.entries[0].row);
  if (!parsed || parsed.table !== "S") {
    fail(
      `split: "${args.entries[0].row}" is not a scope row to split (S2, S2a, S2a+1). ` +
      "Exit Criteria are the human's leaves and are never split.",
    );
  }
  if (parsed.sub !== 0) fail("split: a split is decomposed further by splitting its own row, not by addressing a sub-row.");
  if (args.partFiles.length === 0) fail('split needs at least one --part-file <path>.');

  const { file, ledger } = loadLedger(args, ref);
  const parent = ledger.byId.get(parsed.id);
  if (!parent) fail(`split: no row ${parsed.id} in ${ref.relativeDir}/progress.md.`);
  if (parent.status !== "doing") {
    fail(
      `split: ${parsed.id} is '${parent.status}' — only the row currently being built may be split. ` +
      "Build cannot pre-decompose the ledger.",
    );
  }

  const existing = L.splitChildrenOf(ledger.scope, parsed.id);
  let next = existing.length ? Math.max(...existing.map((r) => r.parsed.sub)) + 1 : 1;
  const texts = args.partFiles.map((f, i) => readContractText(f, `split --part-file[${i + 1}]`));

  const added = [];
  for (let i = 0; i < texts.length; i++) {
    // The first part of a first split is the one already finished — a split is
    // legitimate only after a part is complete, so the ledger records that.
    const status = existing.length === 0 && i === 0 ? "done" : "pending";
    const sub = L.parseRowId(`${parsed.id}.${next++}`);
    const row = { id: sub.id, parsed: sub, label: L.deriveLabel(texts[i]), status };
    ledger.scope.push(row);
    ledger.byId.set(row.id, row);
    setContract(ledger, row.id, { text: texts[i] });
    added.push(row);
  }
  const promoted = refreshRollUps(ledger);
  save(file, ledger);

  out(`[mano build] split → ${parsed.id} into ${added.length} sub-row(s)\n`);
  for (const a of added) out(`  + ${a.id.padEnd(8)} ${a.status.padEnd(7)} ${a.label}\n`);
  for (const p of promoted) out(`  = ${p.id} (${p.was} → ${p.now}, derived from its children)\n`);
  out("  Sub-rows are the only ledger text build composes — show them to the human before writing more code.\n");
}

// ---- add-row --------------------------------------------------------------

function cmdAddRow(args) {
  refuseInlineText(args);
  const ref = resolveRef(args);
  if (!args.parent) {
    fail("add-row needs --parent <id> — an existing normal row the correction hangs off.");
  }
  const parent = L.parseRowId(args.parent);
  if (!parent || parent.table !== "S") {
    fail(`add-row: "${args.parent}" is not a scope row address (S2, S2a).`);
  }
  if (parent.kind !== "normal") {
    fail(
      `add-row: ${parent.id} is itself a ${parent.kind}. A correction hangs off the brief item it ` +
      "corrects, never off another correction or a split — a correction of a correction has no " +
      "contract to bound it. Correct the brief item instead.",
    );
  }
  if (!args.exit) {
    fail(
      "add-row needs --exit <E-id> — the Exit Criterion this correction changes. Without it the " +
      "phase can close with the correction built and its evidence never asked for.",
    );
  }

  const { file, ledger } = loadLedger(args, ref);
  const parentRow = ledger.byId.get(parent.id);
  if (!parentRow) {
    fail(
      `add-row: nothing in the ledger is addressed ${parent.id}, so a correction under it would be ` +
      "new scope, not a correction. Route it to mano start (amend the brief) or the backlog.",
    );
  }
  const exitParsed = L.parseRowId(args.exit);
  if (!exitParsed || exitParsed.table !== "E") fail(`add-row: "${args.exit}" is not an Exit Criterion address.`);
  const exitRow = ledger.byId.get(exitParsed.id);
  if (!exitRow) fail(`add-row: no Exit Criterion ${exitParsed.id} in ${ref.relativeDir}/progress.md.`);

  const text = readContractText(args.textFiles[0], "add-row --text-file");

  // Callers never choose a correction number: allocating it here is what makes
  // a `+1+1` chain unrepresentable.
  const siblings = L.correctionChildrenOf(ledger.scope, parent.id);
  const nextPlus = siblings.length ? Math.max(...siblings.map((r) => r.parsed.plus)) + 1 : 1;
  const parsed = L.parseRowId(`${parent.id}+${nextPlus}`);

  let affects = exitParsed.id;
  let newExit = null;
  if (args.exitTextFile) {
    // New wording for the promise this correction changes: a correction leaf
    // under the criterion it supersedes, so the original stays readable.
    const exitText = readContractText(args.exitTextFile, "add-row --exit-text-file");
    const exitSiblings = L.correctionChildrenOf(ledger.exit, exitParsed.id);
    const nextExitPlus = exitSiblings.length ? Math.max(...exitSiblings.map((r) => r.parsed.plus)) + 1 : 1;
    const exitId = L.parseRowId(`${exitParsed.id}+${nextExitPlus}`);
    newExit = { id: exitId.id, parsed: exitId, label: L.deriveLabel(exitText), status: "pending" };
    ledger.exit.push(newExit);
    ledger.byId.set(newExit.id, newExit);
    setContract(ledger, newExit.id, { text: exitText });
    affects = newExit.id;
  }

  const row = { id: parsed.id, parsed, label: L.deriveLabel(text), status: "pending" };
  ledger.scope.push(row);
  ledger.byId.set(row.id, row);
  setContract(ledger, row.id, { attributes: { affects }, text });
  const promoted = refreshRollUps(ledger);
  save(file, ledger);

  out(`[mano build] add-row → 1 written\n  + ${row.id.padEnd(8)} pending  ${row.label}\n`);
  out(`    affects ${affects}\n`);
  if (newExit) out(`  + ${newExit.id.padEnd(8)} pending  ${newExit.label}\n`);
  for (const p of promoted) out(`  = ${p.id} (${p.was} → ${p.now}, derived from its children)\n`);
  out("  A correction the brief did not authorise — run the gap check against it and show it to the human before code.\n");
}

// ---- rework ---------------------------------------------------------------

function cmdRequestRework(args) {
  refuseInlineText(args);
  const ref = resolveRef(args);
  if (args.textFiles.length === 0) fail("request-rework needs at least one --text-file <path>.");
  const { file, ledger } = loadLedger(args, ref);

  const texts = args.textFiles.map((f, i) => readContractText(f, `request-rework --text-file[${i + 1}]`));
  let next = ledger.rework.length ? Math.max(...ledger.rework.map((r) => r.number)) + 1 : 1;
  const added = [];
  for (const text of texts) {
    const event = { id: `R${next}`, number: next, label: L.deriveLabel(text), status: "pending" };
    next++;
    ledger.rework.push(event);
    setContract(ledger, event.id, { text });
    added.push(event);
  }
  save(file, ledger);

  out(`[mano build] request-rework → ${added.length} event(s) recorded\n`);
  for (const a of added) out(`  + ${a.id.padEnd(4)} pending  ${a.label}\n`);
  out("  Confirmed findings are durable state: they survive session loss and route to mano build.\n");
}

function cmdResolveRework(args) {
  refuseInlineText(args);
  const ref = resolveRef(args);
  const parsed = L.parseReworkId(args.id);
  if (!parsed) fail('resolve-rework needs --id R<n> (R1, R2, ...).');
  const status = String(args.status || "").trim().toLowerCase();
  if (!["resolved", "dismissed"].includes(status)) {
    fail('resolve-rework needs --status resolved|dismissed.');
  }
  const { file, ledger } = loadLedger(args, ref);
  const event = ledger.rework.find((r) => r.id === parsed.id);
  if (!event) fail(`resolve-rework: no event ${parsed.id} in ${ref.relativeDir}/progress.md.`);
  if (event.status !== "pending") {
    fail(`resolve-rework: ${parsed.id} is already '${event.status}'; nothing was written.`);
  }

  if (status === "dismissed") {
    // Dismissal discards a finding a human confirmed, so it carries that
    // human's exact authorisation and never a summary of it.
    const reason = readContractText(args.reasonFile, "resolve-rework --reason-file");
    setContract(ledger, event.id, { attributes: { "dismissed-reason": reason } });
  }
  event.status = status;
  save(file, ledger);
  out(`[mano build] resolve-rework → ${event.id} (pending → ${status})\n`);
}

// ---- sign-off -------------------------------------------------------------

function cmdSignOff(args) {
  const ref = resolveRef(args);
  const { file, ledger } = loadLedger(args, ref);
  const pendingRework = ledger.rework.filter((r) => r.status === "pending");
  if (pendingRework.length) {
    fail(
      `sign-off: ${pendingRework.map((r) => r.id).join(", ")} is still pending. ` +
      "Review does not close while a confirmed finding is open; nothing was written.",
    );
  }
  const stamp = new Date().toISOString().slice(0, 10);
  const provenance = `human sign-off at review, ${stamp}`;
  const flipped = [];
  const rollUps = L.rollUpIds(ledger.exit);
  for (const row of ledger.exit) {
    if (rollUps.has(row.id)) continue;
    if (row.status === "met") continue;
    flipped.push({ id: row.id, was: row.status });
    row.status = "met";
    // The ledger records *who* proved it. "Built is not proven" survives more
    // honestly as attributed evidence than as a status nobody owns.
    setContract(ledger, row.id, { attributes: { provenance } });
  }
  if (flipped.length) save(file, ledger);
  out(`[mano build] sign-off → ${flipped.length} exit criterion row(s) met by human attestation\n`);
  for (const f of flipped) out(`  + ${f.id.padEnd(8)} (${f.was} → met) ${provenance}\n`);
  if (!flipped.length) out("  Every criterion was already met; nothing to attest.\n");
}

// ---- main -----------------------------------------------------------------

const COMMANDS = {
  "init": cmdInit,
  "set-status": cmdSetStatus,
  "split": cmdSplit,
  "add-row": cmdAddRow,
  "request-rework": cmdRequestRework,
  "resolve-rework": cmdResolveRework,
  "sign-off": cmdSignOff,
};

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help || !args.command) {
    out(HELP + "\n");
    process.exit(args.help ? 0 : 1);
  }
  const run = COMMANDS[args.command];
  if (!run) {
    fail(`unknown command "${args.command}". Use ${Object.keys(COMMANDS).join(", ")} (--help for usage).`);
  }
  run(args);
}

if (require.main === module) main();

module.exports = {
  parseArgs, resolveRef, progressPath, briefPath, storiesPath,
  refreshRollUps, setContract, save, main,
};
