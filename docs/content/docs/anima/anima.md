---
weight: 60
title: "Anima"
description: "The entry point you call to play any motion."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# Anima

`Anima` is the one thing you call to actually run a motion you've built — a single [`AnimaPropertyMotion`](./anima-property-motion.md), or a whole tree of [`AnimaSequence`](./anima-sequence.md)s and [`AnimaParallel`](./anima-parallel.md)s.

```gdscript
class_name Anima
extends RefCounted
```

## Overview

You never create an instance of `Anima` yourself — every one of its methods is called directly on the class itself (this is called a **static method**: a function you call on the type, like `Anima.play(...)`, rather than on an object you created with `.new()`).

There is nothing to set up before calling `Anima.play()` — no autoload to add, no node to place in your scene. The first call creates everything Anima needs internally, automatically.

## Quick example

```gdscript
var motion := AnimaPropertyMotion.new()
motion.target_property = NodePath("modulate:a")
motion.to_value = 0.0
motion.duration = 0.5

var playback := Anima.play(motion, $Sprite2D)
await playback.finished
print("Done!")
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`play()`](#play) | [`AnimaPlayback`](./anima-playback.md) | Starts playing a motion against a target node. |

---

### `play()`

```gdscript
static func play(motion: AnimaMotion, target: Node) -> AnimaPlayback
```

Starts running `motion` against `target` immediately and returns an [`AnimaPlayback`](./anima-playback.md) you can use to pause, resume, cancel, or wait for it to finish.

#### Parameters

| Parameter | Type | Description |
|---|---|---|
| `motion` | [`AnimaMotion`](./anima-motion.md) | The motion to play — any subtype, such as [`AnimaPropertyMotion`](./anima-property-motion.md), [`AnimaSequence`](./anima-sequence.md), or [`AnimaParallel`](./anima-parallel.md). |
| `target` | `Node` | The node the motion animates. |

#### Behaviour

- Playback starts immediately — there is no delay before the first frame of the motion runs.
- Calling `Anima.play()` again on the same node while a motion is still playing starts a second, independent playback. The first one keeps running unaffected; there is no conflict detection between them yet if they happen to target the same property.

## Related API

- [`AnimaPlayback`](./anima-playback.md)
- [`AnimaRuntime`](./anima-runtime.md)
- [`AnimaMotion`](./anima-motion.md)

## Source

- [`anima.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima.gd)
