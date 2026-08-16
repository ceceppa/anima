#!/usr/bin/env node
"use strict";

/** Configure the optional local work track for one Mano checkout. */

const path = require("node:path");
const childProcess = require("node:child_process");
const { validateTrack, resolveConfiguredTrack } = require("./phase.js");

const HELP = `mano track — configure an optional work track for this repository clone

Usage:
  node track.js show [projectRoot]
  node track.js set "Option B" [projectRoot]
  node track.js clear [projectRoot]

The active track is stored in local Git config as mano.track and is not
committed. It tags new imports and conversational Start items, and narrows
mano start candidates. Review items copy the Track recorded in their phase
brief. MANO_TRACK overrides Git config for a shell/session.`;

function fail(message) {
  process.stderr.write(`[mano track] ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const positional = argv.filter((arg) => arg !== "--help" && arg !== "-h");
  const shorthand = positional[0] && !["show", "set", "clear"].includes(positional[0]);
  return {
    help: argv.includes("--help") || argv.includes("-h"),
    command: shorthand ? "set" : (positional[0] || "show"),
    value: shorthand ? positional[0] : (positional[0] === "set" ? positional[1] : null),
    root: path.resolve(positional[shorthand ? 1 : (positional[0] === "set" ? 2 : 1)] || process.cwd()),
  };
}

function runGit(root, args, allowMissing = false) {
  const result = childProcess.spawnSync("git", args, { cwd: root, encoding: "utf8" });
  if (result.status === 0) return result;
  if (allowMissing && result.status === 5) return result;
  const detail = String(result.stderr || result.stdout || "git command failed").trim();
  fail(`${detail}. Mano track configuration requires a Git checkout; alternatively set MANO_TRACK.`);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(HELP + "\n");
    return;
  }
  if (args.command === "set") {
    if (args.value == null) fail("set needs a track name");
    let track;
    try { track = validateTrack(args.value); } catch (error) { fail(error.message); }
    runGit(args.root, ["rev-parse", "--git-dir"]);
    runGit(args.root, ["config", "--local", "mano.track", track]);
    process.stdout.write(`[mano track] track set to ${JSON.stringify(track)} for this repository clone\n`);
    if (Object.prototype.hasOwnProperty.call(process.env, "MANO_TRACK")) {
      process.stdout.write(`  MANO_TRACK=${JSON.stringify(process.env.MANO_TRACK)} currently overrides that value\n`);
    }
    return;
  }
  if (args.command === "clear") {
    runGit(args.root, ["rev-parse", "--git-dir"]);
    runGit(args.root, ["config", "--local", "--unset-all", "mano.track"], true);
    process.stdout.write("[mano track] local track cleared; untracked planning is active unless MANO_TRACK is set\n");
    return;
  }
  if (args.command !== "show") fail(`unknown command ${JSON.stringify(args.command)}; use show, set, or clear`);
  let configured;
  try { configured = resolveConfiguredTrack(args.root); } catch (error) { fail(error.message); }
  if (!configured.track) process.stdout.write("[mano track] no track configured\n");
  else process.stdout.write(`[mano track] ${JSON.stringify(configured.track)} (${configured.source})\n`);
}

if (require.main === module) {
  try { main(); } catch (error) { fail(error && error.message ? error.message : String(error)); }
}

module.exports = { parseArgs, runGit, main };
