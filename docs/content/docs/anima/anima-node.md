---
weight: 200
title: "Anima.Node"
description: "Anima.Node class reference"
draft: false
---

This class is used to animate a single node.

## Syntax

```gdscript
Anima.Node(node: Node, delay = null) -> AnimaDeclaration
```

| param | type | Description |
|---|---|---|
| node | Node | The node to animate |
|delay | float | The delay before starting the animation |

## Example

```gdscript
(
   Anima.Node($Label)
   .anima_fade_in()
   .play_with_delay(0.5)
)
```

{{% anima-declaration class="Node" init="self" %}}
