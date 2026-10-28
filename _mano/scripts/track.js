#!/usr/bin/env node
"use strict";

/** Configure the optional local work track for one Mano checkout. */

const path = require("node:path");
const Settings = require("./settings.js");
const { validateTrack, resolveConfiguredTrack } = require("./phase.js");

const HELP = `mano track — configure an optional work track for this repository clone

Usage:
  node track.js show [projectRoot]
  node track.js set "Option B" [projectRoot]
  node track.js clear [projectRoot]

The active track is stored in _mano_output/[owner].json (or .default.json
without an owner) and can be committed. It tags new imports and Start items
and narrows Start candidates. Review items copy their phase brief Track.
MANO_TRACK overrides the stored value for a shell/session.`;

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
    Settings.writeSetting(args.root, "track", track);
    process.stdout.write(`[mano track] track set to ${JSON.stringify(track)} for this repository clone\n`);
    if (Object.prototype.hasOwnProperty.call(process.env, "MANO_TRACK")) {
      process.stdout.write(`  MANO_TRACK=${JSON.stringify(process.env.MANO_TRACK)} currently overrides that value\n`);
    }
    return;
  }
  if (args.command === "clear") {
    Settings.writeSetting(args.root, "track", null);
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

module.exports = { parseArgs, main };
