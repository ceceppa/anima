"use strict";

/**
 * Shared phase identity and path rules.
 *
 * Legacy projects use `phase-N`. Team mode is opt-in through an explicit owner
 * slug and uses `<owner>-phase-N`. Owner identity is local execution context,
 * never inferred from an email address or OS username.
 */

const fs = require("node:fs");
const path = require("node:path");
const childProcess = require("node:child_process");

const OWNER_RE = /^[a-z0-9](?:[a-z0-9-]{0,46}[a-z0-9])?$/;

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
  return {
    owner: configured.owner,
    ownerSource: configured.source,
    mode: configured.owner ? "owned" : "legacy",
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
  validateOwner,
  resolveConfiguredOwner,
  parsePhaseDirName,
  phaseRef,
  listPhaseRefs,
  phaseRouting,
  reviewHeadingPattern,
};
