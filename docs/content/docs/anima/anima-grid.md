---
weight: 400
title: "Anima.Grid"
description: "Anima.Grid class reference"
draft: false
---

This class is used to animate all the direct child of the node specified.

## Syntax

```gdscript
Anima.Grid(grid: Node, grid_size: Vector2, items_delay: float, animation_type: int = GROUP.FROM_TOP, point := 0)
```

| param | type | Default | Description |
|---|---|---|---|
| group | Node | | The node of whom children we want to animate |
| grid_size | Vector2 | | The grid size |
| items_delay | float | | The incremental delay to apply for each child of the group |
| animation_type | [ANIMA.GRID](#animation-type) | ANIMA.GRID.FROM_TOP_RIGHT | The order to which animate the elements |
| point | Vector2 | Vector2.ZERO | The starting point of the animation |


{{% animation-type %}}

{{% anima-declaration class="Grid" init="Vector2(2, 2), 0.1" distance="1" %}}

