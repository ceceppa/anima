---
weight: 70
title: "AnimaPlayback"
description: "A handle to one running motion, returned by Anima.play()."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaPlayback

`AnimaPlayback` is what [`Anima.play()`](./anima.md) gives you back — a handle to that specific, currently-running motion, which you can pause, resume, cancel, or wait on.

```gdscript
class_name AnimaPlayback
extends RefCounted
```

## Overview

You never create an `AnimaPlayback` yourself — you always get one from [`Anima.play()`](./anima.md). Each call to `Anima.play()` returns its own independent `AnimaPlayback`, even if you call it twice with the same motion and target.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaPlayback
```

## Properties

| Property | Type | Description |
|---|---|---|
| [`motion`](#motion) | [`AnimaMotion`](./anima-motion.md) | The motion this playback is running. |
| [`target`](#target) | `Node` | The node this motion is animating. |
| [`state`](#state) | `State` | The playback's current state — see [Enumerations](#enumerations). |

---

### `motion`

```gdscript
var motion: AnimaMotion
```

The exact motion resource passed to [`Anima.play()`](./anima.md) when this playback was created.

---

### `target`

```gdscript
var target: Node
```

The node passed to [`Anima.play()`](./anima.md) when this playback was created.

---

### `state`

```gdscript
var state: State = State.PLAYING
```

The playback's current state. See the [`State`](#state) enum below for every possible value.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`pause()`](#pause) | `void` | Freezes the animated values in place. |
| [`resume()`](#resume) | `void` | Continues from wherever the motion paused. |
| [`cancel()`](#cancel) | `void` | Stops the motion and marks it as not successful. |

---

### `pause()`

```gdscript
func pause() -> void
```

Freezes the motion exactly where it is. The animated property (or properties) stop changing until [`resume()`](#resume) is called. Has no effect if the playback isn't currently `PLAYING`.

---

### `resume()`

```gdscript
func resume() -> void
```

Continues a paused motion from exactly where it left off — nothing resets or restarts. Has no effect if the playback isn't currently `PAUSED`.

---

### `cancel()`

```gdscript
func cancel() -> void
```

Stops the motion immediately. The animated property is left at whatever value it had reached — it does not jump to its final value. The [`finished`](#finished) signal fires with `success` set to `false`.

## Signals

| Signal | Description |
|---|---|
| [`finished`](#finished) | Emitted exactly once, whether the motion completes normally or is cancelled. |

---

### `finished`

```gdscript
signal finished(success: bool)
```

Fires exactly once per playback — either when the motion reaches its end naturally (`success` is `true`), or when [`cancel()`](#cancel) is called (`success` is `false`).

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `success` | `bool` | `true` if the motion completed normally, `false` if it was cancelled. |

#### Example

```gdscript
var playback := Anima.play(motion, $Sprite2D)
playback.finished.connect(_on_motion_finished)

func _on_motion_finished(success: bool) -> void:
    if success:
        print("Motion completed")
    else:
        print("Motion was cancelled")
```

## Enumerations

### `State`

```gdscript
enum State {
    PLAYING,
    PAUSED,
    CANCELLED,
    FINISHED,
}
```

| Value | Description |
|---|---|
| `PLAYING` | The motion is actively running. This is the state a playback starts in. |
| `PAUSED` | The motion is frozen in place after `pause()`. |
| `CANCELLED` | `cancel()` was called; the motion stopped before reaching its end. |
| `FINISHED` | The motion reached its end naturally. |

## Interruption behaviour

| Situation | Behaviour |
|---|---|
| `Anima.play()` is called again on the same node | A second, independent `AnimaPlayback` is created. The first one is unaffected. There is no automatic cancellation of the first playback yet. |
| Two playbacks animate the same property on the same node at the same time | Whichever one writes to the property last within a given frame "wins" that frame — there is no conflict detection yet. |

## Related API

- [`Anima`](./anima.md)
- [`AnimaRuntime`](./anima-runtime.md)

## Source

- [`anima_playback.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_playback.gd)
