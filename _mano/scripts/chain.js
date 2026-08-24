#!/usr/bin/env node
"use strict";

/**
 * Record the planning actions a human removed from a proposed auto chain.
 *
 * An armed chain is otherwise derived, not stored: what is on disk says which
 * planning artifacts exist and the ledger says whether implementation is done,
 * so a fresh session recomputes the remaining chain without help. Exactly one
 * thing is not derivable — that the human looked at the proposed chain and
 * *removed* an action ("go, skip ui"). Recompute it and you re-propose the
 * action they just declined; store the whole chain and you own a second copy of
 * state the filesystem already answers, which drifts the moment an artifact is
 * written outside the chain.
 *
 * So this script stores the subtraction and nothing else. `mano start` writes it
 * only when the approval reply actually edited the proposed chain; a default
 * chain costs no record at all.
 *
 * Storage is local Git config, exactly like `mano mode`: a chain edit is a
 * property of how this human is running this clone, not of the project, and
 * must not be committed.
 */

const path = require("node:path");
const childProcess = require("node:child_process");
const { parsePhaseDirName } = require("./phase.js");

// The planning actions a chain can contain, and therefore the only ones a human
// can remove from one. Implementation is the chain's terminal action and is
// never skippable — a chain that stops before implementation is a chain that
// did nothing. `review` is never in a chain at all.
const SKIPPABLE = ["spec", "ux", "rules", "ui", "stories"];

const HELP = `mano chain — record planning actions removed from a proposed auto chain

Usage:
  node chain.js show [--phase <phase-id>] [projectRoot]
  node chain.js skip --phase <phase-id> --actions <a,b,...> [projectRoot]
  node chain.js clear --phase <phase-id> [projectRoot]

skip     record that the human removed these actions when they approved the
         scope. Only ${SKIPPABLE.join(", ")} may be skipped; implementation is a
         chain's terminal action and is never optional.
show     print the recorded skips for one phase, or for every phase.
clear    forget a phase's record (a re-approval that restores an action).

The record is a subtraction, not a chain: everything else is derived fresh from
what exists on disk, so an interrupted session recomputes the rest by itself.
It is stored in local Git config as mano.chain.<phase-id> and is not committed.`;

function fail(message) {
  process.stderr.write(`[mano chain] ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = {
    help: argv.includes("--help") || argv.includes("-h"),
    command: null,
    phase: null,
    actions: null,
    root: null,
  };
  const positional = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--help" || a === "-h") continue;
    else if (a === "--phase") args.phase = argv[++i];
    else if (a === "--actions") args.actions = argv[++i];
    else positional.push(a);
  }
  args.command = positional[0] || "show";
  args.root = path.resolve(positional[1] || process.cwd());
  return args;
}

function runGit(root, gitArgs, allowMissing = false) {
  const result = childProcess.spawnSync("git", gitArgs, { cwd: root, encoding: "utf8" });
  if (result.status === 0) return result;
  // 1 is "key not found" on --get, 5 is "no such section" on --unset.
  if (allowMissing && (result.status === 1 || result.status === 5)) return result;
  const detail = String(result.stderr || result.stdout || "git command failed").trim();
  fail(`${detail}. Chain records require a Git checkout.`);
}

function validatePhaseId(value) {
  const id = String(value == null ? "" : value).trim();
  if (!id) fail("--phase needs a phase id, e.g. phase-3 or alice-phase-3");
  if (!parsePhaseDirName(id)) {
    fail(`${JSON.stringify(id)} is not a phase id; use the exact PHASE_ID from the state projection`);
  }
  return id;
}

function validateActions(value) {
  const raw = String(value == null ? "" : value)
    .split(",")
    .map((part) => part.trim().toLowerCase())
    .filter(Boolean);
  if (!raw.length) fail(`--actions needs at least one of: ${SKIPPABLE.join(", ")}`);
  const seen = [];
  for (const action of raw) {
    if (!SKIPPABLE.includes(action)) {
      fail(
        `${JSON.stringify(action)} cannot be skipped; a chain's terminal action is implementation. ` +
          `Skippable: ${SKIPPABLE.join(", ")}`,
      );
    }
    if (!seen.includes(action)) seen.push(action);
  }
  // Stored in the chain's own order, not the order they were typed, so `show`
  // reads the same for the same set.
  return SKIPPABLE.filter((action) => seen.includes(action));
}

/** Read one phase's recorded skips. Returns [] when nothing is recorded. */
function readSkipped(root, phaseId) {
  const result = childProcess.spawnSync(
    "git",
    ["config", "--local", "--get", `mano.chain.${phaseId}`],
    { cwd: root, encoding: "utf8" },
  );
  if (result.status !== 0) return [];
  return String(result.stdout || "")
    .trim()
    .split(",")
    .map((part) => part.trim())
    .filter(Boolean);
}

/** Every phase with a record, as { phaseId, skipped } rows. */
function readAll(root) {
  const result = childProcess.spawnSync(
    "git",
    ["config", "--local", "--get-regexp", "^mano\\.chain\\."],
    { cwd: root, encoding: "utf8" },
  );
  if (result.status !== 0) return [];
  const rows = [];
  for (const line of String(result.stdout || "").split("\n")) {
    const match = /^mano\.chain\.(\S+)\s+(.*)$/.exec(line.trim());
    if (!match) continue;
    const skipped = match[2].split(",").map((p) => p.trim()).filter(Boolean);
    if (skipped.length) rows.push({ phaseId: match[1], skipped });
  }
  return rows;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(HELP + "\n");
    return;
  }
  if (!["show", "skip", "clear"].includes(args.command)) {
    fail(`unknown command ${JSON.stringify(args.command)}; use show, skip, or clear`);
  }

  if (args.command === "skip") {
    const phaseId = validatePhaseId(args.phase);
    const actions = validateActions(args.actions);
    runGit(args.root, ["rev-parse", "--git-dir"]);
    runGit(args.root, ["config", "--local", `mano.chain.${phaseId}`, actions.join(",")]);
    process.stdout.write(`[mano chain] ${phaseId} — skipped: ${actions.join(", ")}\n`);
    process.stdout.write("  Recorded so a later session does not re-propose them. Not committed.\n");
    return;
  }

  if (args.command === "clear") {
    const phaseId = validatePhaseId(args.phase);
    runGit(args.root, ["rev-parse", "--git-dir"]);
    runGit(args.root, ["config", "--local", "--unset-all", `mano.chain.${phaseId}`], true);
    process.stdout.write(`[mano chain] ${phaseId} — record cleared\n`);
    return;
  }

  runGit(args.root, ["rev-parse", "--git-dir"]);
  if (args.phase) {
    const phaseId = validatePhaseId(args.phase);
    const skipped = readSkipped(args.root, phaseId);
    process.stdout.write(
      skipped.length
        ? `[mano chain] ${phaseId} — skipped: ${skipped.join(", ")}\n`
        : `[mano chain] ${phaseId} — no record; the chain is derived from what exists on disk\n`,
    );
    return;
  }
  const rows = readAll(args.root);
  if (!rows.length) {
    process.stdout.write("[mano chain] no records; every chain is derived from what exists on disk\n");
    return;
  }
  for (const row of rows) {
    process.stdout.write(`[mano chain] ${row.phaseId} — skipped: ${row.skipped.join(", ")}\n`);
  }
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    fail(error && error.message ? error.message : String(error));
  }
}

module.exports = { SKIPPABLE, parseArgs, readSkipped, readAll, validateActions, main };
