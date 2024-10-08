{{ $show_distance := .Get "distance" }}
{{ if $show_distance }}
## Staggered Animation

Selecting the starting index is inside the range `]0, GROUP_LENGTH[` creates a staggering animation, where node starting delay depends by its absolute distance from that point. 


Let's consider the following group with 7 buttons:

![Control node with 7 children](/images/group-example.png)

And animate them from the middle using, for semplicity, a delay of 1 second between each node:

```gdscript
Anima.{{ .Get "class" }}($Control, 1, ANIMA.GROUP.FROM_CENTER) \
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

{{ end }}

## Methods

_NOTE_: For commodity, all the class methods start with the `anima_` prefix. This allows us to filter out all the Godot default class methods:

![AnimaDeclaration autocomplete](/img/anima_autocomplete.png)

## as_reusable

Tells Anima to keep the node in the scene after the animation completes.

#### Syntax

```gdscript
as_reusable()
```

## anima_animation

Animates the {{ .Get "class" }} using the given animation name.

#### Syntax

```gdscript
anima_animation(animation: String, duration: float)
```

{{ partial "custom/param" (dict "name" "animation" "type" "string" "default" "" "required" true "description" "The animation name") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anim.{{ .Get "class" }}({{ .Get "init" }}).anima_animation("zoomIn")
```

## anima_animation_frames

Animates the {{ .Get "class" }} using a CSS-Style inline animation.

_NOTE:_ For more info check the [Animation Keyframes tutorial](/tutorials/extras/animation-keyframes)

#### Syntax

```gdscript
anima_animation_frames(frames: Dictionary, duration: float)
```

