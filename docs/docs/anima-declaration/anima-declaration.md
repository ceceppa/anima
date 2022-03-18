---
sidebar_position: 1
---

# AnimaDeclaration

AnimaDeclaration is used to tell Anima what kind of animation to peform for the given [Anima.Node](/docs/anima-declaration/anima-node), [Anima.Group](/docs/anima-declaration/anima-group) or [Anima.Grid](/docs/anima-declaration/anima-grid).

Each of those classes exposes the following methods to specify how to animate the selected type.

_NOTE_: For commodity, all the methods start with the `anima_` prefix. This allows us to filter out all the Godot default class methods:

![AnimaDeclaration autocomplete](/img/anima_autocomplete.png)

## anima_animation

Animates the Node/Group/Grid using the given animation name.

####  Syntax

```gdscript
anima_animation(animation: String, duration: float, ignore_initial_values: bool )
```

| Param | Type | Default | Description |
|---|---|---|---|
| animation | string | | The animation name |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |
| ignore_initial_values | bool | false | If true does not apply the `initial_values` defined inside the animation |

####  Example

```gdscript
Anim.Node($node).anima_animation("zoomIn")
Anim.Group($node).anima_animation("tada")
Anim.Grid($node).anima_animation("fadeIn")
```

## anima_animation_frames

Animates the Node/Group/Grid using a CSS-Style inline animation.

####  Syntax

```gdscript
anima_animation_frames(animation: Dictionary, duration: float, ignore_initial_values: bool)
```

| Param | Type | Default | Description |
|---|---|---|---|
| animation | string | | The animation frames. See[Create a custom animation](docs/extend-anima/custom-animation) for more information about the syntax |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |
| ignore_initial_values | bool | false | If true does not apply the `initial_values` defined inside the animation |

####  Example:

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

## anima_property

Animates the given property

####  Syntax

```gdscript
anima_property(property: String, final_value, duration)
```

| Param | Type | Default | Description |
|---|---|---|---|
| property | string | | The property to animate |
| final_value | Variant | null | (Optional) The final value. If null, the current property value is used as final value |
| duration | float | null | The animation duration (seconds). If null, the [default duration](/docs/anima-node/) is used |

The `property` parameter can be any animatable property, for example:

- size
- position

We can also specify the subkey of the Vector2, Vector3 or Rect2 we want to animate, for example:

- size:x
- position:y
- size:width

Anima also recognised these built-in property names:

| property | description |
|---|---|
| x | This is equivalent to `position:x` or `rect_position:x` |
| y | This is equivalent to `position:y` or `rect_position:x` |
| z | This is equivalent to `position:z` or `rect_position:x` |
| width | This is equivalent to `size:x` or `rect_size:x` |
| height | This is equivalent to `size:y` or `rect_size:y` |
| shared_param | This will call `set_shader_param` |

##### position vs rect_position

Although Godot prefixes some of the **Controls** properties with `rect_`, we don't need to worry about that; Anima will figure out the correct property name for us.

For example:

```gdscript
Anima.Node($Control).property("position:x", 100 ) # Animates rect_position.x
Anima.Node($Node2D).property("position:x", 100 )  # Animates position.x
```


####  Example

```gdscript
Anima.Node($node).anima_property("size:x").anima_from(100)
Anima.Node($node).anima_property("x", 200)
```

## animate_fade_in

Fades in the given element(s)

####  Syntax

```gdscript
anima_fade_in(duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).fade_in(0.4)
```

## anima_fade_out

Fades out the given element(s)

####  Syntax

```gdscript
anima_fade_out(duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).fade_out(0.4)
```

## anima_position

Animates the `x` and `y` position of the given element(s)

####  Syntax

```gdscript
anima_position(position: Vector2, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| position | Vector2 |  | The final 2D position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_position(Vector2(100, 100))
Anima.Node($node).anima_position(Vector2(100, 100), 0.3) # duration - 0.3s
```

## anima_position3D

Animates the `x`, `y` and `z` position of the given element(s)

####  Syntax

```gdscript
anima_position3D(position: Vector3, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| position | Vector3 |  | The final 3D position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_position3D(Vector3(100, 100, 0))
```

## anima_position_x

Animates the global `x` position of the given element(s)

####  Syntax

```gdscript
anima_position_x(x: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| x | float |  | The global final `x` position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_position_x(100)
```

## anima_position_y

Animates the global `y` position of the given element(s)

####  Syntax

```gdscript
anima_position_y(y: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| y | float |  | The global final `y` position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_position_y(100)
```

## anima_position_z

Animates the global `z` position of the given element(s)

####  Syntax

```gdscript
anima_position_z(z: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| z | float |  | The global final `z` position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_position_z(-1)
```

## anima_relative_position

Animates the relative `x` and `y` position of the given element(s)

####  Syntax

