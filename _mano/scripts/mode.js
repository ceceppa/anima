#!/usr/bin/env node
"use strict";

/** Configure the local run mode that decides whether Mano skills chain. */

const path = require("node:path");
const Settings = require("./settings.js");
const { MODES, validateMode, resolveConfiguredMode } = require("./phase.js");

const HELP = `mano mode — configure the run mode for this repository clone

Usage:
  node mode.js show [projectRoot]
  node mode.js set <${MODES.join("|")}> [projectRoot]
  node mode.js clear [projectRoot]

manual (default)  every command hands back when it finishes; you type the next one.
auto              after you approve a phase scope, each finished action runs the
                  next one automatically, up to and including implementation.
                  It pauses for any question and always stops before review.

The mode is stored in _mano_output/[owner].json (or .default.json without
an owner) and can be committed. MANO_MODE overrides it for a shell/session.`;

function fail(message) {
  process.stderr.write(`[mano mode] ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const positional = argv.filter((arg) => arg !== "--help" && arg !== "-h");
  return {
    help: argv.includes("--help") || argv.includes("-h"),
    command: positional[0] || "show",
    value: positional[0] === "set" ? positional[1] : null,
    root: path.resolve(positional[positional[0] === "set" ? 2 : 1] || process.cwd()),
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(HELP + "\n");
    return;
  }
  // A bare `mano mode auto` is the natural spelling; treat a lone mode word as
  // `set`, so the shorthand can never be mistaken for an unknown command.
  if (!["show", "set", "clear"].includes(args.command)) {
    if (MODES.includes(String(args.command).trim().toLowerCase())) {
      args.value = args.command;
      args.command = "set";
    } else {
      fail(`unknown command ${JSON.stringify(args.command)}; use show, set, or clear`);
    }
  }

  if (args.command === "set") {
    if (!args.value) fail(`set needs a mode (${MODES.join(" or ")})`);
    let mode;
    try {
      mode = validateMode(args.value);
    } catch (error) {
      fail(error.message);
    }
    Settings.writeSetting(args.root, "mode", mode);
    if (mode === "auto") {
      process.stdout.write(
        "[mano mode] auto — after you approve a phase scope, actions chain through to implementation\n",
      );
      process.stdout.write("  Pauses for any question. Never runs mano review.\n");
    } else {
      process.stdout.write("[mano mode] manual — every command hands back when it finishes\n");
    }
    if (Object.prototype.hasOwnProperty.call(process.env, "MANO_MODE")) {
      process.stdout.write(`  MANO_MODE=${process.env.MANO_MODE} currently overrides that value\n`);
    }
    return;
  }

  if (args.command === "clear") {
    Settings.writeSetting(args.root, "mode", "manual");
    process.stdout.write("[mano mode] local mode cleared; manual is active unless MANO_MODE is set\n");
    return;
  }

  let configured;
  try {
    configured = resolveConfiguredMode(args.root);
  } catch (error) {
    fail(error.message);
  }
  const source = configured.source ? ` (${configured.source})` : " (default)";
  process.stdout.write(`[mano mode] ${configured.mode}${source}\n`);
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    fail(error && error.message ? error.message : String(error));
  }
}

module.exports = { parseArgs, main };
