"use strict";

/**
 * Shared phase identity, path rules, and local execution context.
 *
 * Legacy projects use `phase-N`. Team mode is opt-in through an explicit owner
 * slug and uses `<owner>-phase-N`. Owner identity is local execution context,
 * never inferred from an email address or OS username.
 *
 * Run mode (`manual` / `auto`) is the other piece of local execution context:
 * it decides whether a finished skill chains into the next action or hands
 * back. Like the owner, it is stored per clone and never committed — it is a
 * statement about how much this person reviews, not a property of the project.
 */

const fs = require("node:fs");
const path = require("node:path");
const childProcess = require("node:child_process");

const OWNER_RE = /^[a-z0-9](?:[a-z0-9-]{0,46}[a-z0-9])?$/;
const TRACK_MAX_LENGTH = 120;

function validateOwner(value) {
  const owner = value == null ? "" : String(value).trim();
  if (!OWNER_RE.test(owner)) {
    throw new Error(
      `invalid Mano owner ${JSON.stringify(owner)}; use a lowercase slug such as ` +
      '"alice" or "gameplay-team" (letters, digits, hyphens; max 48)',
    );
  }
  return owner;
}

function gitConfigOwner(projectRoot) {
  const result = childProcess.spawnSync(
    "git",
    ["config", "--local", "--get", "mano.owner"],
    { cwd: projectRoot, encoding: "utf8" },
  );
  if (result.status !== 0) return null;
  const value = String(result.stdout || "").trim();
  return value ? validateOwner(value) : null;
}

function resolveConfiguredOwner(projectRoot) {
  if (Object.prototype.hasOwnProperty.call(process.env, "MANO_OWNER")) {
    const value = String(process.env.MANO_OWNER || "").trim();
    if (!value) throw new Error("MANO_OWNER is set but empty");
    return { owner: validateOwner(value), source: "MANO_OWNER" };
  }
  const owner = gitConfigOwner(projectRoot);
  return owner ? { owner, source: "git config --local mano.owner" } : { owner: null, source: null };
}

function validateTrack(value) {
  const track = value == null ? "" : String(value).trim();
  if (!track || track.length > TRACK_MAX_LENGTH || /[\u0000-\u001F\u007F]/.test(track)) {
    throw new Error(
      `invalid Mano track ${JSON.stringify(value)}; use 1-${TRACK_MAX_LENGTH} printable characters on one line`,
    );
  }
  return track;
}

function gitConfigTrack(projectRoot) {
  const result = childProcess.spawnSync(
    "git",
    ["config", "--local", "--get", "mano.track"],
    { cwd: projectRoot, encoding: "utf8" },
  );
  if (result.status !== 0) return null;
  const value = String(result.stdout || "").trim();
  return value ? validateTrack(value) : null;
}

function resolveConfiguredTrack(projectRoot) {
  if (Object.prototype.hasOwnProperty.call(process.env, "MANO_TRACK")) {
    const value = String(process.env.MANO_TRACK || "").trim();
    if (!value) throw new Error("MANO_TRACK is set but empty");
    return { track: validateTrack(value), source: "MANO_TRACK" };
  }
  const track = gitConfigTrack(projectRoot);
  return track ? { track, source: "git config --local mano.track" } : { track: null, source: null };
}

const MODES = ["manual", "auto"];
const DEFAULT_MODE = "manual";

function validateMode(value) {
  const mode = value == null ? "" : String(value).trim().toLowerCase();
  if (!MODES.includes(mode)) {
    throw new Error(
      `invalid Mano mode ${JSON.stringify(value)}; use ${MODES.join(" or ")}`,
    );
  }
  return mode;
}

function gitConfigMode(projectRoot) {
  const result = childProcess.spawnSync(
    "git",
    ["config", "--local", "--get", "mano.mode"],
    { cwd: projectRoot, encoding: "utf8" },
  );
  if (result.status !== 0) return null;
  const value = String(result.stdout || "").trim();
  return value ? validateMode(value) : null;
}

