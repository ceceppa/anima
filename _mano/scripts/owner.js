#!/usr/bin/env node
"use strict";

/** Configure the local owner namespace used by Mano phase-scoped commands. */

const path = require("node:path");
const childProcess = require("node:child_process");
const { validateOwner, resolveConfiguredOwner } = require("./phase.js");

const HELP = `mano owner — configure phase ownership for this repository clone

Usage:
  node owner.js show [projectRoot]
  node owner.js set <slug> [projectRoot]
  node owner.js clear [projectRoot]

The slug is stored in local Git config as mano.owner and is not committed.
Use a stable team handle such as "alice" or "gameplay". Do not use an email.
MANO_OWNER overrides Git config for a shell/session.`;

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

function runGit(root, args, allowMissing = false) {
  const result = childProcess.spawnSync("git", args, { cwd: root, encoding: "utf8" });
  if (result.status === 0) return result;
  if (allowMissing && result.status === 5) return result;
  const detail = String(result.stderr || result.stdout || "git command failed").trim();
  fail(`${detail}. Mano owner configuration requires a Git checkout; alternatively set MANO_OWNER.`);
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
    runGit(args.root, ["rev-parse", "--git-dir"]);
    runGit(args.root, ["config", "--local", "mano.owner", owner]);
    process.stdout.write(`[mano owner] owner set to ${owner} for this repository clone\n`);
    if (Object.prototype.hasOwnProperty.call(process.env, "MANO_OWNER")) {
      process.stdout.write(`  MANO_OWNER=${process.env.MANO_OWNER} currently overrides that value\n`);
    }
    return;
  }

  if (args.command === "clear") {
    runGit(args.root, ["rev-parse", "--git-dir"]);
    runGit(args.root, ["config", "--local", "--unset-all", "mano.owner"], true);
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

module.exports = { parseArgs, runGit, main };
