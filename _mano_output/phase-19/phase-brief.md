# Phase Brief — Anima — Phase 19

## Why This Phase

Requested twice during phase-18 review: there is no documentation for Anima's core authoring surfaces, and a developer new to the addon currently has no way to learn `Anima.on`/`.group`/`.grid`, the built-in catalog, keyframes, dynamic values, or easings without reading source.

## Design Principle

Newbie-friendly, every concept backed by a runnable example — favour runnable examples over prose, write for someone new to Godot, and defer anything that needs deep Anima-internals knowledge to read.

## Core Product Principles

- Composition over inheritance: Anima attaches to ordinary Godot nodes. Examples should never introduce an `AnimatedButton`/`AnimatedLabel`-style subclass.

## Phase Goal

A developer new to Anima can open the documentation site and, through a Features reference, six conceptual Guides, and two step-by-step Tutorials, learn every core authoring surface without reading source.

## Phase Scope

- A Features section: one reference page listing the built-in animation catalog, one listing the built-in easing curves — each entry showing a runnable code example.
- A Guides section covering six concepts, each with a runnable code example: reusable vs. single-shot motions, composing multiple animations, animating relative values, dynamic values, and animation keyframes (`AnimaKeyframeMotion` and `AnimaKeyframeTrack` each get their own guide).
- A Tutorials section: a numbered "01: Basic Animation" walkthrough and a "02: Popup Animation" walkthrough that builds on it using sequential composition.
- All content ships as documentation pages on the existing Hugo site; no new example scenes or scripts are added to the repository this phase.

## Not This Phase

- No documentation for unbuilt features (Motion Composer, layout transitions, shared elements, the native-Animation compiler, migration from other addons) — this phase covers only what already ships.
- No "current value" guide — v2 has no public query API for a motion's live value yet; nothing to honestly document.
- No new runnable Godot example scenes or scripts under `examples/` — this phase is documentation-only.
- No search, versioning, or other documentation-site infrastructure beyond adding these pages to the existing Hugo site.

## Exit Criteria

1. Features
   - Open the documentation site's Features section: a Built-in Animations page lists the catalog with a runnable example; a Built-in Easings page lists the curve library with a runnable example
2. Guides
   - Open the Guides section: all six guides are present (reusable vs. single-shot, multiple animations, relative values, dynamic values, `AnimaKeyframeMotion`, `AnimaKeyframeTrack`), each with a runnable code example a reader can copy into their own project
3. Tutorials
   - Open the Tutorials section: "01: Basic Animation" and "02: Popup Animation" are present, numbered, and each is a step-by-step walkthrough that ends at a working result
   - Following Tutorial 01 then Tutorial 02 in order: 02 builds on 01's result rather than starting over
4. Site builds
   - Running the existing documentation build produces no broken links or missing pages among the new content

## Validation Plan

### Questions

- Can a Godot developer with no prior Anima experience follow the Tutorials and end up with a working animation, without needing outside help?

### Try

- Have someone unfamiliar with Anima open the documentation site and follow Tutorial 01 and Tutorial 02 start to finish.

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| This phase's Features/Guides/Tutorials set is a deliberately narrowed, hand-picked slice of the deferred "Full documentation structure" backlog item (which also covers the Composer, layout, shared elements, compiler, accessibility, adapters, migration, and troubleshooting) — not the final information architecture. | The full documentation structure lands later and reorganises or renames these sections rather than simply extending them. |

## Acknowledged Risks

- Six Guides plus two Tutorials is a lot of new-writer surface area for one phase; content quality may be uneven across pages without a second editing pass.
