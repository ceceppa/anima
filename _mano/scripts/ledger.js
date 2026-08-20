"use strict";

/**
 * mano ledger — the one grammar, parser, validator, and renderer for a phase's
 * build ledger (`_mano_output/phase-<N>/progress.md`).
 *
 * `progress.js` writes the ledger and `state.js` routes from it. They used to
 * carry a row regex each, and the two disagreed: a lettered row is a *normal
 * nested brief leaf* to the writer and a *human correction* to the reader, so
 * the reader dropped the leaf's behaviour line and routed on a bolded lead.
 * One module now owns the address space, so that class of disagreement is not
 * expressible.
 *
 * The address space, in full:
 *
 *   S2        a flat `## Phase Scope` item
 *   S2a       a nested brief leaf: category 2, leaf a
 *   S2+1      a human correction under S2 — its own exact text is the contract
 *   S2a+1     a human correction under S2a
 *   S2.1      a split of S2, authored by build
 *   S2a+1.1   a split of a correction
 *   E2a       an `## Exit Criteria` leaf
 *   E2a+1     a correction Exit leaf
 *   R1        a review rework event
 *
 * `+` means human correction. `.` means split. Letters mean a normal nested
 * brief leaf and nothing else. Callers never choose a `+N`: `add-row` allocates
 * it, so `+1+1` chains cannot be written.
 *
 * Statuses stay split by prefix, deliberately: Scope is pending|doing|done and
 * Exit is pending|met|needs-human, so `met` on an S row and `done` on an E row
 * are both errors. Built is not proven.
 */

const crypto = require("node:crypto");

const ROW_ID = /^([SE])(\d+)([a-z]*)(?:\+(\d+))?(?:\.(\d+))?$/;
const REWORK_ID = /^R(\d+)$/;

const SCOPE_STATUSES = ["pending", "doing", "done"];
const EXIT_STATUSES = ["pending", "met", "needs-human"];
const REWORK_STATUSES = ["pending", "resolved", "dismissed"];

const SCOPE_HEADER = "| # | What | Status |";
const SCOPE_SEPARATOR = "|---|------|--------|";
const EXIT_HEADER = "| # | Criterion | Status |";
const EXIT_SEPARATOR = "|---|-----------|--------|";
const REWORK_HEADER = "| # | Finding | Status |";
const REWORK_SEPARATOR = "|---|---------|--------|";

const VERSION_MARKER = "<!-- mano-progress: v2 -->";
const VERSION_RE = /^<!--\s*mano-progress:\s*v2\s*-->$/;
const CONTRACT_RE = /^<!--\s*contract:\s*([0-9a-f]{16})\s*-->$/;

// The addressed brief: the four sections a ledger is a decomposition of. A
// change to any of them invalidates every address in the ledger, so the digest
// covers exactly these and nothing else.
const ADDRESSED_SECTIONS = ["Phase Goal", "Phase Scope", "Not This Phase", "Exit Criteria"];

// ---- row addressing -------------------------------------------------------

/**
 * Parse a row address. Returns null for anything outside the grammar, and for
 * the two combinations the grammar can spell but the model forbids: a split of
 * an Exit leaf (Exit leaves are the human's, build never decomposes them) and
 * a zero-numbered correction or split.
 */
function parseRowId(id) {
  const m = ROW_ID.exec(String(id == null ? "" : id).trim());
  if (!m) return null;
  const plus = m[4] === undefined ? 0 : Number(m[4]);
  const sub = m[5] === undefined ? 0 : Number(m[5]);
  if (m[4] !== undefined && plus < 1) return null;
  if (m[5] !== undefined && sub < 1) return null;
  if (m[1] === "E" && sub) return null;
  const table = m[1];
  const number = Number(m[2]);
  const letters = m[3];
  return {
    table,
    number,
    letters,
    plus,
    sub,
    id: `${table}${number}${letters}${plus ? `+${plus}` : ""}${sub ? `.${sub}` : ""}`,
    kind: kindOf(plus, sub),
  };
}

