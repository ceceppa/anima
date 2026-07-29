---
weight: 80
title: "AnimaRuntime"
description: "The internal manager that advances every active motion, frame by frame."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaRuntime

`AnimaRuntime` is the internal manager that keeps every currently-playing motion moving forward, one frame at a time. You never create or configure one directly.

```gdscript
class_name AnimaRuntime
extends Node
```

## Overview

The first time you call [`Anima.play()`](./anima.md) anywhere in your project, Anima automatically creates one `AnimaRuntime` and adds it to your scene tree behind the scenes. From then on, every playback is tracked and advanced by that same runtime — you don't need to add anything to `project.godot`, and there's nothing to place in your scene yourself.

A **[`Node`](https://docs.godotengine.org/en/stable/classes/class_node.html)** is Godot's basic building block for anything that needs to exist in the running scene and update every frame — `AnimaRuntime` is a `Node` specifically so it can hook into Godot's normal per-frame update cycle to advance every active motion.

## Inheritance

```text
Object
└── Node
    └── AnimaRuntime
```

## Properties

| Property | Type | Description |
|---|---|---|
| [`active_playbacks`](#active_playbacks) | `Array[AnimaPlayback]` | Every playback the runtime is currently advancing. |

---

### `active_playbacks`

```gdscript
var active_playbacks: Array[AnimaPlayback] = []
```

Every [`AnimaPlayback`](./anima-playback.md) currently being advanced, across your whole project. A playback is added here the moment [`Anima.play()`](./anima.md) creates it, and removed automatically once it finishes or is cancelled.

## Performance notes

- One `AnimaRuntime` advances every active motion in a single per-frame pass, rather than creating a separate scheduling object per animated property.

## Related API

- [`Anima`](./anima.md)
- [`AnimaPlayback`](./anima-playback.md)

## Source

- [`anima_runtime.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_runtime.gd)
