---
title: "ClassName"
description: "Short description of what ClassName represents or controls."
godot_version: "4.x"
anima_version: "2.x"
api_type: "class"
---

# ClassName

Briefly explain what this class represents and when a developer would use it.

```gdscript
class_name ClassName
extends ParentClass
```

## Overview

Describe the class’s responsibilities and important behaviour.

Keep this focused on:

- What the class controls.
- How it fits into Anima.
- Whether developers create it directly.
- Any important lifecycle or ownership rules.

## Inheritance

```text
GodotObject
└── ParentClass
    └── ClassName
```

## Quick example

Show the smallest complete example demonstrating the class’s primary purpose.

```gdscript
var instance := ClassName.new()

instance.configure(...)
instance.play()
```

> This example assumes Anima is installed and enabled in the current Godot project.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`duration`](#duration) | `float` | `0.3` | Duration of the animation in seconds. |
| [`delay`](#delay) | `float` | `0.0` | Time to wait before the animation starts. |
| [`enabled`](#enabled) | `bool` | `true` | Whether the behaviour is enabled. |

---

### `duration`

```gdscript
var duration: float = 0.3
```

Controls how long the animation takes to complete, measured in seconds.

#### Accepted values

Any value greater than or equal to `0.0`.

| Value | Behaviour |
|---:|---|
| `0.0` | Applies the final state immediately. |
| Greater than `0.0` | Animates over the specified duration. |

#### Example

```gdscript
animation.duration = 0.5
```

#### Notes

- The effective duration may change when the playback speed is modified.
- Reduced-motion settings may override this value.

---

### `delay`

```gdscript
var delay: float = 0.0
```

Controls how long Anima waits before starting the animation.

#### Accepted values

Any value greater than or equal to `0.0`.

#### Example

```gdscript
animation.delay = 0.2
```

---

### `enabled`

```gdscript
var enabled: bool = true
```

Determines whether this behaviour is active.

When set to `false`, explain exactly whether the animation is skipped, paused or immediately completed.

#### Example

```gdscript
animation.enabled = false
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`configure()`](#configure) | `ClassName` | Configures the instance. |
| [`play()`](#play) | `void` | Starts playback. |
| [`stop()`](#stop) | `void` | Stops playback. |
| [`is_playing()`](#is-playing) | `bool` | Returns whether playback is active. |

---

### `configure()`

```gdscript
func configure(
    target: Node,
    duration: float = 0.3,
    delay: float = 0.0
) -> ClassName
```

Configures the animation for a target node.

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---:|---|
| `target` | `Node` | Required | Node affected by the animation. |
| `duration` | `float` | `0.3` | Animation duration in seconds. |
| `delay` | `float` | `0.0` | Delay before playback begins. |

#### Returns

Returns the current `ClassName` instance, allowing additional method calls to be chained.

#### Example

```gdscript
var animation := ClassName.new()

animation.configure(
    $Panel,
    0.5,
    0.1
)
```

#### Chained example

```gdscript
ClassName.new() \
    .configure($Panel, 0.5) \
    .play()
```

#### Behaviour

- Calling this method again replaces the previous configuration.
- The target must remain valid for the duration of the animation.
- This method configures the animation but does not start it.

#### Errors

| Condition | Result |
|---|---|
| `target` is `null` | Describe whether Anima reports an error or ignores the call. |
| `duration` is negative | Describe whether it is rejected, clamped or treated as `0.0`. |
| Target is freed during playback | Describe how playback finishes or is cancelled. |

---

### `play()`

```gdscript
func play() -> void
```

Starts the configured animation.

#### Example

```gdscript
animation.play()
```

#### Behaviour

Explain:

- What happens when playback starts.
- What happens if the animation is already playing.
- Whether an initial delay is respected.
- Whether this method can be called more than once.

#### See also

- [`stop()`](#stop)
- [`is_playing()`](#is-playing)

---

### `stop()`

```gdscript
func stop(reset: bool = false) -> void
```

Stops the current animation.

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---:|---|
| `reset` | `bool` | `false` | Whether the target returns to its initial state. |

#### Example

```gdscript
animation.stop()
```

#### Reset the target

```gdscript
animation.stop(true)
```

#### Behaviour

Describe whether:

- Completion signals are emitted.
- The target keeps its current values.
- Playback can resume after stopping.
- Child or nested animations are also stopped.

---

### `is_playing()`

```gdscript
func is_playing() -> bool
```

Returns whether the animation is currently playing.

#### Returns

- `true` while playback is active.
- `false` when the animation is idle, stopped or complete.

#### Example

```gdscript
if animation.is_playing():
    print("The animation is running.")
```

## Signals

| Signal | Description |
|---|---|
| [`started`](#started) | Emitted when playback starts. |
| [`completed`](#completed) | Emitted when playback finishes. |
| [`interrupted`](#interrupted) | Emitted when playback is interrupted. |

---

### `started`

```gdscript
signal started
```

Emitted when playback begins.

Clarify whether this occurs before or after any configured delay.

#### Example

```gdscript
animation.started.connect(_on_animation_started)


func _on_animation_started() -> void:
    print("Animation started")
```

---

### `completed`

```gdscript
signal completed
```

Emitted after the animation reaches its final state.

Clarify whether this signal is emitted when playback is stopped or interrupted.

#### Example

```gdscript
animation.completed.connect(_on_animation_completed)


func _on_animation_completed() -> void:
    print("Animation completed")
```

---

### `interrupted`

```gdscript
signal interrupted(reason: StringName)
```

Emitted when the animation ends before reaching normal completion.

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `reason` | `StringName` | Reason playback was interrupted. |

## Enumerations

### `PlaybackState`

```gdscript
enum PlaybackState {
    IDLE,
    DELAYED,
    PLAYING,
    PAUSED,
    COMPLETED,
    CANCELLED,
}
```

| Value | Description |
|---|---|
| `IDLE` | Playback has not started. |
| `DELAYED` | Playback is waiting for its configured delay. |
| `PLAYING` | The animation is running. |
| `PAUSED` | Playback is temporarily paused. |
| `COMPLETED` | The animation reached its final state. |
| `CANCELLED` | Playback ended before completion. |

## Constants

| Constant | Type | Value | Description |
|---|---|---:|---|
| `DEFAULT_DURATION` | `float` | `0.3` | Default animation duration in seconds. |
| `NO_DELAY` | `float` | `0.0` | Indicates that playback should start immediately. |

## Complete example

Show how the class is normally used in context. This should be complete and copyable, but it should not become a tutorial.

```gdscript
extends Control

@onready var panel: Panel = $Panel

var animation: ClassName


func _ready() -> void:
    animation = ClassName.new()

    animation.started.connect(_on_animation_started)
    animation.completed.connect(_on_animation_completed)

    animation.configure(
        panel,
        0.5,
        0.1
    )


func _on_start_button_pressed() -> void:
    animation.play()


func _on_animation_started() -> void:
    print("Animation started")


func _on_animation_completed() -> void:
    print("Animation completed")
```

## Interruption behaviour

Document what happens when:

| Situation | Behaviour |
|---|---|
| `play()` is called during playback | Describe restart, ignore or interruption behaviour. |
| `stop()` is called | Describe the resulting target state. |
| The target leaves the scene tree | Describe whether playback pauses or ends. |
| The target is freed | Describe cancellation and cleanup behaviour. |
| Another animation controls the same property | Describe conflict-resolution behaviour. |

## Reduced motion

Explain how the API behaves when reduced motion is enabled.

Document whether Anima:

- Skips the animation.
- Shortens its duration.
- Applies the final state immediately.
- Replaces movement with a less disruptive effect.
- Still emits normal lifecycle signals.

## Determinism

If the API uses randomness, document:

- How to provide a seed.
- Whether the same seed produces the same result.
- Which values are affected by randomness.
- Whether randomness is evaluated when configured or when played.

```gdscript
animation.set_seed(12345)
```

## Performance notes

Include this section only when the API has meaningful performance implications.

For example:

- Avoid creating a new instance every frame.
- Reuse declarations when supported.
- Large staggered groups may increase update cost.
- Animating layout properties may trigger additional Godot layout calculations.

## Limitations

List known limitations precisely.

- Limitation and its practical effect.
- Unsupported node or property type.
- Behaviour that differs between Godot versions.
- Combination that is currently unsupported.

## Related API

- [`RelatedClass`](./related-class.md)
- [`AnotherClass`](./another-class.md)
- [`Anima`](./anima.md)

## Source

- [`class_name.gd`](https://github.com/example/anima/path/to/class_name.gd)