function kindOf(plus, sub) {
  if (plus && sub) return "correction-split";
  if (plus) return "correction";
  if (sub) return "split";
  return "normal";
}

function parseReworkId(id) {
  const m = REWORK_ID.exec(String(id == null ? "" : id).trim());
  if (!m || Number(m[1]) < 1) return null;
  return { number: Number(m[1]), id: `R${Number(m[1])}` };
}

/**
 * The row this one hangs off, or null for a normal row.
 *
 * A split belongs to the thing it splits; a correction belongs to the normal
 * row it corrects. Letters are not a level here — `S2a` is a brief leaf with no
 * parent row in the ledger, because a nested brief category contributes its
 * leaves and not itself.
 */
function parentIdOf(parsed) {
  if (parsed.sub) {
    return `${parsed.table}${parsed.number}${parsed.letters}${parsed.plus ? `+${parsed.plus}` : ""}`;
  }
  if (parsed.plus) return `${parsed.table}${parsed.number}${parsed.letters}`;
  return null;
}

/**
 * [number, letters, plus, sub] — and the order of the last two is the whole
 * point. It puts a correction after its parent *and after that parent's entire
 * split subtree*, and the next normal sibling after every correction under the
 * previous parent: S2a, S2a.1, S2a.2, S2a+1, S2a+1.1, S3.
 */
function sortKey(parsed) {
  return [parsed.number, parsed.letters, parsed.plus, parsed.sub];
}

function compareRows(a, b) {
  const ka = sortKey(a);
  const kb = sortKey(b);
  if (ka[0] !== kb[0]) return ka[0] - kb[0];
  if (ka[1] !== kb[1]) return ka[1] < kb[1] ? -1 : 1;
  if (ka[2] !== kb[2]) return ka[2] - kb[2];
  return ka[3] - kb[3];
}

function statusesFor(table) {
  return table === "S" ? SCOPE_STATUSES : EXIT_STATUSES;
}

// A backwards move is a deviation the human must see, so it needs --reopen.
// `needs-human` is a terminal handoff, not a point on the pending-to-met line:
// it ranks with `met` so reaching it is never "backwards".
function rank(table, status) {
  const value = String(status).toLowerCase();
  if (table === "E" && value === "needs-human") return EXIT_STATUSES.indexOf("met");
  return statusesFor(table).indexOf(value);
}

// ---- cells ----------------------------------------------------------------

// One mechanical transform for every table cell: a cell is one line and cannot
// contain the column separator. It never shortens or rewords — the authoritative
// text of a row that carries its own contract lives in `## Row Contracts`.
function cell(value) {
  return String(value).replace(/\r?\n/g, " ").replace(/\|/g, " / ").replace(/\s+/g, " ").trim();
}

function formatRow(id, label, status) {
  return `| ${cell(id)} | ${cell(label)} | ${cell(status)} |`;
}

function rowCells(line) {
  if (!line.includes("|")) return null;
  const cells = line.split("|").map((c) => c.trim());
  while (cells.length && cells[0] === "") cells.shift();
  while (cells.length && cells[cells.length - 1] === "") cells.pop();
  return cells;
}

// A short, scannable handle derived from a row's contract text. Never the
// contract itself — `## Row Contracts` is always authoritative.
function deriveLabel(text, limit = 72) {
  const oneLine = String(text).replace(/\s+/g, " ").trim();
  if (oneLine.length <= limit) return oneLine;
  return `${oneLine.slice(0, limit - 1).trimEnd()}…`;
}

// ---- Row Contracts fencing ------------------------------------------------

