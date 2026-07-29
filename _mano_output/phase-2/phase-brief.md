# Phase Brief — Anima — Phase 2

<!-- Self-contained. Everything needed to understand this phase is here. -->

## Why This Phase

Phase 1 shipped the core relational-motion runtime with no developer documentation, and the docs site still describes v1 classes that no longer exist in the repo. Closing that gap now, before more runtime surface ships, keeps the docs from falling further behind the code.

## Vision

A developer lands on the docs site, finds a page for any Phase 1 class, and can understand what it does and how to use it from that page alone — without reading GDScript source. Nothing on the site still describes a class that was deleted.

## Design Principle

When a documentation decision trades off depth against simplicity, favour the reader who has never touched Godot or GDScript before over the reader who already knows Anima.

## Phase Goal

Every Phase 1 class has a complete, beginner-friendly documentation page, and the docs site no longer contains any v1-specific content.

## Phase Scope

- A documentation page for each of the 12 Phase 1 classes: `AnimaMotion`, `AnimaSequence`, `AnimaParallel`, `AnimaPropertyMotion`, `AnimaEase`, `AnimaPlayback`, `AnimaRuntime`, `Anima`, `AnimaMotionInstance`, `AnimaPropertyMotionInstance`, `AnimaSequenceInstance`, `AnimaParallelInstance`.
- Every page follows the project's documentation-page convention and is written for a developer with zero prior Godot or coding experience.
- All v1-specific content removed from the docs site: the direct class-reference pages under the API reference section, plus the guides, tutorials, and features pages describing v1's workflow.

## Not This Phase

- No new guides, tutorials, or features content describing the v2 API — deferred until the API is more complete (tracked separately in the backlog).
- No changes to runtime code — this phase is documentation only.
- No design of the documentation-page convention itself — codifying that template is a separate concern; this phase applies it.

## Exit Criteria

1. Class reference
   - Open the docs site's API reference section: a page exists for each of the 12 Phase 1 classes
   - Open any one of those pages: it follows the documentation-page convention and reads clearly to someone with no prior Godot or coding background
2. Legacy removal
   - Search the docs site for v1-specific content: no class-reference page, guide, tutorial, or feature page describing a deleted class or v1 workflow remains

## Assumption Log

| Assumption | Risk if wrong |
|---|---|
| The documentation-page convention is stable enough to write all 12 pages against as-is. | If the convention changes materially after these pages are written, some or all of them may need reformatting rather than just extending. |

## Acknowledged Risks

- This is the first real content pass through the docs site's build tooling since it was scaffolded — the actual generated output hasn't been exercised yet, so unexpected structural adjustments may be needed once it is.

<!-- Future work, deferred items, and ideas live in _mano_output/backlog.md — not here. -->