{{ partial "custom/param" (dict "name" "frames" "type" "Dictionary" "default" "" "required" true "description" "The animation frames. See[Create a custom keyframes animation](/docs/tutorials/extras/animation-keyframes/) for more information about the syntax") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example:

```gdscript
Anim.{{ .Get "class" }}({{ .Get "init" }}).anima_animation_frames({
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

Animates the given property.

Compared to the other property specific fuctions, like `anima_position_x` this method allows us to specify a [dynamic value](/docs/docs/tutorial-extras/dynamic-value)

#### Syntax

```gdscript
anima_property(property: String, final_value: Variant, duration: float)
```

{{ partial "custom/param" (dict "name" "property" "type" "string" "default" "" "required" true) }}

The property to animate it can be any node property that can be accessed, even exported variables. For example:

- size
- position

We can also specify the subkey of the `Vector2`, `Vector3` or `Rect2` we want to animate, for example:

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

{{ partial "custom/param" (dict "name" "final_value" "type" "Variant" "required" true "description" "(Optional) The final value. If null, the current property value is used as final value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_property("size:x").anima_from(100)
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_property("x", 200)
```

##### position vs rect_position

Although Godot prefixes some of the **Controls** properties with `rect_`, we don't need to worry about that; Anima will figure out the correct property name.

For example:

```gdscript
Anima.{{ .Get "class" }}($Control).anima_property("position:x", 100 ) # Animates rect_position.x
Anima.{{ .Get "class" }}($Node2D).anima_property("position:x", 100 )  # Animates position.x
```

## anima_as_relative

Tells anima that the final value is a relative one

#### Syntax

```gdscript
anima_as_relative()
```

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_x(0.8).anima_as_relative()
```

## anima_delay

The delay to use before starting the animation.

#### Syntax

```gdscript
anima_delay(delay: float)
```

**NOTE:** You can also use negative values to anticipate a sequential/parallel animation

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_x(0.8).anima_delay(0.5)

# or
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_x(0.8).anima_delay(-0.5)
```

{{ if $show_distance }}
## anima_distance_formula

The formula to use to calculate the distance between the elements.

#### Syntax

```gdscript
.anima_distance_formula(formula: ANIMA.DISTANCE)
```

{{ partial "custom/param" (dict "name" "formula" "type" "ANIMA.DISTANCE" "default" "" "required" true "description" "The formula to use to calculate the distance between the elements") }}

**Formula**

```
enum DISTANCE {
	EUCLIDIAN,
	MANHATTAN,
	CHEBYSHEV,
	COLUMN,
	ROW,
	DIAGONAL,
}
```

To visualize the effects of different easing formulas, explore these resources:

- [2D Grid Demo](https://github.com/ceceppa/anima/tree/main/demos/2d)
- [Live Demo: Animate 2D Grid](https://ceceppa.me/anima-demo)

These demonstrations will provide a clear understanding of how easing points influence animation behavior.

#### Example

```gdscript
(
    Anima.{{ .Get "class" }}({{ .Get "init" }})
    .anima_distance_formula(ANIMA.DISTANCE.MANHATTAN)
    .anima_fade_in()
    .play()
)
```
{{ end }}

## anima_easing

The easing to use to animate the node.

_NOTE_: [List of available easings](/docs/anima/constants#easings)

#### Syntax

```gdscript
anima_easing(easing: int)
```

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_x(0.8).anima_easing(ANIMA.EASINGS.EASE_IN_OUT)
```

## anima_from

Set the initial value.

#### Syntax

```gdscript
anima_from(value: Variant)
```

{{ partial "custom/param" (dict "name" "value" "type" "Variant" "default" "" "required" true "description" "The initial value") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_property("x").anima_from(-100)
```

## anima_fade_in

Fades in the given element(s)

#### Syntax

```gdscript
anima_fade_in(duration: float)
```

{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).fade_in(0.4)
```

## anima_fade_out

Fades out the given element(s)

#### Syntax

```gdscript
anima_fade_out(duration: float)
```

{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).fade_out(0.4)
```

## anima_on_started

Callback to be triggered when the {{ .Get "class" }} animation starts.

#### Syntax

```gdscript
anima_on_started(callback: Funcref | Callable, on_started_value, on_backwards_completed_value = null)
```

{{ partial "custom/param" (dict "name" "callback" "type" "Callable" "required" true "description" "The callback to call when the animation is starts") }}
{{ partial "custom/param" (dict "name" "on_started_value" "type" "Variant" "required" true "description" "The parameter to pass at the callback when the animation is played forward") }}
{{ partial "custom/param" (dict "name" "on_backwards_completed_value" "type" "Variant" "default" "null" "description" "The parameter to pass at the callback when the animation is played backwards") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_on_started(funcref(self, "do_something"), true, false)

func do_something(is_forward) -> void:
    print(is_forward)
```

## anima_on_completed

Callback to be triggered when the {{ .Get "class" }} animation completes.

#### Syntax

```gdscript
anima_on_completed(on_completed: Callable, on_completed_value, on_backwards_started_value = null)
```

{{ partial "custom/param" (dict "name" "on_completed" "type" "Callable" "required" true "description" "The callback to call when the animation is completed") }}
{{partial "custom/param" (dict "name" "on_completed_value" "type" "Variant" "required" true "description" "The parameter to pass at the callback when the animation is played forward")}}
{{partial "custom/param" (dict "name" "on_backwards_started_value" "type" "Variant" "default" "null" "description" "The parameter to pass at the callback when the animation is played backwards")}}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_on_started(funcref(self, "do_something"), true, false)

func do_something(is_forward) -> void:
    print(is_forward)
```

## anima_pivot

The pivot point to use to animate the node.

_NOTE_: [List of available pivot points](/docs/anima/constants#pivot-points)

#### Syntax

```gdscript
anima_pivot(easing: int)
```

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_x(0.8).anima_pivot(ANIMA.PIVOT.CENTER)
```

## anima_position

Animates the `x` and `y` position of the given element(s)

#### Syntax

```gdscript
anima_position(position: Vector2, duration: float)
```

{{ partial "custom/param" (dict "name" "position" "type" "Vector2" "default" "" "required" true "description" "The final 2D position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_position(Vector2(100, 100))
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_position(Vector2(100, 100), 0.3) # duration - 0.3s
```

## anima_position3D

Animates the `x`, `y` and `z` position of the given element(s)

#### Syntax

```gdscript
anima_position3D(position: Vector3, duration: float)
```

{{ partial "custom/param" (dict "name" "position" "type" "Vector3" "default" "" "required" true "description" "The final 3D position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_position3D(Vector3(100, 100, 0))
```

## anima_position_x

Animates the global `x` position of the given element(s)

#### Syntax

```gdscript
anima_position_x(x: float, duration: float)
```

{{ partial "custom/param" (dict "name" "x" "type" "float" "default" "" "required" true "description" "The global final `x` position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_position_x(100)
```

## anima_position_y

Animates the global `y` position of the given element(s)

#### Syntax

```gdscript
anima_position_y(y: float, duration: float)
```

{{ partial "custom/param" (dict "name" "y" "type" "float" "default" "" "required" true "description" "The global final `y` position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_position_y(100)
```

## anima_position_z

Animates the global `z` position of the given element(s)

#### Syntax

```gdscript
anima_position_z(z: float, duration: float)
```

{{ partial "custom/param" (dict "name" "z" "type" "float" "default" "" "required" true "description" "The global final `z` position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_position_z(-1)
```

## anima_relative_position

Animates the relative `x` and `y` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position(position: Vector2, duration: float)
```

{{ partial "custom/param" (dict "name" "position" "type" "Vector2" "default" "" "required" true "description" "The relative 2D position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_relative_position(Vector2(100, 100))
```

## anima_relative_position3D

Animates the relative `x`, `y` and `z` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position3D(position: Vector3, duration: float)
```

{{ partial "custom/param" (dict "name" "position" "type" "Vector3" "default" "" "required" true "description" "The relative 3D position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_relative_position3D(Vector3(100, 100, 0))
```

## anima_relative_position_x

Animates the relative `x` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position_x(x: float, duration: float)
```

{{ partial "custom/param" (dict "name" "x" "type" "float" "default" "" "required" true "description" "The relative `x` position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_relative_position_x(100)
```

## anima_relative_position_y

Animates the relative `y` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position_y(y: float, duration: float)
```

{{ partial "custom/param" (dict "name" "y" "type" "float" "default" "" "required" true "description" "The relative `y` position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_relative_position_y(100)
```

## anima_relative_position_z

Animates the relative `z` position of the given element(s)

#### Syntax

```gdscript
anima_relative_position_z(z: float, duration: float)
```

{{ partial "custom/param" (dict "name" "z" "type" "float" "default" "" "required" true "description" "The relative `z` position") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_relative_position_z(-1)
```

## anima_rotate

Animates the 2D rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate(rotate: Vector2, duration: float)
```

{{ partial "custom/param" (dict "name" "rotate" "type" "Vector2" "default" "" "required" true "description" "The final rotate value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_rotate(Vector2.ZERO)
```

## anima_rotate3D

Animates the 3D rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate3D(rotate: Vector3, duration: float)
```

{{ partial "custom/param" (dict "name" "rotate" "type" "Vector3" "default" "" "required" true "description" "The final rotate value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_rotate3D(Vector3(10, 0, -0.5))
```

## anima_rotate_x

Animates the `x` rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate_x(rotate_x: float, duration: float)
```

{{ partial "custom/param" (dict "name" "rotate_x" "type" "float" "default" "" "required" true "description" "The final rotate `x` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_rotate_x(0.8)
```

## anima_rotate_y

Animates the `y` rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate_y(rotate_y: float, duration: float)
```

{{ partial "custom/param" (dict "name" "rotate_y" "type" "float" "default" "" "required" true "description" "The final rotate `y` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_rotate_y(0.8)
```

## anima_rotate_z

Animates the `z` rotate property of the given element(s)

#### Syntax

```gdscript
anima_rotate_z(rotate_z: float, duration: float)
```

{{ partial "custom/param" (dict "name" "rotate_z" "type" "float" "default" "" "required" true "description" "The final rotate `z` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_rotate_z(0.8)
```

## anima_scale

Animates the 2D scale property of the given element(s)

#### Syntax

```gdscript
anima_scale(scale: Vector2, duration: float)
```

{{ partial "custom/param" (dict "name" "scale" "type" "Vector2" "default" "" "required" true "description" "The final scale value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale(Vector2.ZERO)
```

## anima_scale3D

Animates the 3D scale property of the given element(s)

#### Syntax

```gdscript
anima_scale3D(scale: Vector3, duration: float)
```

{{ partial "custom/param" (dict "name" "scale" "type" "Vector3" "default" "" "required" true "description" "The final scale value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale3D(Vector3(10, 0, -0.5))
```

## anima_scale_x

Animates the `x` scale property of the given element(s)

#### Syntax

```gdscript
anima_scale_x(scale_x: float, duration: float)
```

{{ partial "custom/param" (dict "name" "scale_x" "type" "float" "default" "" "required" true "description" "The final scale `x` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_x(0.8)
```

## anima_scale_y

Animates the `y` scale property of the given element(s)

#### Syntax

```gdscript
anima_scale_y(scale_y: float, duration: float)
```

{{ partial "custom/param" (dict "name" "scale_y" "type" "float" "default" "" "required" true "description" "The final scale `y` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_y(0.8)
```

## anima_scale_z

Animates the `z` scale property of the given element(s)

#### Syntax

```gdscript
anima_scale_z(scale_z: float, duration: float)
```

{{ partial "custom/param" (dict "name" "scale_z" "type" "float" "default" "" "required" true "description" "The final scale `z` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_scale_z(0.8)
```

## anima_size

Animates the 2D size property of the given element(s)

#### Syntax

```gdscript
anima_size(size: Vector2, duration: float)
```

{{ partial "custom/param" (dict "name" "size" "type" "Vector2" "default" "" "required" true "description" "The final size value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_size(Vector2.ZERO)
```

## anima_size3D

Animates the 3D size property of the given element(s)

#### Syntax

```gdscript
anima_size3D(size: Vector3, duration: float)
```

{{ partial "custom/param" (dict "name" "size" "type" "Vector3" "default" "" "required" true "description" "The final size value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_size3D(Vector3(10, 0, -0.5))
```

## anima_size_x

Animates the `x` size property of the given element(s)

#### Syntax

```gdscript
anima_size_x(size_x: float, duration: float)
```

{{ partial "custom/param" (dict "name" "size_x" "type" "float" "default" "" "required" true "description" "The final size `x` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_size_x(0.8)
```

## anima_size_y

Animates the `y` size property of the given element(s)

#### Syntax

```gdscript
anima_size_y(size_y: float, duration: float)
```

{{ partial "custom/param" (dict "name" "size_y" "type" "float" "default" "" "required" true "description" "The final size `y` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_size_y(0.8)
```

## anima_size_z

Animates the `z` size property of the given element(s)

#### Syntax

```gdscript
anima_size_z(size_z: float, duration: float)
```

{{ partial "custom/param" (dict "name" "size_z" "type" "float" "default" "" "required" true "description" "The final size `z` value") }}
{{ partial "custom/param" (dict "name" "duration" "type" "float" "default" "null" "description" "The animation duration (in seconds). If null, the {{% default-duration %}} is used") }}

#### Example

```gdscript
Anima.{{ .Get "class" }}({{ .Get "init" }}).anima_size_z(0.8)
```

## Chaining

Anima uses the `anima_with` and `anima_then` methods to chain multiple animations.

## anima_with

Executes the next animation in parallel with the current one.

#### Syntax

```gdscript
.anima_with(new_class: AnimaDeclaration, delay = 0)
```

{{ partial "custom/param" (dict "name" "new_class" "type" "AnimaDeclaration" "default" "" "required" true "description" "The new AnimaDeclaration class to chain with the current one") }}
{{ partial "custom/param" (dict "name" "delay" "type" "float" "default" "0" "description" "The delay to apply before starting the new animation. If negative, it anticipates the animation") }}

#### Example

```gdscript
(
    Anima.{{ .Get "class" }}({{ .Get "init" }})
    .anima_scale_x(0.8)
    .anima_with()
    .anima_fade_in()
    .play()
)
```

This will animate the node scaling it while fading it in.


```gdscript
(
    Anima.{{ .Get "class" }}({{ .Get "init" }})
    .anima_scale_x(0.8)
    .anima_with(Anima.{{ .Get "class" }}($another_node))
    .anima_fade_in()
    .play()
)
```

This will animate the node scaling it and fade in `$another_node` at the same time.

## anima_then

Executes the next animation after the current one has completed.

#### Syntax

```gdscript
.anima_then(new_class: AnimaDeclaration, delay = 0)
```

{{ partial "custom/param" (dict "name" "new_class" "type" "AnimaDeclaration" "default" "" "required" true "description" "The new AnimaDeclaration class to chain with the current one") }}
{{ partial "custom/param" (dict "name" "delay" "type" "float" "default" "0" "description" "The delay to apply before starting the new animation. If negative, it anticipates the animation") }}

#### Example

```gdscript
(
    Anima.{{ .Get "class" }}({{ .Get "init" }})
    .anima_fade_in()
    .anima_then()
    .anima_scale_x(0.8)
    .play()
)
```

This will animate the node fading it in and then scaling it

```gdscript
(
    Anima.{{ .Get "class" }}({{ .Get "init" }})
    .anima_scale_x(0.8)
    .anima_then(Anima.{{ .Get "class" }}($another_node))
    .anima_fade_in()
    .play()
)
```

This will animate the node scaling it and then fade in `$another_node`.
