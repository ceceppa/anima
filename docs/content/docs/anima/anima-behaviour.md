---
weight: 190
title: "AnimaBehaviour"
description: "Per-node motion configuration, attached to an ordinary node without subclassing."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaBehaviour

`AnimaBehaviour` is a configuration resource you attach to any ordinary node — no node subclass required — to describe how that node should animate.

```gdscript
class_name AnimaBehaviour
extends Resource
```

## Overview

Some projects want to declare a node's motion configuration once and keep it with the node, rather than writing playback code every time that node needs to enter or exit. `AnimaBehaviour` is that configuration: it holds a `motion_in`, a `motion_out`, timing defaults, and a few related settings, and attaches to any `Node` via [`Anima.attach_behaviour()`](./anima.md#attach_behaviour) — the node's class and script are left completely unchanged.

This phase ships the resource, its fields, and attach/retrieve storage (via node metadata, so it survives scene save/load). Nothing reads these fields to actually play a motion yet — that's separate, later work. Right now, attaching an `AnimaBehaviour` records configuration; it doesn't cause anything to animate on its own.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaBehaviour
```

## Quick example

```gdscript
var behaviour := AnimaBehaviour.new()
behaviour.motion_id = "card_intro"
behaviour.default_duration = 0.4

Anima.attach_behaviour($Card, behaviour)

var stored := Anima.get_behaviour($Card)
print(stored.motion_id) # "card_intro"
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Card` refers to a node already in your scene.

## Properties

| Property | Type | Default | Description |
|---|---|---:|---|
| [`motion_id`](#motion_id) | `String` | `""` | Optional identity for this behaviour, independent of the node's own name. |
| [`motion_in`](#motion_in) | [`AnimaMotion`](./anima-motion.md) | `null` | Motion to play when the node enters. *(Reserved — see [Limitations](#limitations).)* |
| [`motion_out`](#motion_out) | [`AnimaMotion`](./anima-motion.md) | `null` | Motion to play when the node exits. *(Reserved.)* |
| [`play_in_on_ready`](#play_in_on_ready) | `bool` | `false` | Whether `motion_in` should auto-play on the node's `_ready()`. *(Reserved.)* |
| [`hide_after_out`](#hide_after_out) | `bool` | `false` | Whether the node should hide after `motion_out` finishes. *(Reserved.)* |
| [`default_duration`](#default_duration) | `float` | `0.3` | Default duration for motions authored against this behaviour. *(Reserved.)* |
| [`default_ease`](#default_ease) | [`AnimaEase`](./anima-ease.md) | `null` | Default ease for motions authored against this behaviour. *(Reserved.)* |
| [`layout_transition_enabled`](#layout_transition_enabled) | `bool` | `false` | Whether layout-transition behaviour is enabled for this node. *(Reserved.)* |
| [`state_bindings`](#state_bindings) | `Dictionary` | `{}` | Reserved slot for per-state motion bindings. *(Reserved.)* |
| [`reduced_motion`](#reduced_motion) | `ReducedMotion` | `SYSTEM` | Reduced-motion preference for this behaviour. |

---

### `motion_id`

```gdscript
@export var motion_id: String = ""
```

Optional identity for this behaviour, independent of the node's own name. Useful when you need to distinguish behaviours in code without relying on the node tree.

---

### `motion_in`

```gdscript
@export var motion_in: AnimaMotion = null
```

The motion to play when the node enters, once something consumes it. Reserved — nothing plays this automatically yet.

---

### `motion_out`

```gdscript
@export var motion_out: AnimaMotion = null
```

The motion to play when the node exits, once something consumes it. Reserved — nothing plays this automatically yet.

---

### `play_in_on_ready`

```gdscript
@export var play_in_on_ready: bool = false
```

Whether `motion_in` should auto-play on the node's `_ready()`, once something consumes it. Reserved.

---

### `hide_after_out`

```gdscript
@export var hide_after_out: bool = false
```

Whether the node should hide after `motion_out` finishes, once something consumes it. Reserved.

---

### `default_duration`

```gdscript
@export var default_duration: float = 0.3
```

Default duration for motions authored against this behaviour, once something consumes it. Reserved.

---

### `default_ease`

```gdscript
@export var default_ease: AnimaEase = null
```

Default ease for motions authored against this behaviour, once something consumes it. `null` falls back to linear. Reserved.

---

### `layout_transition_enabled`

```gdscript
@export var layout_transition_enabled: bool = false
```

Whether layout-transition behaviour is enabled for this node, once that feature exists. Reserved.

---

### `state_bindings`

```gdscript
@export var state_bindings: Dictionary = {}
```

Reserved slot for per-state (Idle/Hover/Pressed/and similar) motion bindings. No runtime consumer reads this yet — it exists so scenes authored now don't need migrating once that feature ships.

---

### `reduced_motion`

```gdscript
@export var reduced_motion: ReducedMotion = ReducedMotion.SYSTEM
```

How reduced-motion preference is resolved for this behaviour. See [Enumerations](#enumerations) below.

## Enumerations

### `ReducedMotion`

```gdscript
enum ReducedMotion {
    SYSTEM,
    ENABLED,
    DISABLED,
}
```

| Value | Description |
|---|---|
| `SYSTEM` | Follows the system/project-wide reduced-motion setting. |
| `ENABLED` | Reduced motion is always on for this behaviour, regardless of the system setting. |
| `DISABLED` | Reduced motion is always off for this behaviour, regardless of the system setting. |

## Limitations

- Attaching an `AnimaBehaviour` only stores configuration — nothing reads `motion_in`, `motion_out`, `play_in_on_ready`, `hide_after_out`, `default_duration`, `default_ease`, `layout_transition_enabled`, or `state_bindings` to actually drive playback yet. Only `motion_id` and `reduced_motion` are meaningfully used today.
- There is no Inspector UI for editing an attached `AnimaBehaviour` yet — set its fields from code.

## Related API

- [`Anima`](./anima.md)
- [`AnimaNodeProxy`](./anima-node-proxy.md)
- [`AnimaMotion`](./anima-motion.md)

## Source

- [`anima_behaviour.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_behaviour.gd)
