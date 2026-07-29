---
weight: 100
title: "AnimaPropertyMotionInstance"
description: "The internal runtime behaviour behind AnimaPropertyMotion."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaPropertyMotionInstance

`AnimaPropertyMotionInstance` is the internal class that actually animates a property, frame by frame, on behalf of an [`AnimaPropertyMotion`](./anima-property-motion.md). It is created automatically and is not something you construct directly.

```gdscript
class_name AnimaPropertyMotionInstance
extends AnimaMotionInstance
```

## Overview

When you play an [`AnimaPropertyMotion`](./anima-property-motion.md), Anima creates one of these behind the scenes to track the property's starting value and apply the eased, in-progress value every frame until the motion finishes.

## Inheritance

```text
Object
└── RefCounted
    └── AnimaMotionInstance
        └── AnimaPropertyMotionInstance
```

## Methods

| Method | Returns | Description |
|---|---|---|
| [`advance()`](#advance) | `bool` | Advances the property's value by one frame's worth of time. |

---

### `advance()`

```gdscript
func advance(target: Node, delta: float) -> bool
```

On the first call, reads the property's starting value from `target` (per [`AnimaPropertyMotion.from_value`](./anima-property-motion.md#from_value)). Every call afterwards advances the eased progress and writes the new value to `target`. Returns `true` once the motion's duration has elapsed.

## Related API

- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`AnimaMotionInstance`](./anima-motion-instance.md)

## Source

- [`anima_property_motion_instance.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_property_motion_instance.gd)
