"use strict";

/**
 * writeAtomic — the one write path for every Mano artifact a script owns.
 *
 * A bare `fs.writeFileSync` truncates its target before it writes. An
 * interrupt in that window — Ctrl-C, a crash, a laptop lid — leaves a
 * half-written ledger, which is the only real data-loss path in a single-user
 * local tool. Writing to a temp file in the *same directory*, flushing it, and
 * renaming means the destination only ever holds a complete file: rename is
 * atomic within a filesystem, and any failure before it leaves the previous
 * file untouched.
 */

const fs = require("node:fs");
const path = require("node:path");

function writeAtomic(file, text) {
  const dir = path.dirname(file);
  // Same directory: a cross-filesystem rename is a copy, and a copy is not
  // atomic. This is the property the whole helper exists for.
  const tmp = path.join(dir, `.${path.basename(file)}.tmp-${process.pid}`);
  const fd = fs.openSync(tmp, "w");
  try {
    fs.writeFileSync(fd, text);
    fs.fsyncSync(fd);
  } finally {
    fs.closeSync(fd);
  }
  try {
    fs.renameSync(tmp, file);
  } catch (error) {
    fs.rmSync(tmp, { force: true });
    throw error;
  }
}

module.exports = { writeAtomic };
