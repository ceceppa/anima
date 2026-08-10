#!/usr/bin/env node
"use strict";

/**
 * Run a greenfield project generator outside the project root, then merge only
 * non-conflicting generated files. Existing project files are never replaced.
 */

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const childProcess = require("node:child_process");

const PLACEHOLDER = "{target}";
const RESERVED_TOP_LEVEL = new Set(["_mano", "_mano_output"]);

const HELP = `mano scaffold — safely run an empty-directory project generator

Usage:
  node _mano/scripts/scaffold.js run [--project-root PATH] [--name NAME] [--keep-stage] -- COMMAND [ARGS...]

Example:
  node _mano/scripts/scaffold.js run --name my-app -- npx create-example-app@latest {target}

The command runs outside the project. Every {target} token is replaced with a
relative directory name inside an external staging directory. After the command
succeeds, Mano preflights the complete generated tree and copies only missing files into the project.
Existing files are never overwritten or deleted. Identical files are retained.
Any differing collision aborts before copying and preserves the staged output.`;

function fail(message) {
  process.stderr.write(`[mano scaffold] ${message}\n`);
  process.exitCode = 1;
}

function parseArgs(argv) {
  if (argv.includes("--help") || argv.includes("-h")) return { help: true };

  const separator = argv.indexOf("--");
  if (separator === -1) {
    throw new Error(`missing -- before the generator command; see --help`);
  }

  const own = argv.slice(0, separator);
  const command = argv.slice(separator + 1);
  const parsed = {
    help: false,
    action: own.shift() || "",
    projectRoot: process.cwd(),
    name: null,
    keepStage: false,
    command,
  };

  for (let index = 0; index < own.length; index += 1) {
    const arg = own[index];
    if (arg === "--project-root") {
      if (!own[index + 1]) throw new Error("--project-root needs a path");
      parsed.projectRoot = own[index + 1];
      index += 1;
    } else if (arg === "--name") {
      if (!own[index + 1]) throw new Error("--name needs a directory name");
      parsed.name = own[index + 1];
      index += 1;
    } else if (arg === "--keep-stage") {
      parsed.keepStage = true;
    } else {
      throw new Error(`unknown option ${JSON.stringify(arg)}; see --help`);
    }
  }

  return parsed;
}

function validateName(value) {
  const name = String(value || "").trim();
  if (
    !name ||
    name === "." ||
    name === ".." ||
    name.includes("/") ||
    name.includes("\\") ||
    name.includes("\0")
  ) {
    throw new Error(
      `invalid staging name ${JSON.stringify(value)}; use one directory name such as "my-app"`,
    );
  }
  return name;
}

function lstatOrNull(filePath) {
  try {
    return fs.lstatSync(filePath);
  } catch (error) {
    if (error && error.code === "ENOENT") return null;
    throw error;
  }
}

function filesEqual(left, right) {
  const leftStat = fs.statSync(left);
  const rightStat = fs.statSync(right);
  if (leftStat.size !== rightStat.size) return false;

  const leftFd = fs.openSync(left, "r");
  const rightFd = fs.openSync(right, "r");
  const leftBuffer = Buffer.allocUnsafe(64 * 1024);
  const rightBuffer = Buffer.allocUnsafe(64 * 1024);
  try {
    while (true) {
      const leftRead = fs.readSync(leftFd, leftBuffer, 0, leftBuffer.length, null);
      const rightRead = fs.readSync(rightFd, rightBuffer, 0, rightBuffer.length, null);
      if (leftRead !== rightRead) return false;
      if (leftRead === 0) return true;
      if (!leftBuffer.subarray(0, leftRead).equals(rightBuffer.subarray(0, rightRead))) {
        return false;
      }
    }
  } finally {
    fs.closeSync(leftFd);
    fs.closeSync(rightFd);
  }
}

function collectTree(sourceRoot) {
  const entries = [];

  function visit(relativeDir) {
    const absoluteDir = path.join(sourceRoot, relativeDir);
    const children = fs.readdirSync(absoluteDir, { withFileTypes: true })
      .sort((left, right) => left.name.localeCompare(right.name));

    for (const child of children) {
      const relativePath = relativeDir ? path.join(relativeDir, child.name) : child.name;
      const topLevel = relativePath.split(path.sep)[0];
      if (topLevel === ".git") continue;
      if (RESERVED_TOP_LEVEL.has(topLevel)) {
        throw new Error(
          `generator created reserved path ${JSON.stringify(topLevel)}; staged output was not merged`,
        );
      }

      const absolutePath = path.join(sourceRoot, relativePath);
      const stat = fs.lstatSync(absolutePath);
      if (stat.isSymbolicLink()) {
        throw new Error(
          `generator created symbolic link ${JSON.stringify(relativePath)}; staged output was not merged`,
        );
      }
      if (stat.isDirectory()) {
        entries.push({ type: "directory", relativePath, source: absolutePath, stat });
        visit(relativePath);
      } else if (stat.isFile()) {
        entries.push({ type: "file", relativePath, source: absolutePath, stat });
      } else {
        throw new Error(
          `generator created unsupported entry ${JSON.stringify(relativePath)}; staged output was not merged`,
        );
      }
    }
  }

  visit("");
  return entries;
}

