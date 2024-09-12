---
weight: 200
title: "The current value"
description: ""
icon: "developer_guide"
draft: false
---

When you create an animation, you can tell Anima exactly where to start and where to end.
Or, you can just tell it where to end, and it will figure out where to start based on the current position.

## 1. All is set

In this case, we give Anima all the info needed to create the animation, so it doesn't matter when this is created.

```gdscript
(
    Anima.Node(self)
    .anima_position_x(100, 1)
    .anima_from(0)
    .play()
)
```

This code animates the `x` position from **0** to **100** in 1 second.
We specified the initial value as **0** and the final value as **100**.

## 2. The current value

{{< alert context="warning" text="When the animation is created matters!" />}}

To understand what this means, let's consider the following example:

![Image of a cross Sprite](/images/tutorials/fundamentals-cross.png)

In our test scene, we have a Button and a **Sprite**:

- Sprite with the initial position of `Vector2(490, 280)`.
- Button animates the Sprite to a final position of `x = 600` using 1 second.

Now let's consider the following two animations:

<table style={{ width: '100%' }}><tr style={{ width: '100%'}}>

<th style={{ width: '50%' }}>Initialise the animation on: `_ready`</th>
<th style={{ width: '50%' }}>
  Initialise the animation on: `_on_Button_pressed`
</th>

</tr>
<tr style={{ width: '100%'}}>
<td valign="top">

```gdscript
var anima: AnimaNode

func _ready():
  anima = Anima.Node($sprite).anima_position_x(600, 1)

func _on_Button_pressed():
    anima.play()
```

</td>
<td valign="top">

```gdscript
func _on_Button_pressed():
    (
        Anima.Node($sprite)
        .anima_position_x(600, 1)
        .play()
    )
```

</td>

</tr></table>

We only specified the final `x` value, leaving Anima to use the current `x` value as the initial value.

{{% alert context="info" %}}
Remember we said that Anima uses the initial value when the animation is created?
Let's play the animations and see what this means:
{{% /alert %}}

<table>
<tr>
 <th>_ready</th>
 <th>_on_Button_pressed</th>
</tr>

<tr>
  <td>

Anima animates `x` from **490** _to_ **600**.

**490** is the `x` value found when initialising the animation on `_ready`.

</td>
<td>

Anima animates `x` from **490** _to_ **600**.

**490** is the `x` value found when initialising the animation on `_on_Button_pressed`.

</td>
</tr>
</table>

{{% alert  %}}
Both codes behave the same here, but what happens if we re-trigger the animation?
{{% /alert %}}

<table>
<tr>
 <th>_ready</th>
 <th>_on_Button_pressed</th>
</tr>

<tr>
  <td>

We press the button:

- Anima animates `x` from **490** _to_ **600**.

Before the animation completes, we press the button again:

- Anima is animating `x` from **490** _to_ **600**.

Here the initial value of `x` is always **490** because we're reusing the same animation we initialised on `_ready`.

</td>
<td>

We press the button:

- Anima animates `x` from **490** _to_ **600**.

Before the animation completes, we press the button again:

- Anima is animating `x` from **??** _to_ **600**.

Here the initial `x` value depends on when we re-trigger the animation again. If we trigger the animation again once it
has completed, we will have:

- Initial `x = 600`
- Final `x = 600`

`x` is calculated when the animation is created and, in this case, matches with the final value. If we re-trigger the animation before
it reaches the final `x` position, and then the initial value will be a number between **490** and **600**.

</td>
</tr>
</table>

As we can see, when the animation is initialised matters!
This is true especially if we use built-in animations or animation frames, where positions are specified as relative or the current value.

## Loop strategy for relative data

Loops behave in the same way. By default, the initial value is set when the loop animation is initialised, for example:

### Example

```gdscript
func _ready():
  anima = Anima.begin(self) \
    .then(
      Anima.Node($sprite)
        .anima_relative_position_x(100, 1)
    )

func _on_Button_pressed():
    anima.loop()
```

In this case Anima loops the Sprite `x` position from **490** to **490 + 100 = 590**.

### What if we want the final value to be the next initial one?

Simple, by using the [set_loop_strategy](/docs/anima-node/#set_loop_strategy).

This method tells Anima what to do when a loop completes:

```
enum LOOP_STRATEGY {
   USE_EXISTING_RELATIVE_DATA,
   RECALCULATE_RELATIVE_DATA,
}
```

Anima uses `LOOP.USE_EXISTING_RELATIVE_DATA` by default so that we can change the behaviour with:

```
func _ready():
  anima = Anima.begin(self) \
    .set_loop_strategy(Anima.LOOP_STRATEGY.RECALCULATE_RELATIVE_DATA) \
    .then(
      Anima.Node($sprite)
        .anima_relative_position_x(100, 1)
    )

func _on_Button_pressed():
    anima.loop()
```

When we play this animation, the Sprite `x` position will be animated indefinitely as the starting point will get updated at each loop.

:::caution

This method re-calculates only relative data!
:::
