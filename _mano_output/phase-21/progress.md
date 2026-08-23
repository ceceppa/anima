# Progress — Phase 21

<!-- mano-progress: v2 -->
<!-- contract: 5a846daa63def077 -->

## Scope

| # | What | Status |
|---|------|--------|
| S1a | Motion conflict handling — Ownership | done |
| S1b | Motion conflict handling — Interruption choices | done |
| S1c | Motion conflict handling — Observable outcome | done |
| S2a | Demo selector — Showcase category | done |

## Exit Criteria

| # | Criterion | Status |
|---|-----------|--------|
| E1a | Motion ownership — Start a motion, then request another motion on the same property: the system identifies the active owner and applies the selected interruption behaviour | met |
| E2a | Interruption outcomes — Start a motion using each supported interruption choice: the affected property reaches the result defined by that choice without simultaneous conflicting writes | met |
| E2b | Interruption outcomes — Queue a second motion behind an active motion: the queued motion starts only after the active motion's policy-defined outcome | met |
| E3a | Showcase discovery — Open the demo selector and choose Showcase: Grid Showcase is listed and can be opened | met |

## Row Contracts

### E3a
reason: The headless editor validates the selector scene and script, but a person must open the Showcase tab and Grid Showcase to confirm the visible category and navigation.
provenance: human sign-off at review, 2026-08-24