// Long enough to survive any backtick run inside the text, so a contract that
// itself contains a fenced block still round-trips byte for byte.
function fenceFor(text) {
  let longest = 0;
  for (const run of String(text).match(/`+/g) || []) longest = Math.max(longest, run.length);
  return "`".repeat(Math.max(3, longest + 1));
}

function renderContract(id, { attributes = {}, text = null } = {}) {
  const L = [`### ${id}`];
  for (const [key, value] of Object.entries(attributes)) {
    L.push(`${key}: ${cell(value)}`);
  }
  if (text !== null) {
    if (Object.keys(attributes).length) L.push("");
    const fence = fenceFor(text);
    L.push(`${fence}text`, ...String(text).split("\n"), fence);
  }
  return L;
}

/**
 * Parse `## Row Contracts` into { id: { attributes, text } }.
 *
 * Attributes live *outside* the fence and the fence holds the authored text and
 * nothing else. A correction's text is the user's exact words and a rework
 * event's is the reviewer's, and either could legitimately begin with something
 * shaped like `reason:` — so metadata may never share the fence with it.
 */
function parseContracts(lines, start, end) {
  const out = new Map();
  let id = null;
  let attributes = {};
  let text = null;
  let fence = null;
  let buffer = [];

  const flush = () => {
    if (id !== null) out.set(id, { attributes, text });
    id = null;
    attributes = {};
    text = null;
  };

  for (let i = start; i < end; i++) {
    const line = lines[i];
    if (fence !== null) {
      if (line.trim() === fence) {
        text = buffer.join("\n");
        fence = null;
        buffer = [];
      } else {
        buffer.push(line);
      }
      continue;
    }
    const heading = /^###\s+(\S+)\s*$/.exec(line);
    if (heading) {
      flush();
      id = heading[1];
      continue;
    }
    if (id === null) continue;
    const open = /^(`{3,})text\s*$/.exec(line.trim());
    if (open) {
      fence = open[1];
      buffer = [];
      continue;
    }
    const attribute = /^([a-z][a-z0-9-]*):\s?(.*)$/.exec(line);
    if (attribute && text === null) attributes[attribute[1]] = attribute[2];
  }
  if (fence !== null) {
    // Unterminated fence: keep what we read so the validator can name it.
    text = buffer.join("\n");
  }
  flush();
  return out;
}

// ---- brief parsing --------------------------------------------------------

const LIST_ITEM = /^(\s*)(?:(\d+)[.)]|([a-z])[.)]|[-*+])\s+(.*)$/;

// The lines under `## <heading>`, up to the next `##`. HTML comments are the
// template's own guidance, not content.
function sectionLines(text, heading) {
  const lines = String(text).split("\n");
  const start = lines.findIndex((l) => new RegExp(`^##\\s+${heading}\\s*$`, "i").test(l.trim()));
  if (start === -1) return null;
  const out = [];
  for (let i = start + 1; i < lines.length; i++) {
    if (/^##\s+/.test(lines[i])) break;
    out.push(lines[i]);
  }
  return out.join("\n").replace(/<!--[\s\S]*?-->/g, "").split("\n");
}

function listItems(lines) {
  const items = [];
  for (const line of lines) {
    if (!line.trim()) continue;
    const m = LIST_ITEM.exec(line);
    if (m) {
      items.push({
        indent: m[1].replace(/\t/g, "    ").length,
        number: m[2] ? Number(m[2]) : null,
        letter: m[3] || null,
        text: m[4].trim(),
      });
    } else if (items.length) {
      items[items.length - 1].text += ` ${line.trim()}`;
    }
  }
  return items;
}

// Two levels, capped: top-level items and their direct children. Anything
// deeper folds into the child's own text — an unbounded tree has no stable
// address scheme.
function tree(items) {
  if (items.length === 0) return [];
  const top = Math.min(...items.map((i) => i.indent));
  const roots = [];
  let childIndent = null;
  for (const item of items) {
    if (item.indent === top) {
      roots.push({ ...item, children: [] });
      childIndent = null;
      continue;
    }
    if (roots.length === 0) continue;
    const parent = roots[roots.length - 1];
    if (childIndent === null) childIndent = item.indent;
    if (item.indent <= childIndent) parent.children.push({ ...item, children: [] });
    else if (parent.children.length) {
      const last = parent.children[parent.children.length - 1];
      last.text += `; ${item.text}`;
    } else parent.children.push({ ...item, children: [] });
  }
  return roots;
}

// `**Short title** — the full behaviour line` becomes "Short title".
function boldLead(text) {
  const m = /^\*\*([^*]+)\*\*(?:\s*[—–-]\s*.+)?$/.exec(text.trim());
  return m ? m[1].trim() : null;
}

function stripMarkers(text) {
  return text.replace(/\*\*/g, "").trim();
}

function letterFor(index) {
  let n = index, out = "";
  do { out = String.fromCharCode(97 + (n % 26)) + out; n = Math.floor(n / 26) - 1; } while (n >= 0);
  return out;
}

function numberRoots(roots) {
  const allNumbered = roots.every((r) => r.number !== null);
  return roots.map((r, i) => ({ ...r, num: allNumbered ? r.number : i + 1 }));
}

/**
 * `## Phase Scope` as addressed rows.
 *
 * Each row carries both a scannable `label` and its **full brief text**. The
 * missing full text is B1: a nested leaf's row used to keep only its bolded
 * lead, so the behaviour line the row is a contract for was unreachable.
 */
function parseScope(briefText) {
  const lines = sectionLines(briefText, "Phase Scope");
  if (lines === null) return { error: "the brief has no `## Phase Scope` section" };
  const roots = numberRoots(tree(listItems(lines)));
  if (roots.length === 0) return { error: "`## Phase Scope` has no list to parse — only prose" };

  const rows = [];
  for (const root of roots) {
    if (root.children.length === 0) {
      const text = stripMarkers(root.text);
      rows.push({ id: `S${root.num}`, label: boldLead(root.text) || text, text, status: "pending" });
      continue;
    }
    const lead = boldLead(root.text);
    const lettered = root.children.every((c) => c.letter !== null);
    root.children.forEach((child, i) => {
      const leaf = stripMarkers(child.text);
      // The label joins the category to the leaf's own handle, the same way an
      // Exit leaf's does. A bare "Write on change" in the table says nothing
      // about which item it belongs to, and the ledger is read by scanning.
      const handle = boldLead(child.text) || leaf;
      rows.push({
        id: `S${root.num}${lettered ? child.letter : letterFor(i)}`,
        label: lead ? `${lead} — ${handle}` : handle,
        text: lead ? `${lead} — ${leaf}` : leaf,
        status: "pending",
      });
    });
  }
  const seen = new Set();
  for (const row of rows) {
    if (seen.has(row.id)) return { error: `the brief numbers two Phase Scope items ${row.id.slice(1)}` };
    seen.add(row.id);
  }
  return { rows };
}

function parseExitCriteria(briefText) {
  const lines = sectionLines(briefText, "Exit Criteria");
  if (lines === null) return { error: "the brief has no `## Exit Criteria` section" };
  const roots = numberRoots(tree(listItems(lines)));
  if (roots.length === 0) return { error: "`## Exit Criteria` has no list to parse — only prose" };

  const rows = [];
  for (const root of roots) {
    const lead = boldLead(root.text);
    if (root.children.length === 0) {
      const text = stripMarkers(root.text);
      rows.push({ id: `E${root.num}`, label: text, text, status: "pending" });
      continue;
    }
    const lettered = root.children.every((c) => c.letter !== null);
    root.children.forEach((child, i) => {
      const leaf = stripMarkers(child.text);
      const text = lead ? `${lead} — ${leaf}` : leaf;
      rows.push({
        id: `E${root.num}${lettered ? child.letter : letterFor(i)}`,
        label: text,
        text,
        status: "pending",
      });
    });
  }
  const seen = new Set();
  for (const row of rows) {
    // parseExitCriteria used to skip this check entirely (B4b): a brief with
    // two `b.` leaves under one category produced two E2b rows.
    if (seen.has(row.id)) return { error: `the brief numbers two Exit Criteria leaves ${row.id.slice(1)}` };
    seen.add(row.id);
  }
  return { rows };
}

function projectName(briefText) {
  const m = /^#\s+Phase Brief\s+—\s+(.+?)\s+—\s+Phase\s+\d+/m.exec(String(briefText));
  return m ? m[1].trim() : null;
}

/**
 * A digest over the brief's addressed sections: Phase Goal, Phase Scope, Not
 * This Phase, Exit Criteria. UTF-8, line endings normalised to LF, and no other
 * normalisation — a whitespace edit inside an addressed section is a brief edit
 * and must fail closed, not be smoothed away.
 */
function contractDigest(briefText) {
  const text = String(briefText).replace(/\r\n?/g, "\n");
  const lines = text.split("\n");
  const blocks = ADDRESSED_SECTIONS.map((heading) => {
    const start = lines.findIndex((l) => new RegExp(`^##\\s+${heading}\\s*$`, "i").test(l.trim()));
    if (start === -1) return ` missing:${heading}`;
    const body = [];
    for (let i = start; i < lines.length; i++) {
      if (i > start && /^##\s+/.test(lines[i])) break;
      body.push(lines[i]);
    }
    return body.join("\n");
  });
  return crypto.createHash("sha256").update(blocks.join(" "), "utf8").digest("hex").slice(0, 16);
}

// ---- render ---------------------------------------------------------------

function renderLedger({
  project, phaseNumber, owner, contract, scope, exit, rework = [], contracts = new Map(),
  title = null,
}) {
  // A re-render keeps the ledger's original heading verbatim; only `init`
  // composes one, from the brief's own project name and the phase identity.
  const heading = title
    || `# Progress — ${project ? `${project} — ` : ""}Phase ${phaseNumber}${owner ? ` — Owner: ${owner}` : ""}`;
  const L = [heading, "", VERSION_MARKER, `<!-- contract: ${contract} -->`, ""];
  L.push("## Scope", "", SCOPE_HEADER, SCOPE_SEPARATOR);
  for (const r of scope) L.push(formatRow(r.id, r.label, r.status));
  L.push("", "## Exit Criteria", "", EXIT_HEADER, EXIT_SEPARATOR);
  for (const r of exit) L.push(formatRow(r.id, r.label, r.status));
  // Both optional sections are omitted entirely until something needs them.
  if (rework.length) {
    L.push("", "## Rework", "", REWORK_HEADER, REWORK_SEPARATOR);
    for (const r of rework) L.push(formatRow(r.id, r.label, r.status));
  }
  if (contracts.size) {
    L.push("", "## Row Contracts");
    for (const [id, body] of contracts) L.push("", ...renderContract(id, body));
  }
  return L.join("\n") + "\n";
}

// ---- parse + validate -----------------------------------------------------

const TABLE_SECTIONS = { Scope: "S", "Exit Criteria": "E", Rework: "R" };

/**
 * Parse and validate a ledger.
 *
 * Returns { ok: true, ledger } or { ok: false, errors }. There is no third
 * outcome and no "best effort" ledger: a ledger that does not validate is
 * `invalid`, and the only repair is to delete it and re-run `mano build`. No
 * migration path exists because no v1 ledger was ever released.
 */
function parseLedger(text) {
  const errors = [];
  const lines = String(text).replace(/\r\n?/g, "\n").split("\n");

  const title = lines.find((l) => /^#\s+Progress\b/.test(l.trim())) || null;
  if (!title) errors.push("no `# Progress ...` heading");
  if (!lines.some((l) => VERSION_RE.test(l.trim()))) {
    errors.push(`no \`${VERSION_MARKER}\` marker — a ledger without it is not a v2 ledger`);
  }
  const contractLine = lines.map((l) => CONTRACT_RE.exec(l.trim())).find(Boolean);
  if (!contractLine) errors.push("no `<!-- contract: ... -->` digest");

  // Section spans, so a row can be checked against the table it sits in.
  const sections = [];
  lines.forEach((line, i) => {
    const m = /^##\s+(.+?)\s*$/.exec(line);
    if (m) sections.push({ name: m[1].trim(), start: i, end: lines.length });
  });
  sections.forEach((s, i) => { if (sections[i + 1]) s.end = sections[i + 1].start; });

  const counts = {};
  for (const s of sections) counts[s.name] = (counts[s.name] || 0) + 1;
  for (const name of ["Scope", "Exit Criteria"]) {
    if (!counts[name]) errors.push(`no \`## ${name}\` section`);
    else if (counts[name] > 1) errors.push(`${counts[name]} \`## ${name}\` sections — a ledger has exactly one`);
  }

  const scope = [];
  const exit = [];
  const rework = [];
  const seen = new Set();

  for (const section of sections) {
    const expected = TABLE_SECTIONS[section.name];
    if (!expected) continue;
    for (let i = section.start + 1; i < section.end; i++) {
      const cells = rowCells(lines[i]);
      if (!cells || cells.length < 3) continue;
      const first = cells[0];
      if (!first || first === "#" || /^-{2,}$/.test(first)) continue;
      const status = (cells[cells.length - 1] || "").toLowerCase();
      const label = cells[1];

      if (expected === "R") {
        const parsed = parseReworkId(first);
        if (!parsed) {
          errors.push(`\`${first}\` in \`## Rework\` is not a rework address (R1, R2, ...)`);
          continue;
        }
        if (seen.has(parsed.id)) errors.push(`duplicate row id ${parsed.id}`);
        seen.add(parsed.id);
        if (!REWORK_STATUSES.includes(status)) {
          errors.push(`${parsed.id} has status "${status}"; rework takes ${REWORK_STATUSES.join(" | ")}`);
        }
        rework.push({ id: parsed.id, number: parsed.number, label, status, line: i });
        continue;
      }

      const parsed = parseRowId(first);
      if (!parsed) {
        errors.push(`\`${first}\` is not a row address`);
        continue;
      }
      if (parsed.table !== expected) {
        errors.push(`${parsed.id} sits in \`## ${section.name}\`, but its prefix names the other table`);
        continue;
      }
      if (seen.has(parsed.id)) errors.push(`duplicate row id ${parsed.id}`);
      seen.add(parsed.id);
      const allowed = statusesFor(parsed.table);
      if (!allowed.includes(status)) {
        const table = parsed.table === "S" ? "Scope" : "Exit Criteria";
        errors.push(`${parsed.id} has status "${status}"; ${table} takes ${allowed.join(" | ")}`);
      }
      const row = { id: parsed.id, parsed, label, status, line: i };
      (parsed.table === "S" ? scope : exit).push(row);
    }
  }

  if (counts["Scope"] === 1 && scope.length === 0) errors.push("`## Scope` has no rows");
  if (counts["Exit Criteria"] === 1 && exit.length === 0) errors.push("`## Exit Criteria` has no rows");

  const contractsSection = sections.find((s) => s.name === "Row Contracts");
  const contracts = contractsSection
    ? parseContracts(lines, contractsSection.start + 1, contractsSection.end)
    : new Map();

  const byId = new Map([...scope, ...exit].map((r) => [r.id, r]));
  for (const row of [...scope, ...exit]) {
    const parentId = parentIdOf(row.parsed);
    if (parentId && !byId.has(parentId)) {
      errors.push(`${row.id} has no parent row ${parentId}`);
    }
    if (row.parsed.kind !== "normal") {
      const body = contracts.get(row.id);
      if (!body || !body.text) {
        errors.push(`${row.id} carries its own contract but has no \`### ${row.id}\` text in \`## Row Contracts\``);
      }
    }
    // A correction to scope must say which promise it changes, or the phase can
    // close with the correction built and its evidence never asked for.
    if (row.parsed.table === "S" && row.parsed.plus && row.parsed.sub === 0) {
      const body = contracts.get(row.id) || {};
      const affects = String((body.attributes || {}).affects || "")
        .split(",").map((v) => v.trim()).filter(Boolean);
      if (affects.length === 0) {
        errors.push(`${row.id} names no affected Exit Criterion (\`affects:\` in \`## Row Contracts\`)`);
      }
      for (const target of affects) {
        if (!byId.has(target)) errors.push(`${row.id} affects ${target}, which is not a row in this ledger`);
      }
    }
    if (row.status === "needs-human") {
      const body = contracts.get(row.id) || {};
      if (!String((body.attributes || {}).reason || "").trim()) {
        errors.push(`${row.id} is needs-human with no \`reason:\` in \`## Row Contracts\``);
      }
    }
  }

  for (const event of rework) {
    const body = contracts.get(event.id);
    if (!body || !body.text) {
      errors.push(`${event.id} has no \`### ${event.id}\` text in \`## Row Contracts\``);
    }
    if (event.status === "dismissed") {
      const attributes = (body || {}).attributes || {};
      if (!String(attributes["dismissed-reason"] || "").trim()) {
        errors.push(`${event.id} is dismissed with no \`dismissed-reason:\` in \`## Row Contracts\``);
      }
    }
  }
  const reworkNumbers = rework.map((r) => r.number);
  if (reworkNumbers.some((n, i) => i > 0 && n <= reworkNumbers[i - 1])) {
    errors.push("`## Rework` events are out of order");
  }

  if (errors.length) return { ok: false, errors };

  scope.sort((a, b) => compareRows(a.parsed, b.parsed));
  exit.sort((a, b) => compareRows(a.parsed, b.parsed));
  return {
    ok: true,
    ledger: {
      lines,
      title,
      contract: contractLine[1],
      scope,
      exit,
      rework,
      contracts,
      byId,
    },
  };
}

// ---- hierarchy and resume -------------------------------------------------

/**
 * Rows that a **split** hangs off. A roll-up is never directly actionable.
 *
 * Only a split makes a roll-up. A split is a partition of its parent, so the
 * parent's work is entirely covered by its children and writing a status on it
 * would be writing over derived state. A correction is not a partition — it is
 * extra work beside the item it corrects — so a corrected row stays actionable
 * and keeps owning its own original contract.
 */
function rollUpIds(rows) {
  const parents = new Set();
  for (const row of rows) {
    if (!row.parsed.sub) continue;
    parents.add(parentIdOf(row.parsed));
  }
  return parents;
}

/**
 * The first open **deepest** leaf, in comparator order.
 *
 * B2: taking the first non-done row in *file* order returns the roll-up parent
 * (`S2 doing`) instead of the child that actually owes work (`S2.2 pending`),
 * so a fresh session re-derived finished work.
 */
function nextActionableRow(scopeRows) {
  const parents = rollUpIds(scopeRows);
  const ordered = [...scopeRows].sort((a, b) => compareRows(a.parsed, b.parsed));
  return ordered.find((r) => !parents.has(r.id) && r.status !== "done") || null;
}

/** A roll-up parent's status is derived from its children, never written. */
function derivedParentStatus(children) {
  if (children.every((c) => c.status === "done")) return "done";
  if (children.some((c) => c.status !== "pending")) return "doing";
  return "pending";
}

/** Every row that names `id` as its parent — splits and corrections alike. */
function childrenOf(rows, id) {
  return rows.filter((r) => parentIdOf(r.parsed) === id);
}

/** The split parts of `id`. These, and only these, derive its status. */
function splitChildrenOf(rows, id) {
  return rows.filter((r) => r.parsed.sub > 0 && parentIdOf(r.parsed) === id);
}

/** The corrections hanging off `id`, in allocation order. */
function correctionChildrenOf(rows, id) {
  return rows.filter((r) => r.parsed.plus > 0 && r.parsed.sub === 0 && parentIdOf(r.parsed) === id);
}

module.exports = {
  ROW_ID, REWORK_ID,
  SCOPE_STATUSES, EXIT_STATUSES, REWORK_STATUSES,
  SCOPE_HEADER, SCOPE_SEPARATOR, EXIT_HEADER, EXIT_SEPARATOR, REWORK_HEADER, REWORK_SEPARATOR,
  VERSION_MARKER, ADDRESSED_SECTIONS,
  parseRowId, parseReworkId, parentIdOf, sortKey, compareRows, kindOf,
  statusesFor, rank, cell, formatRow, rowCells, deriveLabel,
  fenceFor, renderContract, parseContracts,
  sectionLines, listItems, tree, boldLead, letterFor,
  parseScope, parseExitCriteria, projectName, contractDigest,
  renderLedger, parseLedger,
  rollUpIds, nextActionableRow, derivedParentStatus,
  childrenOf, splitChildrenOf, correctionChildrenOf,
};
