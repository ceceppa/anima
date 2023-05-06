---
sidebar_position: 3
---
# Anima.Group

The `Anima.Group` class is used to animate all the direct children of the given node.

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

## Animation type

The animation type parameter is used to define how to animate the nodes inside the group or create staggered animations.

| Option | Description |
|---|---|
| FROM_TOP | Animates the group items from top to down |
| FROM_BOTTOM | Animates the group items from bottom to top |
| FROM_CENTER | Animated the items from the center of the group to the top and bottom at the same time. |
| TOGETHER | Animates all the items at the same time. `items_delay` is ignored |
| ODDS_ONLY | Animates the group odd items only, starting from the top |
| EVEN_ONLY | Animates the even items only, starting from the top |
| RANDOM | Randomize the group starting point |
| FROM_INDEX | The item index to start the animation |

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

## Methods

:::info
It's important to keep in mind that any of the following methods are applied to the single node of the given group. This is an important consideration when working with [Dynamic values](/tutorials/basics/dynamic-value).
:::

### anima_animation

Animates the *node* using the specified [animation](/docs/anima/animations).

#### Syntax

```gdscript
anima_animation(animation: String, duration: float)
```

| Param     | Type   | Default | Description                                                                                     |
| --------- | ------ | ------- | ----------------------------------------------------------------------------------------------- |
| animation | string |         | The animation name                                                                              |
| duration  | float  | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anim.Node($node).anima_animation("zoomIn")
Anim.Group($node).anima_animation("tada")
Anim.Grid($node).anima_animation("fadeIn")
```

### anima_animation_frames

Animates the *node* using a [CSS-Style animation](/tutorials/extras/animation-keyframes).

#### Syntax

```gdscript
anima_animation_frames(animation: Dictionary, duration: float)
```

| Param     | Type   | Default | Description                                                                                                                    |
| --------- | ------ | ------- | ------------------------------------------------------------------------------------------------------------------------------ |
| animation | string |         | The animation frames. See[Create a custom animation](docs/extend-anima/custom-animation) for more information about the syntax |
| duration  | float  | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used                                |

#### Example:

```gdscript
Anim.Node($node).anima_animation_frames({
    from = {
        opacity = 0,
        x = 0,
        y = 0,
    },
    to = {
        opacity = 1,
        x = 100
        y = 100
    },
    easing = AnimaEasing.EASING.EASE_IN_OUT
})
```

### anima_property

Animates the given property.

:::info
Compared to the other property specific functions, like `anima_position_x`, this method allows us to specify a [dynamic value](/docs/tutorial-extras/dynamic-value)
:::

#### Syntax

```gdscript
anima_property(property: String, final_value, duration)
```

| Param       | Type    | Default | Description                                                                                  |
| ----------- | ------- | ------- | -------------------------------------------------------------------------------------------- |
| property    | string  |         | The property to animate                                                                      |
| final_value | Variant | null    | (Optional) The final value. If null, the current property value is used as the final value       |
| duration    | float   | null    | The animation duration (seconds). If null, the [default duration](/docs/anima-node/) is used |

The `property` parameter can be any node property that can be accessed, even exported variables. For example:

- size
- position

We can also specify the subkey of the Vector2, Vector3 or Rect2 we want to animate, for example:

- size:x
- position:y
- size:width

Anima also recognised these built-in property names:

| property     | description                                             |
| ------------ | ------------------------------------------------------- |
| x            | This is equivalent to `position:x` or `rect_position:x` |
| y            | This is equivalent to `position:y` or `rect_position:x` |
| z            | This is equivalent to `position:z` or `rect_position:x` |
| width        | This is equivalent to `size:x` or `rect_size:x`         |
| height       | This is equivalent to `size:y` or `rect_size:y`         |
| shared_param | This will call `set_shader_param`                       |

#### Example

```gdscript
Anima.Node($node).anima_property("size:x").anima_from(100)
Anima.Node($node).anima_property("x", 200)
```

##### position vs rect_position

Although Godot prefixes some of the **Controls** properties with `rect_`, we don't need to worry about that; Anima will figure out the correct property name.

For example:

```gdscript
Anima.Node($Control).property("position:x", 100 ) # Animates rect_position.x
Anima.Node($Node2D).property("position:x", 100 )  # Animates position.x
```

### anima_delay

The delay to use before starting the animation.

#### Syntax

```gdscript
anima_delay(delay: float)
```

:::tip
You can also use negative values to anticipate the start of a sequential/parallel animation.
:::

#### Example

```gdscript
Anima.Node($node).anima_scale_x(0.8).anima_delay(0.5)

