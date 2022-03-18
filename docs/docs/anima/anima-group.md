---
sidebar_position: 3
---

# Anima.Group

This class is used to animate all the direct child of the node specified.

## Syntax

```gdscript
Anima.Group(group: Node, items_delay: float, animation_type: int = GROUP.FROM_TOP, point := 0)
```

| param | type | Default | Description |
|---|---|---|---|
| group | Node | | The node of whom children we want to animate |
| items_delay | float | | The incremental delay to apply for each child of the group |
| animation_type | [Anima.GRID](/docs/anima/#group--grid)  | GROUP.FROM_TOP | The order to which animate the elements |
| point | int | 0 | The starting point of the animation |
