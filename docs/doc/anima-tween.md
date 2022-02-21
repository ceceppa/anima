# AnimaTween

This is the node where the magic happens. It extends the [Godot Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html) node and uses the data passed by AnimaNode to play the animations as we want.

## Methods

- [add_animation_data(data: Dictionary)](#add-animation-data)
- [add_frames](#add-frames)
- [add_relative_frames](#add-relative-frames)

## Reference

### add\_animation\_data

Adds the animation data to the list of animations to perform.

#### Syntax

```gdscript
add_animation_data(animation_data: Dictionary)
```

For reference check: [animation_data](doc/anima-node.html#animation-data)

### add_frames

Given an array of frames generates the animation data using absolute values.

#### Syntax

```gdscript
add_frames(data: Dictionary, property: String, frames: Array)
```

| Parameter | Type       | Description                                                              |
| --------- | ---------- | ------------------------------------------------------------------------ |
| data      | Dictionary | The animation_data passed to the callback. See []() for more information |
| property  | String     | The property to animate                                                  |
| frames    | Array      | The animation frames                                                     |

Each frame needs to specify the `percentage` value and any key of [animation_data](#/doc/anima-node.html#animation-data) but "animation".

#### Example

```gdscript
var frames = [
  { percentage = 0, from = 0 }
  { percentage = 20, to = 0.3 } # 20%
  { percentage = 100, to = 1 }
]
anima_tween.add_frames(data, "opacity", frames)
```

In this case, the animation will have three frames and create two distinct animations. Consider that the animation duration is 1 second:

1. animates opacity from 0 to 0.3 in about 0.2 seconds
2. animates opacity from 0.3 to 1 in about 0.8 seconds

### add\_relative\_frames

This works like the [add_frames](#add-frames) method. The only difference is that it will automatically add the `relative = true` property to each given frame's animation data.

#### Syntax

```gdscript
add_relative_frames(data: Dictionary, property: String, frames: Array)
```

| Parameter | Type       | Description                                                              |
| --------- | ---------- | ------------------------------------------------------------------------ |
| data      | Dictionary | The animation_data passed to the callback. See []() for more information |
| property  | String     | The property to animate                                                  |
| frames    | Array      | The animation frames                                                     |

Each frame needs to specify the `percentage` value and any key of [animation_data](#/doc/anima-node.html#animation-data) but "animation".

#### Example

```gdscript
var frames = [
  { percentage = 0, from = 0 }
  { percentage = 30, to = 10 } # 30%
  { percentage = 100, to = 100 }
]
anima_tween.add_relative_frames(data, "x", frames)
```

In this case, the animation will have three frames and create two distinct animations. Consider that the animation duration is 1 second:

1. animates the X value from the current value to +10 in about 0.3 seconds
2. animates opacity from the position reached in point 1 to +100 in about 0.7 seconds