# or
Anima.Node($node).anima_scale_x(0.8).anima_delay(-0.5)
```

### anima_easing

The easing to use to animate the node.

_NOTE_: [List of available easings](/anima/constants#easings)

#### Syntax

```gdscript
anima_easing(easing: int)
```

#### Example

```gdscript
Anima.Node($node).anima_scale_x(0.8).anima_easing(ANIMA.EASINGS.EASE_IN_OUT)
```

### anima_from

Set the initial value.

#### Syntax

```gdscript
anima_from(value: Variant)
```

| Param | Type    | Description                                                                                      |
| ----- | ------- | ------------------------------------------------------------------------------------------------ |
| value | Variant | The initial value. It can be a fixed or [dynamic](/docs/tutorial-extras/dynamic-value) one. |

#### Example

```gdscript
Anima.Node($node).anima_property("x").anima_from(-100)
```

### anima_fade_in

Fades in the given element(s)

#### Syntax

```gdscript
anima_fade_in(duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).fade_in(0.4)
```

### anima_fade_out

Fades out the given element(s)

#### Syntax

```gdscript
anima_fade_out(duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).fade_out(0.4)
```

### anima_on_started

Callback to be triggered when the Node animation starts.

#### Syntax

```gdscript
anima_on_started(callback: Funcref | Callable, on_started_value, on_backwards_completed_value = null)
```

| Param                        | Type                          | Required | Description                                                                         |
| ---------------------------- | ----------------------------- | -------- | ----------------------------------------------------------------------------------- |
| callback                     | Funcref/Callable<sup>\*</sup> | yes      | The callback to call when the Node animation is starts (or complete<sup>\*\*</sup>) |
| on_started_value             | Variant                       | yes      | The parameter to pass at the callback when the Node animation is played forward     |
| on_backwards_completed_value | Variant                       | no       | The parameter to pass at the callback when the Node animation is played backwards   |

<b>
  <sup>*</sup>
</b> In Godot4 Funcref are called Callable.
<br />
<b>
  <sup>**</sup>
</b> When the animation is played backwards this event is triggered when the
Node animation starts

#### Example

```gdscript
Anima.Node($node).anima_on_started(funcref(self, "do_something"), true, false)

func do_something(is_forward) -> void:
    print(is_forward)
```

### anima_on_completed

Callback to be triggered when the Node animation completes.

#### Syntax

```gdscript
anima_on_completed(on_completed: FuncRef | Callable, on_completed_value, on_backwards_started_value = null)
```

| Param                      | Type                          | Required | Description                                                                           |
| -------------------------- | ----------------------------- | -------- | ------------------------------------------------------------------------------------- |
| callback                   | Funcref/Callable<sup>\*</sup> | yes      | The callback to call when the Node animation is completed (or started<sup>\*\*</sup>) |
| on_completed_value         | Variant                       | yes      | The parameter to pass at the callback when the Node animation is played forward       |
| on_backwards_started_value | Variant                       | no       | The parameter to pass at the callback when the Node animation is played backwards     |

<b>
  <sup>*</sup>
</b> In Godot4 Funcref are called Callable.
<br />
<b>
  <sup>**</sup>
</b> When the animation is played backwards this event is triggered when the
Node animation starts

#### Example

```gdscript
Anima.Node($node).anima_on_started(funcref(self, "do_something"), true, false)

func do_something(is_forward) -> void:
    print(is_forward)
