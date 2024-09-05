---
weight: 500
title: "Anima.Group"
description: "Anima.Group class reference"
draft: false
---


This class is used to animate all the direct child of the node specified.

## Syntax

```gdscript
Anima.Group(group: Node, items_delay: float, animation_type: int = GROUP.FROM_TOP, point := 0)
```

| param | type | Default | Description |
|---|---|---|---|
| group | Node | | The node of whom children we want to animate |
| items_delay | float | | The incremental delay to apply for each child of the group |
| animation_type | [ANIMA.GRID](#animation-type) | ANIMA.GROUP.FROM_TOP | The order to which animate the elements |
| index | int | 0 | The starting index of the animation |

{{% animation-type %}}

## Staggered Animation

Selecting the starting index is inside the range `]0, GROUP_LENGTH[` creates a staggering animation, where node starting delay depends by its absolute distance from that point. 


Let's consider the following group with 7 buttons:

![Control node with 7 children](/img/group-example.png)

And animate them from the middle using, for semplicity, a delay of 1 second between each node:

```gdscript
Anima.Group($Control, 1, ANIMA.GROUP.FROM_CENTER) \
    .anima_fade_in()

# or

Anima.Group($Control, 1, ANIMA.GROUP.FROM_INDEX, ($Control.get_child_count() - 1) / 2) \
    .anima_fade_in()

```

The middle node of this group is: **Button4** with an index of **3**, then:

- *Button3* and *Button5* have an absolute distance from *Button4* of **1**
- *Button2* and *Button5* have an absolute distance from *Button4* of **2**
- *Button1* and *Button5* have an absolute distance from *Button4* of **3**

So this is equivalent to:

1. Fade in **Button4**
2. Wait 1 second
3. Fade in **Button3** and **Button5**
4. Wait 1 second
3. Fade in **Button2** and **Button6**
2. Wait 1 second
3. Fade in **Button1** and **Button7**

{{% anima-declaration class="Grid" init="Vector2(2, 2), 0.1" distance="1" %}}