```gdscript
anima_relative_position(position: Vector2, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| position | Vector2 |  | The relative 2D position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_relative_position(Vector2(100, 100))
```

## anima_relative_position3D

Animates the relative `x`, `y` and `z` position of the given element(s)

####  Syntax

```gdscript
anima_relative_position3D(position: Vector3, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| position | Vector3 |  | The relative 3D position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_relative_position3D(Vector3(100, 100, 0))
```

## anima_relative_position_x

Animates the relative `x` position of the given element(s)

####  Syntax

```gdscript
anima_relative_position_x(x: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| x | float |  | The relative `x` position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_relative_position_x(100)
```

## anima_relative_position_y

Animates the relative `y` position of the given element(s)

####  Syntax

```gdscript
anima_relative_position_y(y: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| y | float |  | The relative `y` position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_relative_position_y(100)
```

## anima_relative_position_z

Animates the relative `z` position of the given element(s)

####  Syntax

```gdscript
anima_relative_position_z(z: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| z | float |  | The relative `z` position |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_relative_position_z(-1)
```

## anima_scale

Animates the 2D scale property of the given element(s)

####  Syntax

```gdscript
anima_scale(scale: Vector2, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| scale | Vector2 |  | The final scale value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_scale(Vector2.ZERO)
```

## anima_scale3D

Animates the 3D scale property of the given element(s)

####  Syntax

```gdscript
anima_scale3D(scale: Vector3, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| scale | Vector3 |  | The final scale value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_scale3D(Vector3(10, 0, -0.5))
```

## anima_scale_x

Animates the `x` scale property of the given element(s)

####  Syntax

```gdscript
anima_scale_x(scale_x: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| scale_x | float |  | The final scale `x` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_scale_x(0.8)
```

## anima_scale_y

Animates the `y` scale property of the given element(s)

####  Syntax

```gdscript
anima_scale_y(scale_y: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| scale_y | float |  | The final scale `y` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_scale_y(0.8)
```

## anima_scale_z

Animates the `z` scale property of the given element(s)

####  Syntax

```gdscript
anima_scale_z(scale_z: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| scale_z | float |  | The final scale `z` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_scale_z(0.8)
```


## anima_size

Animates the 2D size property of the given element(s)

####  Syntax

```gdscript
anima_size(size: Vector2, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| size | Vector2 |  | The final size value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_size(Vector2.ZERO)
```

## anima_size3D

Animates the 3D size property of the given element(s)

####  Syntax

```gdscript
anima_size3D(size: Vector3, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| size | Vector3 |  | The final size value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_size3D(Vector3(10, 0, -0.5))
```

## anima_size_x

Animates the `x` size property of the given element(s)

####  Syntax

```gdscript
anima_size_x(size_x: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| size_x | float |  | The final size `x` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_size_x(0.8)
```

## anima_size_y

Animates the `y` size property of the given element(s)

####  Syntax

```gdscript
anima_size_y(size_y: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| size_y | float |  | The final size `y` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_size_y(0.8)
```

## anima_size_z

Animates the `z` size property of the given element(s)

####  Syntax

```gdscript
anima_size_z(size_z: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| size_z | float |  | The final size `z` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_size_z(0.8)
```

## anima_rotate

Animates the 2D rotate property of the given element(s)

####  Syntax

```gdscript
anima_rotate(rotate: Vector2, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| rotate | Vector2 |  | The final rotate value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_rotate(Vector2.ZERO)
```

## anima_rotate3D

Animates the 3D rotate property of the given element(s)

####  Syntax

```gdscript
anima_rotate3D(rotate: Vector3, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| rotate | Vector3 |  | The final rotate value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_rotate3D(Vector3(10, 0, -0.5))
```

## anima_rotate_x

Animates the `x` rotate property of the given element(s)

####  Syntax

```gdscript
anima_rotate_x(rotate_x: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| rotate_x | float |  | The final rotate `x` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_rotate_x(0.8)
```

## anima_rotate_y

Animates the `y` rotate property of the given element(s)

####  Syntax

```gdscript
anima_rotate_y(rotate_y: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| rotate_y | float |  | The final rotate `y` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_rotate_y(0.8)
```

## anima_rotate_z

Animates the `z` rotate property of the given element(s)

####  Syntax

```gdscript
anima_rotate_z(rotate_z: float, duration: float)
```

| Param | Type | Default | Description |
|---|---|---|---|
| rotate_z | float |  | The final rotate `z` value |
| duration | float | null | The animation duration (in seconds). If null, the [default duration](/docs/anima-node/) is used |

####  Example

```gdscript
Anima.Node($node).anima_rotate_z(0.8)
```


## anima_as_relative

Tells anima that the final value is a relative one

####  Syntax

```gdscript
anima_as_relative()
```

####  Example

```gdscript
Anima.Node($node).anima_scale_x(0.8).anima_as_relative()
```
