#!/usr/bin/env node
"use strict";

/** Configure the local owner namespace used by Mano phase-scoped commands. */

const path = require("node:path");
const Settings = require("./settings.js");
const { validateOwner, resolveConfiguredOwner } = require("./phase.js");

const HELP = `mano owner — configure phase ownership for this repository clone

Usage:
  node owner.js show [projectRoot]
  node owner.js set <slug> [projectRoot]
  node owner.js clear [projectRoot]

The selected owner is stored in ignored _mano_output/.local.json.
Portable settings and chain records live in _mano_output/[owner].json.
MANO_OWNER overrides the local selection for a shell/session.`;

function fail(message) {
  process.stderr.write(`[mano owner] ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const positional = argv.filter((arg) => arg !== "--help" && arg !== "-h");
  return {
    help: argv.includes("--help") || argv.includes("-h"),
    command: positional[0] || "show",
    slug: positional[0] === "set" ? positional[1] : null,
    root: path.resolve(positional[positional[0] === "set" ? 2 : 1] || process.cwd()),
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(HELP + "\n");
    return;
  }
  if (!['show', 'set', 'clear'].includes(args.command)) {
    fail(`unknown command ${JSON.stringify(args.command)}; use show, set, or clear`);
  }

  if (args.command === "set") {
    if (!args.slug) fail("set needs an owner slug");
    const owner = validateOwner(args.slug);
    Settings.selectOwner(args.root, owner);
    process.stdout.write(`[mano owner] owner set to ${owner} for this repository clone\n`);
    if (Object.prototype.hasOwnProperty.call(process.env, "MANO_OWNER")) {
      process.stdout.write(`  MANO_OWNER=${process.env.MANO_OWNER} currently overrides that value\n`);
    }
    return;
  }

  if (args.command === "clear") {
    Settings.selectOwner(args.root, null);
    process.stdout.write("[mano owner] local owner cleared; legacy phase routing is active unless MANO_OWNER is set\n");
    return;
  }

  let configured;
  try {
    configured = resolveConfiguredOwner(args.root);
  } catch (error) {
    fail(error.message);
  }
  if (!configured.owner) {
    process.stdout.write("[mano owner] no owner configured (legacy phase routing)\n");
  } else {
    process.stdout.write(`[mano owner] ${configured.owner} (${configured.source})\n`);
  }
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    fail(error && error.message ? error.message : String(error));
  }
}

module.exports = { parseArgs, main };
