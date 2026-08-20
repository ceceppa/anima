#!/usr/bin/env node
"use strict";

/**
 * mano verify — run a verification command and filter its output at the source.
 *
 * Instructions cannot save tokens that are already in the transcript, so the
 * filtering happens here, before anything reaches the agent's context:
 *
 *   node verify.js -- <command ...>
 *
 *   exit 0  → prints `PASS: <command>` and exits 0 (~10 tokens, no parsing —
 *             the common case)
 *   exit ≠0 → prints `FAIL (exit n): <command>` plus a trimmed excerpt: the
 *             first 40 and last 20 lines, consecutive duplicates collapsed,
 *             capped at 2,000 characters — then exits with the command's own
 *             exit code
 *
 * The excerpt is **stdout followed by stderr**, not the two interleaved. A
 * child's streams are captured separately and their true interleaving is not
 * recoverable, so the excerpt labels each rather than claiming an ordering it
 * cannot deliver.
 *
 * A command that never ran is not a command that failed: a missing executable
 * or a signalled process reports the spawn error or the signal by name instead
 * of a bare `exit 1` over a blank excerpt.
 *
 * The script is runner-agnostic: it names no test framework, build tool, or
 * language. Optional sharpening is project-owned, not framework-owned: a
 * `## Verification` block in _mano_output/tech-spec.md may declare
 * `failure-pattern: <regex>`; when a failing run's output has lines matching
 * that pattern, those lines lead the excerpt. (`command:` in the same block
 * documents the project's canonical verification command for the implementer;
 * this script does not read it.)
 *
 * Invocation forms:
 *   node verify.js -- npm test              → spawned directly (argv preserved)
 *   node verify.js -- "npm test 2>&1 | x"   → single argument runs via the shell,
 *                                             so pipes and redirects work
 */

const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const path = require("node:path");

const HEAD_LINES = 40;
const TAIL_LINES = 20;
const CHAR_CAP = 2000;
const PATTERN_LINE_CAP = 12;

function parseArgs(argv) {
  const sep = argv.indexOf("--");
  // Empty arguments are preserved: `cmd --filter ""` means something different
  // from `cmd --filter`, and dropping the value silently changes the command.
  const rest = sep === -1 ? argv.slice() : argv.slice(sep + 1);
  const display = rest.map((a) => (a === "" ? '""' : a)).join(" ").trim();
  return { argv: rest, display };
}

// The optional project-owned failure pattern from tech-spec.md's
// `## Verification` block. Absent file, absent block, absent field, or an
// invalid regex all mean "no pattern" — never an error.
function failurePattern(projectRoot) {
  try {
    const spec = fs.readFileSync(
      path.join(projectRoot, "_mano_output", "tech-spec.md"),
      "utf8",
    );
    const block = /^##\s+Verification\s*$([\s\S]*?)(?=^##\s|\n*$(?![\s\S]))/im.exec(spec);
    if (!block) return null;
    const field = /^[-*\s]*failure-pattern:\s*(.+)$/im.exec(block[1]);
    if (!field) return null;
    return new RegExp(field[1].trim().replace(/^`|`$/g, ""));
  } catch {
    return null;
  }
}

// Collapse consecutive duplicate lines ("... 57 more of the same" style noise).
function dedupe(lines) {
  const out = [];
  let last = null;
  let repeats = 0;
  for (const line of lines) {
    if (line === last) {
      repeats++;
      continue;
    }
    if (repeats > 0) out.push(`  [× ${repeats + 1} identical lines]`);
    out.push(line);
    last = line;
    repeats = 0;
  }
  if (repeats > 0) out.push(`  [× ${repeats + 1} identical lines]`);
  return out;
}

function excerpt(text, pattern) {
  const lines = dedupe(
    text.split(/\r?\n/).map((l) => l.replace(/\s+$/, "")).filter((l, i, a) => l !== "" || (i > 0 && a[i - 1] !== "")),
  );
  const parts = [];
  if (pattern) {
    const matched = lines.filter((l) => pattern.test(l)).slice(0, PATTERN_LINE_CAP);
    if (matched.length) {
      parts.push("-- matched failure-pattern --", ...matched, "");
    }
  }
  if (lines.length <= HEAD_LINES + TAIL_LINES) {
    parts.push(...lines);
  } else {
    parts.push(
      ...lines.slice(0, HEAD_LINES),
      `  [... ${lines.length - HEAD_LINES - TAIL_LINES} lines omitted ...]`,
      ...lines.slice(-TAIL_LINES),
    );
  }
  const joined = parts.join("\n");
  return joined.length > CHAR_CAP ? capBothEnds(parts) : joined;
}