```

### anima_pivot

The pivot point to use to animate the node.

_NOTE_: [List of available pivot points](/anima/constants#pivot-points)

#### Syntax

```gdscript
anima_pivot(easing: int)
```

#### Example

```gdscript
Anima.Node($node).anima_scale_x(0.8).anima_pivot(ANIMA.PIVOT.CENTER)
```

### anima_position

Animates the `x` and `y` position of the given element(s)

#### Syntax

```gdscript
anima_position(position: Vector2, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| position | Vector2 |         | The final 2D position                                                                           |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_position(Vector2(100, 100))
Anima.Node($node).anima_position(Vector2(100, 100), 0.3) # duration - 0.3s
```

### anima_position3D

Animates the `x`, `y` and `z` position of the given element(s)

#### Syntax

```gdscript
anima_position3D(position: Vector3, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| position | Vector3 |         | The final 3D position                                                                           |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_position3D(Vector3(100, 100, 0))
```

### anima_position_x

Animates the global `x` position of the given element(s)

#### Syntax

```gdscript
anima_position_x(x: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| x        | float |         | The global final `x` position                                                                   |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_position_x(100)
```

### anima_position_y

Animates the global `y` position of the given element(s)

#### Syntax

```gdscript
anima_position_y(y: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| y        | float |         | The global final `y` position                                                                   |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_position_y(100)
```

### anima_position_z

Animates the global `z` position of the given element(s)

#### Syntax

```gdscript
anima_position_z(z: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| z        | float |         | The global final `z` position                                                                   |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_position_z(-1)
```

### anima_relative_position

Animates the relative `x` and `y` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position(position: Vector2, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| position | Vector2 |         | The relative 2D position                                                                        |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_relative_position(Vector2(100, 100))
```

### anima_relative_position3D

Animates the relative `x`, `y` and `z` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position3D(position: Vector3, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| position | Vector3 |         | The relative 3D position                                                                        |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_relative_position3D(Vector3(100, 100, 0))
```

### anima_relative_position_x

Animates the relative `x` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position_x(x: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| x        | float |         | The relative `x` position                                                                       |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_relative_position_x(100)
```

### anima_relative_position_y

Animates the relative `y` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position_y(y: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| y        | float |         | The relative `y` position                                                                       |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_relative_position_y(100)
```

### anima_relative_position_z

Animates the relative `z` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position_z(z: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| z        | float |         | The relative `z` position                                                                       |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_relative_position_z(-1)
```

### anima_rotate

Animates the 2D rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate(rotate: Vector2, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| rotate   | Vector2 |         | The final rotate value                                                                          |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_rotate(Vector2.ZERO)
```

### anima_rotate3D

Animates the 3D rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate3D(rotate: Vector3, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| rotate   | Vector3 |         | The final rotate value                                                                          |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_rotate3D(Vector3(10, 0, -0.5))
```

### anima_rotate_x

Animates the `x` rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate_x(rotate_x: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| rotate_x | float |         | The final rotate `x` value                                                                      |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_rotate_x(0.8)
```

### anima_rotate_y

Animates the `y` rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate_y(rotate_y: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| rotate_y | float |         | The final rotate `y` value                                                                      |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_rotate_y(0.8)
```

### anima_rotate_z

Animates the `z` rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate_z(rotate_z: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| rotate_z | float |         | The final rotate `z` value                                                                      |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_rotate_z(0.8)
```

### anima_scale

Animates the 2D scale property of the given element(s)

#### Syntax

```gdscript
anima_scale(scale: Vector2, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| scale    | Vector2 |         | The final scale value                                                                           |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_scale(Vector2.ZERO)
```

### anima_scale3D

Animates the 3D scale property of the given element(s)

#### Syntax

```gdscript
anima_scale3D(scale: Vector3, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| scale    | Vector3 |         | The final scale value                                                                           |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_scale3D(Vector3(10, 0, -0.5))
```

### anima_scale_x

Animates the `x` scale property of the given element(s)

#### Syntax

```gdscript
anima_scale_x(scale_x: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| scale_x  | float |         | The final scale `x` value                                                                       |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_scale_x(0.8)
```

### anima_scale_y

Animates the `y` scale property of the given element(s)

#### Syntax

```gdscript
anima_scale_y(scale_y: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| scale_y  | float |         | The final scale `y` value                                                                       |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_scale_y(0.8)
```

### anima_scale_z

Animates the `z` scale property of the given element(s)

#### Syntax

```gdscript
anima_scale_z(scale_z: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| scale_z  | float |         | The final scale `z` value                                                                       |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_scale_z(0.8)
```

### anima_size

Animates the 2D size property of the given element(s)

#### Syntax

```gdscript
anima_size(size: Vector2, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| size     | Vector2 |         | The final size value                                                                            |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_size(Vector2.ZERO)
```

### anima_size3D

Animates the 3D size property of the given element(s)

#### Syntax

```gdscript
anima_size3D(size: Vector3, duration: float)
```

| Param    | Type    | Default | Description                                                                                     |
| -------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| size     | Vector3 |         | The final size value                                                                            |
| duration | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_size3D(Vector3(10, 0, -0.5))
```

### anima_size_x

Animates the `x` size property of the given element(s)

#### Syntax

```gdscript
anima_size_x(size_x: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| size_x   | float |         | The final size `x` value                                                                        |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_size_x(0.8)
```

### anima_size_y

Animates the `y` size property of the given element(s)

#### Syntax

```gdscript
anima_size_y(size_y: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| size_y   | float |         | The final size `y` value                                                                        |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_size_y(0.8)
```

### anima_size_z

Animates the `z` size property of the given element(s)

#### Syntax

```gdscript
anima_size_z(size_z: float, duration: float)
```

| Param    | Type  | Default | Description                                                                                     |
| -------- | ----- | ------- | ----------------------------------------------------------------------------------------------- |
| size_z   | float |         | The final size `z` value                                                                        |
| duration | float | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_size_z(0.8)
```

### anima_shader_param

Animates the given shader parameter

#### Syntax

```gdscript
anima_shader_param(parameter_name: String, to_value: Variant, duration: float)
```

| Param          | Type    | Default | Description                                                                                     |
| -------------- | ------- | ------- | ----------------------------------------------------------------------------------------------- |
| parameter_name | String  |         | The shared parameter to animate                                                                 |
| to_value       | Variant |         | The final value of the shader parameter                                                         |
| duration       | float   | null    | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

#### Example

```gdscript
Anima.Node($node).anima_size_z(0.8)
```


