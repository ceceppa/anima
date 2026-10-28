#!/usr/bin/env node
"use strict";

/** Configure the chat, build, and planning-artifact languages for one owner. */

const path = require("node:path");
const Settings = require("./settings.js");

const CHANNELS = ["chat", "build", "artefacts"];

const HELP = `mano language — configure the languages Mano uses for this owner

Usage:
  node language.js show
  node language.js set <channel> "<language>" [<channel> "<language>" ...]
  node language.js clear [<channel> ...]

Run it from the project root.

chat       conversation: explanations, questions, progress, hand-backs
build      implementation content: code, comments, tests, product/UI text
artefacts  planning prose: briefs, specs, rules, stories, backlog, reviews;
           when unset it follows build, then chat

A channel is chat, build, or artefacts, and every language needs one: for
example "set chat it build en-GB artefacts it". "set" may be omitted. Values
are language names or locale tags (for example it, en-GB, "Brazilian
Portuguese"). "clear" with no channel clears all three. They are stored in
_mano_output/[owner].json (or .default.json without an owner), which is
created if it does not exist yet. Changing a language does not translate
existing files.`;

function fail(message) {
  process.stderr.write(`[mano language] ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const positional = argv.filter((arg) => arg !== "--help" && arg !== "-h");
  const args = { help: argv.includes("--help") || argv.includes("-h"), command: "show", pairs: [], channels: [], error: null };
  let rest = positional;
  if (["show", "set", "clear"].includes(rest[0])) {
    args.command = rest[0];
    rest = rest.slice(1);
  } else if (CHANNELS.includes(rest[0])) {
    // `mano language chat it build en-GB` is the natural spelling.
    args.command = "set";
  } else if (rest.length) {
    // A language with no channel is ambiguous by design.
    args.error = `name a channel before ${JSON.stringify(rest[0])}: chat, build, or artefacts`;
    return args;
  }
  if (args.command === "set") {
    while (CHANNELS.includes(rest[0])) {
      const [channel, value] = rest;
      if (value === undefined || CHANNELS.includes(value) || !value.trim()) {
        args.error = `${channel} needs a language, for example \`${channel} it\``;
        return args;
      }
      if (args.pairs.some(([seen]) => seen === channel)) {
        args.error = `${channel} is given twice`;
        return args;
      }
      args.pairs.push([channel, value.trim()]);
      rest = rest.slice(2);
    }
    if (!args.pairs.length) {
      args.error = `set needs a channel and a language, for example \`set chat it\``;
      return args;
    }
  } else if (args.command === "clear") {
    while (CHANNELS.includes(rest[0])) {
      if (!args.channels.includes(rest[0])) args.channels.push(rest[0]);
      rest = rest.slice(1);
    }
  }
  if (rest.length) {
    args.error = `unexpected argument ${JSON.stringify(rest[0])}; quote a language name that contains spaces`;
    return args;
  }
  return args;
}

function describe(root) {
  const saved = { chat: null, build: null, artefacts: null, ...Settings.readSetting(root, "language") };
  const resolved = Settings.readLanguage(root);
  const lines = CHANNELS.map((channel) => {
    const value = resolved[channel];
    if (value === null) return `  ${channel}: not set (existing behaviour)`;
    if (channel === "artefacts" && saved.artefacts == null) {
      return `  ${channel}: ${value} (follows ${saved.build != null ? "build" : "chat"})`;
    }
    return `  ${channel}: ${value}`;
  });
  return `${lines.join("\n")}\n  stored in ${Settings.relativeFile(root).split(path.sep).join("/")}\n`;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(HELP + "\n");
    return;
  }
  if (args.error) fail(args.error);
  const root = process.cwd();

  if (args.command === "set" || args.command === "clear") {
    const language = { chat: null, build: null, artefacts: null, ...Settings.readSetting(root, "language") };
    const changes = args.command === "set" ? args.pairs : (args.channels.length ? args.channels : CHANNELS).map((channel) => [channel, null]);
    for (const [channel, value] of changes) language[channel] = value;
    Settings.writeSetting(root, "language", language);
    const summary = changes.map(([channel, value]) => value === null ? `${channel} cleared` : `${channel} set to ${JSON.stringify(value)}`);
    process.stdout.write(`[mano language] ${summary.join(", ")}\n`);
    process.stdout.write(describe(root));
    process.stdout.write("  Existing files are not translated.\n");
    return;
  }

  process.stdout.write("[mano language]\n" + describe(root));
}

if (require.main === module) {
  try { main(); } catch (error) { fail(error && error.message ? error.message : String(error)); }
}

module.exports = { CHANNELS, parseArgs, main };