// Manual is the default everywhere: a project that has never opted in must
// never chain, and an unreadable/absent config is not an opt-in.
function resolveConfiguredMode(projectRoot) {
  if (Object.prototype.hasOwnProperty.call(process.env, "MANO_MODE")) {
    const value = String(process.env.MANO_MODE || "").trim();
    if (!value) throw new Error("MANO_MODE is set but empty");
    return { mode: validateMode(value), source: "MANO_MODE" };
  }
  const mode = gitConfigMode(projectRoot);
  return mode
    ? { mode, source: "git config --local mano.mode" }
    : { mode: DEFAULT_MODE, source: null };
}

function parsePhaseDirName(name) {
  let match = /^phase-(\d+)$/.exec(name);
  if (match) {
    return { owner: null, number: Number(match[1]), id: name, dirName: name };
  }
  match = /^([a-z0-9](?:[a-z0-9-]{0,46}[a-z0-9])?)-phase-(\d+)$/.exec(name);
  if (!match) return null;
  return { owner: match[1], number: Number(match[2]), id: name, dirName: name };
}

function phaseRef(owner, number) {
  if (!Number.isInteger(Number(number)) || Number(number) < 1) {
    throw new Error(`phase number must be a positive integer, got ${JSON.stringify(number)}`);
  }
  const n = Number(number);
  const cleanOwner = owner == null ? null : validateOwner(owner);
  const dirName = cleanOwner ? `${cleanOwner}-phase-${n}` : `phase-${n}`;
  return {
    owner: cleanOwner,
    number: n,
    id: dirName,
    dirName,
    relativeDir: `_mano_output/${dirName}`,
    inPhaseStatus: `in-${dirName}`,
    reviewHeading: cleanOwner
      ? `Phase ${n} Review — Owner: ${cleanOwner}`
      : `Phase ${n} Review`,
  };
}

function listPhaseRefs(outputDir) {
  let entries = [];
  try {
    entries = fs.readdirSync(outputDir, { withFileTypes: true });
  } catch {
    return [];
  }
  return entries
    .filter((entry) => entry.isDirectory())
    .map((entry) => parsePhaseDirName(entry.name))
    .filter(Boolean)
    .map((ref) => phaseRef(ref.owner, ref.number));
}

function phaseRouting(projectRoot, outputDir = path.join(projectRoot, "_mano_output")) {
  const configured = resolveConfiguredOwner(projectRoot);
  const all = listPhaseRefs(outputDir);
  const owned = all.filter((ref) => ref.owner !== null);
  const refs = configured.owner
    ? all.filter((ref) => ref.owner === configured.owner)
    : all.filter((ref) => ref.owner === null);
  refs.sort((a, b) => a.number - b.number);
  const run = resolveConfiguredMode(projectRoot);
  const track = resolveConfiguredTrack(projectRoot);
  return {
    owner: configured.owner,
    ownerSource: configured.source,
    // `mode` here is the long-standing owner-routing mode. The run mode is a
    // separate axis and is deliberately not folded into it.
    mode: configured.owner ? "owned" : "legacy",
    runMode: run.mode,
    runModeSource: run.source,
    track: track.track,
    trackSource: track.source,
    refs,
    latest: refs.length ? refs[refs.length - 1] : null,
    otherOwners: [...new Set(owned.map((ref) => ref.owner).filter((owner) => owner !== configured.owner))].sort(),
  };
}

function reviewHeadingPattern(ref) {
  const escapedOwner = ref.owner
    ? ref.owner.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
    : null;
  return ref.owner
    ? new RegExp(`^##\\s+Phase\\s+${ref.number}\\s+Review\\s+—\\s+Owner:\\s+${escapedOwner}(?:\\s+—\\s+.+)?\\s*$`, "im")
    : new RegExp(`^##\\s+Phase\\s+${ref.number}\\s+Review(?:\\s+—\\s+(?!Owner:).+)?\\s*$`, "im");
}

module.exports = {
  OWNER_RE,
  TRACK_MAX_LENGTH,
  MODES,
  DEFAULT_MODE,
  validateOwner,
  validateTrack,
  validateMode,
  resolveConfiguredOwner,
  resolveConfiguredTrack,
  resolveConfiguredMode,
  parsePhaseDirName,
  phaseRef,
  listPhaseRefs,
  phaseRouting,
  reviewHeadingPattern,
};
