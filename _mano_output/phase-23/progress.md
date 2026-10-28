# Progress — Anima — Phase 23

<!-- mano-progress: v2 -->
<!-- contract: b39f3b7954a13419 -->

## Scope

| # | What | Status |
|---|------|--------|
| S1a | Visibility strategy — Per-motion strategy | done |
| S1b | Visibility strategy — Entrance and exit presets apply it | done |
| S2a | Starting-value timing — Per-motion timing choice | done |
| S3a | Playground coverage — Visible scenario | done |

## Exit Criteria

| # | Criterion | Status |
|---|-----------|--------|
| E1a | Hidden and transparent targets — Play an entrance motion on a node that starts hidden, with the strategy set to unhide it: the node becomes visible before the motion plays and the motion completes normally | met |
| E1b | Hidden and transparent targets — Play an entrance motion on a node that starts fully transparent, with the strategy set to make it opaque: the node becomes visible before the motion plays | met |
| E1c | Hidden and transparent targets — Play an entrance motion on a hidden node with the strategy set to leave it alone: the node stays hidden and nothing visible happens | met |
| E1d | Hidden and transparent targets — Play an exit motion configured to hide its target afterward: once playback finishes, the node is hidden | met |
| E2a | Starting-value timing — Set a motion to apply its starting values immediately: the target shows those values as soon as the motion is set up, with no flash of its previous appearance when playback later begins | met |
| E2b | Starting-value timing — Set a motion to apply its starting values only on play: the target keeps its current appearance until playback begins, then jumps to the starting values | met |
| E3a | Playground coverage — Open the playground and run the updated entrance/exit scenario: both the visibility-strategy and starting-value-timing choices are visible and testable without reading code | met |
