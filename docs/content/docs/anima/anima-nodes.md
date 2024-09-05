---
weight: 250
title: "Anima.Nodes"
description: "Anima.Nodes class reference"
draft: false
---

The `Anima.MultiNode` class allows you to animate multiple independent nodes simultaneously.  This provides a flexible way to create custom animation groups beyond the built-in `Anima.Group` and `Anima.Grid` classes.

**Key Distinction:**

Unlike `Anima.Group` and `Anima.Grid`, which target the children of a node, `Anima.MultiNode` directly animates the specified nodes themselves. This enables you to define your own "group" of nodes for animation, regardless of their hierarchical relationship. 

## Syntax

```gdscript
Anima.Nodes(node: Array[Node], items_delay: int = 0) -> AnimaDeclaration
```

| param | type | Description |
|---|---|---|
| node | Nodes | An array of nodes to animate |
|delay | float | The incremental delay to apply for each node in the group |

## Example

```gdscript
(
    Anima.Nodes([self, $Label, $Sprite], 0.1)
    .anima_fade_in()
    .play()
)
```

{{% anima-declaration class="Nodes" init="[self, $Label, $Sprite]" %}}