/**
 * Fit the excerpt into CHAR_CAP while keeping **both** sentinels.
 *
 * `joined.slice(0, CHAR_CAP)` amputated exactly the tail the head/tail excerpt
 * had just been built to preserve — so a failure whose cause prints last (a
 * summary line, a stack, the assertion) lost the only part worth reading. The
 * budget is spent from the outside in: the head takes two thirds, the tail one
 * third, and a marker between them says what went.
 */
function capBothEnds(parts) {
  const marker = "  [... trimmed to fit 2000 chars ...]";
  const budget = CHAR_CAP - marker.length - 2;
  const headBudget = Math.floor((budget * 2) / 3);
  const tailBudget = budget - headBudget;

  const head = [];
  let used = 0;
  for (const line of parts) {
    if (used + line.length + 1 > headBudget) break;
    head.push(line);
    used += line.length + 1;
  }
  const tail = [];
  used = 0;
  for (let i = parts.length - 1; i >= head.length; i--) {
    const line = parts[i];
    if (used + line.length + 1 > tailBudget) break;
    tail.unshift(line);
    used += line.length + 1;
  }
  if (!tail.length && parts.length > head.length) {
    tail.push(parts[parts.length - 1].slice(0, tailBudget));
  }
  return [...head, marker, ...tail].join("\n");
}

/**
 * The child's output, labelled by stream.
 *
 * Concatenating the two and calling it "combined output" claimed an
 * interleaving that separate pipes cannot give. Naming each stream is what this
 * script can actually deliver, and it is more useful besides.
 */
function streams(result) {
  const stdout = String(result.stdout || "").replace(/\s+$/, "");
  const stderr = String(result.stderr || "").replace(/\s+$/, "");
  if (stdout && stderr) return `${stdout}\n-- stderr --\n${stderr}`;
  if (stderr) return `-- stderr --\n${stderr}`;
  return stdout;
}

const USAGE = `mano verify — run a verification command and filter its output at the source

Usage:
  node verify.js -- <command ...>

  node verify.js -- npm test              spawned directly; argv is preserved,
                                          including empty arguments
  node verify.js -- "npm test 2>&1 | x"   a single argument runs through the
                                          shell, so pipes and redirects work

  exit 0   prints \`PASS: <command>\` and nothing else
  exit n   prints \`FAIL (exit n): <command>\` plus a trimmed excerpt — first 40
           and last 20 lines, consecutive duplicates collapsed, capped at 2,000
           characters with both ends kept — then exits with the command's code

A command that never ran is not a command that failed: a missing executable or
a signalled process is reported by name, not as a bare exit 1.

Optional per-project sharpening: a \`## Verification\` block in
_mano_output/tech-spec.md may declare \`failure-pattern: <regex>\`; matching lines
lead the excerpt.
`;

function main() {
  const raw = process.argv.slice(2);
  // `--help` before `--` is the flag; after `--` it is part of the command.
  const beforeSeparator = raw.slice(0, raw.indexOf("--") === -1 ? raw.length : raw.indexOf("--"));
  if (beforeSeparator.some((a) => a === "--help" || a === "-h")) {
    process.stdout.write(USAGE);
    process.exit(0);
  }
  const { argv, display } = parseArgs(raw);
  if (!display) {
    process.stderr.write("usage: node verify.js -- <command ...>   (--help for detail)\n");
    process.exit(2);
  }
  const options = { encoding: "utf8", maxBuffer: 64 * 1024 * 1024 };
  const result = argv.length === 1
    ? spawnSync(argv[0], { ...options, shell: true })
    : spawnSync(argv[0], argv.slice(1), options);
  // A command that could not run at all, or that a signal killed, reports why.
  // Both used to surface as `FAIL (exit 1)` over an empty excerpt, because
  // status is null and stdout/stderr are undefined in exactly those cases —
  // the most confusing failure this script could produce.
  if (result.error) {
    process.stdout.write(`FAIL (did not run): ${display}\n`);
    process.stdout.write(`  ${result.error.code || "spawn error"}: ${result.error.message}\n`);
    process.exit(1);
  }
  if (result.signal) {
    process.stdout.write(`FAIL (killed by ${result.signal}): ${display}\n`);
    const output = streams(result);
    if (output) process.stdout.write(excerpt(output, failurePattern(process.cwd())) + "\n");
    process.exit(1);
  }

  const code = result.status === null ? 1 : result.status;
  if (code === 0) {
    process.stdout.write(`PASS: ${display}\n`);
    process.exit(0);
  }
  process.stdout.write(`FAIL (exit ${code}): ${display}\n`);
  process.stdout.write(excerpt(streams(result), failurePattern(process.cwd())) + "\n");
  process.exit(code);
}

if (require.main === module) main();

module.exports = { parseArgs, failurePattern, dedupe, excerpt, streams, capBothEnds };
