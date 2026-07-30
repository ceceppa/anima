---
weight: 200
title: "AnimaNodeProxy"
description: "A lightweight enter()/exit()/to()/transition_to() proxy over an ordinary node."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaNodeProxy

`AnimaNodeProxy` is what [`Anima.of()`](./anima.md#of) returns — a small wrapper that lets you animate a node directly, without building an [`AnimaMotion`](./anima-motion.md) resource by hand first.

```gdscript
class_name AnimaNodeProxy
extends RefCounted
```

## Overview

Building a motion resource is the right tool when you're composing something — a sequence, a stagger, a conditional branch. But for the common case of "just animate this one property on this one node right now," it's more ceremony than the moment calls for. `Anima.of(node)` returns a proxy scoped to that node, so you can write:

```gdscript
Anima.of($Panel).to(NodePath("modulate:a"), 1.0)
```

instead of constructing an [`AnimaPropertyMotion`](./anima-property-motion.md) and calling [`Anima.play()`](./anima.md#play) yourself. Under the hood, every method here still goes through the same [`Motion`](./anima-motion-builder.md) factories and `Anima.play()` — there's no separate playback path, just a shorter one.

You don't construct `AnimaNodeProxy` directly — always get one from [`Anima.of()`](./anima.md#of).

## Inheritance

```text
Object
└── RefCounted
    └── AnimaNodeProxy
```

## Quick example

```gdscript
Anima.of($Panel).enter()

# later, in response to some input:
Anima.of($Panel).exit()

Anima.of($Panel).transition_to({
    NodePath("position:x"): 200.0,
    NodePath("modulate:a"): 1.0,
})
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Panel` refers to a node already in your scene.

## Properties

| Property | Type | Description |
|---|---|---|
| [`target`](#target) | `Node` | The node this proxy animates. |

---

### `target`

```gdscript
var target: Node
```

The node this proxy animates. Set once, from [`Anima.of()`](./anima.md#of), and never reassigned.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`to()`](#to) | [`AnimaPlayback`](./anima-playback.md) | Animates a single property on `target`. |
| [`transition_to()`](#transition_to) | [`AnimaPlayback`](./anima-playback.md) | Animates several properties on `target` together. |
| [`enter()`](#enter) | [`AnimaPlayback`](./anima-playback.md) | Fades `target` in. |
| [`exit()`](#exit) | [`AnimaPlayback`](./anima-playback.md) | Fades `target` out. |

---

### `to()`

```gdscript
func to(property: NodePath, to_value: Variant, duration: float = DEFAULT_DURATION, ease: AnimaEase = null) -> AnimaPlayback
```

Animates a single `property` on `target` to `to_value`, then plays it immediately and returns the resulting [`AnimaPlayback`](./anima-playback.md).

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---:|---|
| `property` | `NodePath` | — | The property to animate, e.g. `NodePath("position:x")`. |
| `to_value` | `Variant` | — | The value `property` should reach. |
| `duration` | `float` | `DEFAULT_DURATION` (`0.3`) | How long the motion takes, in seconds. |
| `ease` | `AnimaEase` | `null` | The easing curve to use. When `null`, falls back to [`default_ease()`](#default_ease). |

---

### `transition_to()`

```gdscript
func transition_to(properties: Dictionary, duration: float = DEFAULT_DURATION, ease: AnimaEase = null) -> AnimaPlayback
```

Animates every property in `properties` on `target` together, sharing the same `duration` and `ease`, and completes when the slowest one does.

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---:|---|
| `properties` | `Dictionary` | — | Maps each `NodePath` to animate to the `Variant` value it should reach. |
| `duration` | `float` | `DEFAULT_DURATION` (`0.3`) | How long the motion takes, in seconds. |
| `ease` | `AnimaEase` | `null` | The easing curve to use. When `null`, falls back to [`default_ease()`](#default_ease). |

---

### `enter()`

```gdscript
func enter() -> AnimaPlayback
```

Fades `target` in — `modulate:a` from `0.0` to `1.0` — using a built-in default motion. This is a standalone convenience; it does not yet read a `motion_in` from an [`AnimaBehaviour`](./anima-behaviour.md) attached to the node.

---

### `exit()`

```gdscript
func exit() -> AnimaPlayback
```

Fades `target` out — `modulate:a` toward `0.0` — the reverse of [`enter()`](#enter), using the same built-in default.

---

### `default_ease()`

```gdscript
static func default_ease() -> AnimaEase
```

Returns a fresh [`AnimaEase`](./anima-ease.md) instance with `kind = SINE` — the ease used by every method above when the caller doesn't pass one explicitly. Returns a new instance on every call rather than a shared constant, since a GDScript `const` can't hold a `Resource` instance.

## Constants

| Constant | Value | Description |
|---|---:|---|
| `DEFAULT_DURATION` | `0.3` | The duration used when the caller doesn't provide one. |

## Limitations

- `enter()` and `exit()` are fixed, built-in fades — they don't yet read `motion_in` / `motion_out` from an [`AnimaBehaviour`](./anima-behaviour.md) attached to the same node. That integration is separate, later work.

## Related API

- [`Anima`](./anima.md)
- [`AnimaBehaviour`](./anima-behaviour.md)
- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`AnimaPlayback`](./anima-playback.md)

## Source

- [`anima_node_proxy.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/runtime/anima_node_proxy.gd)
