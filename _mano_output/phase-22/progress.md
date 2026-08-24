# Progress — Anima — Phase 22

<!-- mano-progress: v2 -->
<!-- contract: 262c2f470d746c03 -->

## Scope

| # | What | Status |
|---|------|--------|
| S1a | Automatic layout transitions — Visual transition | done |
| S1b | Automatic layout transitions — Supported boundaries | done |
| S2a | Visual verification scenarios — Layout demonstration | done |
| S2b | Visual verification scenarios — Interruption coverage | done |

## Exit Criteria

| # | Criterion | Status |
|---|-----------|--------|
| E1a | Automatic layout motion — Run the layout demonstration and trigger a supported layout change: every supported Control reaches Godot's final position and size without a visible snap. | met |
| E1b | Automatic layout motion — Inspect the completed layout demonstration: the final arrangement remains the one selected by Godot. | met |
| E2a | Interruption scenarios — Run each interruption scenario: replace, retarget, queue, and reverse each show a distinct resulting motion outcome. | met |
| E2b | Interruption scenarios — Restart each interruption scenario: it returns to its defined starting state before the next run. | met |

## Rework

| # | Finding | Status |
|---|---------|--------|
| R1 | mano build so the animate_layout things seems possible, but my solution… | resolved |
| R2 | almost there is a bug tho: _is_animating = false is set while the anima… | resolved |
| R3 | mano build can we make _animate_change needs to validate the _is_animat… | resolved |

## Row Contracts

### R1
source: build

```text
mano build so the animate_layout things seems possible, but my solution is the one to improve. We cannot extends RefCounted as it does not receive the item_rect_changed or resize events.

So, my solution works without flickering, but need to improved to make sure that disconnect and connect works fine even if the animation isn't played
```

### R2
source: build

```text
almost there is a bug tho: _is_animating = false is set while the animation is running. It needs to wait for all the animations to be completed
```

### R3
source: build

```text
mano build can we make _animate_change needs to validate the _is_animating for a specific control. Because I can see the size being animated, but not the position of %Last. I'm assuming Godot triggers the event a node at the time. So when %Middle sizes increases, %Last position is still the original one. When then Godot triggers the position change, `_is_animating` because we're animating %Middle, so %Last "jumps" to its final position
```
