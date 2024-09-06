---
weight: 500
title: "Dynamic Value"
description: ""
icon: "developer_guide"
draft: false
---

Dynamic values let us provide a formula as the initial or final value that depends on a node property or its surrounding.

{{< alert context="success" text="Dynamic value is the key to creating truly reusable animations with Anima." />}}

## Fixed value

Before looking at dynamic values, let's have a look at the following example:

```gdscript
Anima.begin_single_shot(self).then(
  Anima.Group($Grid)
    .anima_property("x")
    .anima_from(-100)
).play()
```

The animation translates the group children to their current position, as [we haven't defined any final value](/docs/docs/tutorial-basics/fundamentals) for `x`, from an initial position.

In the example the initial position is `[current_value] - 100`, supposing that **100** is the width of the node(s).

### Limitations of fixed values

We assumed that **100** is the node's width, but:

1. there is no real correlation between the number and actual width
2. inside the grid, we might have nodes with different widths

Also, if we change any size of the nodes, we would then adjust the animation with the new value.

#### Let's calculate it

Sure, we could calculate the value manually, for example:

```gdscript
Anima.begin_single_shot(self).then(
  Anima.Group($Grid)
    .anima_property("x")
    .anima_from($Grid.get_child(0).rect_size.x)
).play()
```

We fix the issue number **1**, but the 2nd still stands. Also, we made the code a bit less reusable as we tightened our "from" value to a specific node.

## Dynamic value

Anima solves all the limitations of the **fixed values** by letting you specify a **dynamic formula** that is computed when the animation is initialised.


### Syntax

The syntax of a single dynamic value is:

```gdscript
[relative node]:[property]:[sub key]
```

| param | type | Required | Description |
|---|---|---|---|
| relative node | Node | no | The node from whom retrieve the `property` and `sub key`. An empty value or `.` indicates the node animated itself |
| property | Variant | *yes* | The property value to compute |
| sub key | Variant | no | The property subkey |

### Example

```gdscript
Anima.begin_single_shot(self).then(
  Anima.Group($Grid)
    .anima_property("x")
    .anima_from("-.:size:x")
).play()
```

Let's analyse the parts of the dynamic value, and we have `:size:x`

| parameter | value | description |
| --- | --- | --- |
| relative node |  | The value is empty, meaning that we're going to read the property and subkey from the node we're animating |
| property | size | The node size (or rect_size) |
| sub key | x | The size.x value |

**NOTE**: One thing we must keep in mind is that Anima creates an animation for every node in Group and Grid animations, so using `.` or `` for the **relative node** means getting the property from the current child Anima is going to animate.

Let's be more specific and consider a Grid node with the following children:

| Node | size |
|---|---|
| Button | `Vector2(100, 100)` |
| Label | `Vector2(50, 30)` |
| Sprite | `Vector2(150, 80)` |

When Anima generates the animation will compute `-:size:x` with:

| Node | from |
|---|---|
| Button | `-100` |
| Label | `-50` |
| Sprite | `-150` |

As we can see, the initial value is replaced with the animated Node width. Also, the value is negative because we specified the `-` in the formula.

We can find more example of dynamic values in the following area:

- Animate a single node
- Animate a group node
- Animate a grid