function preflight(entries, projectRoot) {
  const conflicts = [];
  let identicalFiles = 0;

  for (const entry of entries) {
    const destination = path.join(projectRoot, entry.relativePath);
    const existing = lstatOrNull(destination);
    entry.destination = destination;
    entry.existing = existing;
    if (!existing) continue;

    if (entry.type === "directory" && existing.isDirectory() && !existing.isSymbolicLink()) {
      continue;
    }
    if (entry.type === "file" && existing.isFile() && filesEqual(entry.source, destination)) {
      identicalFiles += 1;
      continue;
    }
    conflicts.push(entry.relativePath);
  }

  return { conflicts, identicalFiles };
}

function merge(entries) {
  let addedFiles = 0;
  for (const entry of entries) {
    if (entry.existing) continue;
    if (entry.type === "directory") {
      fs.mkdirSync(entry.destination, { recursive: false, mode: entry.stat.mode });
      continue;
    }
    fs.copyFileSync(entry.source, entry.destination, fs.constants.COPYFILE_EXCL);
    fs.chmodSync(entry.destination, entry.stat.mode);
    addedFiles += 1;
  }
  return addedFiles;
}

function verify(entries) {
  for (const entry of entries) {
    const destination = lstatOrNull(entry.destination);
    if (entry.type === "directory") {
      if (!destination || !destination.isDirectory() || destination.isSymbolicLink()) {
        throw new Error(`verification failed for generated directory ${entry.relativePath}`);
      }
    } else if (!destination || !destination.isFile() || !filesEqual(entry.source, entry.destination)) {
      throw new Error(`verification failed for generated file ${entry.relativePath}`);
    }
  }
}

function removeOwnedStage(stageRoot) {
  const tempRoot = fs.realpathSync(os.tmpdir());
  const realStage = fs.realpathSync(stageRoot);
  if (path.dirname(realStage) !== tempRoot || !path.basename(realStage).startsWith("mano-scaffold-")) {
    throw new Error(`refusing to remove unexpected staging path ${realStage}`);
  }
  fs.rmSync(realStage, { recursive: true, force: false });
}

function run(args) {
  if (args.action !== "run") {
    throw new Error(`unknown action ${JSON.stringify(args.action)}; use run`);
  }
  if (args.command.length === 0) throw new Error("generator command is empty");

  const projectRoot = path.resolve(args.projectRoot);
  const projectStat = lstatOrNull(projectRoot);
  if (!projectStat || !projectStat.isDirectory()) {
    throw new Error(`project root is not a directory: ${projectRoot}`);
  }

  const name = validateName(args.name || path.basename(projectRoot));
  const placeholderCount = args.command.reduce(
    (count, arg) => count + String(arg).split(PLACEHOLDER).length - 1,
    0,
  );
  if (placeholderCount === 0) {
    throw new Error(`generator command must contain ${PLACEHOLDER} as its target`);
  }

  const stageRoot = fs.mkdtempSync(path.join(os.tmpdir(), "mano-scaffold-"));
  const stagedTarget = path.join(stageRoot, name);
  // Pass a relative target because many generators do `path.join(cwd, target)`.
  // Supplying an absolute path to that pattern duplicates the path below cwd
  // (`/stage` + `/tmp/stage/app` -> `/stage/tmp/stage/app`). The generator's
  // cwd is already the external stage, so the validated single-component name
  // is both portable and safely confined there.
  const command = args.command.map((arg) => String(arg).split(PLACEHOLDER).join(name));
  const environment = { ...process.env, PWD: stageRoot };
  delete environment.INIT_CWD;

  process.stdout.write(`[mano scaffold] staging generator output outside the project: ${stageRoot}\n`);
  const result = childProcess.spawnSync(command[0], command.slice(1), {
    cwd: stageRoot,
    env: environment,
    stdio: "inherit",
    shell: false,
  });

  if (result.error) {
    throw new Error(`generator could not start: ${result.error.message}; staged output kept at ${stageRoot}`);
  }
  if (result.status !== 0) {
    throw new Error(
      `generator exited with status ${result.status}; project was not touched; staged output kept at ${stageRoot}`,
    );
  }

  const targetStat = lstatOrNull(stagedTarget);
  if (!targetStat || !targetStat.isDirectory() || targetStat.isSymbolicLink()) {
    throw new Error(
      `generator did not create the expected directory ${stagedTarget}; project was not touched; staged output kept at ${stageRoot}`,
    );
  }

  let entries;
  try {
    entries = collectTree(stagedTarget);
  } catch (error) {
    throw new Error(`${error.message}; staged output kept at ${stageRoot}`);
  }
  const checked = preflight(entries, projectRoot);
  if (checked.conflicts.length > 0) {
    const list = checked.conflicts.map((item) => `  - ${item}`).join("\n");
    throw new Error(
      `merge blocked by ${checked.conflicts.length} differing existing path(s):\n${list}\n` +
      `project was not touched; staged output kept at ${stageRoot}`,
    );
  }

  let addedFiles;
  try {
    addedFiles = merge(entries);
    verify(entries);
  } catch (error) {
    throw new Error(
      `${error.message}; existing project files were preserved, but some new files may have been added; ` +
      `staged output kept at ${stageRoot}`,
    );
  }

  if (args.keepStage) {
    process.stdout.write(`[mano scaffold] staged output kept at ${stageRoot}\n`);
  } else {
    removeOwnedStage(stageRoot);
  }
  process.stdout.write(
    `[mano scaffold] merged ${addedFiles} new file(s); retained ${checked.identicalFiles} identical existing file(s); ` +
    "no existing project file was overwritten or deleted\n",
  );
}

function main() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
    if (args.help) {
      process.stdout.write(HELP + "\n");
      return;
    }
    run(args);
  } catch (error) {
    fail(error && error.message ? error.message : String(error));
  }
}

main();
