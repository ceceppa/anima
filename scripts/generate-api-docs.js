#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const sourceDirs = [
  path.join(root, "addons/anima/motion/resources"),
  path.join(root, "addons/anima/motion/runtime"),
  path.join(root, "addons/anima/editor"),
];
const outputDir = path.join(root, "docs/content/docs/anima");

function filesIn(directory) {
  return fs.readdirSync(directory, { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".gd"))
    .map((entry) => path.join(directory, entry.name));
}

function identifier(line) {
  const declaration = line.replace(/^@[A-Za-z_]+(?:\([^)]*\))?\s+/, "");
  const match = declaration.match(/^(class_name|func|static func|var|const|signal|enum)\s+([A-Za-z][A-Za-z0-9_]*)/);
  if (!match || match[2].startsWith("_")) return null;
  return { kind: match[1], name: match[2] };
}

function commentAbove(lines, index) {
  const comment = [];
  for (let cursor = index - 1; cursor >= 0; cursor -= 1) {
    const line = lines[cursor].trim();
    // A bare annotation line with nothing else on it (e.g. a standalone
    // `@tool`) sits between a comment and its declaration in some styles;
    // skip past it. A full sibling declaration also starts with `@` (this
    // codebase writes `@export var name = value` on one line) but has more
    // after the annotation, so it falls through to the stop check below
    // instead of being skipped — otherwise the scan walks straight past a
    // preceding property into *its* comment block and accumulates it too.
    if (/^@[A-Za-z_]+(?:\([^)]*\))?$/.test(line)) continue;
    if (!line.startsWith("##")) break;
    comment.unshift(line.replace(/^## ?/, ""));
  }
  return comment.join("\n").trim();
}

function kebabCase(name) {
  if (name === "Anima") return "anima";
  if (name === "Motion") return "anima-motion-builder";
  return name.replace(/^Anima/, "anima-").replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();
}

function parseSource(file) {
  const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);
  const publicMembers = [];
  let className = null;
  let classDoc = "";
  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index];
    if (/^\s/.test(line)) continue;
    const found = identifier(line.trim());
    if (!found) continue;
    const documentation = commentAbove(lines, index);
    if (!documentation) throw new Error(`${path.relative(root, file)}:${index + 1}: ${found.name} needs a ## documentation comment`);
    if (found.kind === "class_name") {
      className = found.name;
      classDoc = documentation;
    } else {
      publicMembers.push({ ...found, documentation });
    }
  }
  return className ? { className, classDoc, publicMembers } : null;
}

function pageFor(api) {
  const groups = new Map();
  for (const member of api.publicMembers) {
    const section = member.kind.includes("func") ? "Methods" : member.kind === "signal" ? "Signals" : member.kind === "enum" ? "Enumerations" : "Properties and constants";
    if (!groups.has(section)) groups.set(section, []);
    groups.get(section).push(member);
  }
  const description = api.classDoc.split("\n")[0].replace(/"/g, "\\\"");
  let page = `---\ntitle: "${api.className}"\ndescription: "${description}"\n---\n\n# ${api.className}\n\n## Overview\n\n${api.classDoc}\n\n## Availability\n\nGodot 4.x and Anima 2.x.\n\n## Quick example\n\nSee the class and member help in the Godot editor for a minimal, runnable example.\n`;
  for (const [section, members] of groups) {
    page += `\n## ${section}\n`;
    for (const member of members) page += `\n### ${member.name}\n\n${member.documentation}\n`;
  }
  return page;
}

function main() {
  const apis = sourceDirs.flatMap(filesIn).map(parseSource).filter(Boolean);
  fs.mkdirSync(outputDir, { recursive: true });
  for (const api of apis) {
    fs.writeFileSync(path.join(outputDir, `${kebabCase(api.className)}.md`), pageFor(api));
  }
  process.stdout.write(`Generated ${apis.length} API reference pages.\n`);
}

main();
