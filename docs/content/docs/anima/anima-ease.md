---
weight: 30
title: "AnimaEase"
description: "A curve resource controlling the pacing of a property animation."
draft: false
godot_version: "4.x"
anima_version: "2.x (unreleased)"
api_type: "class"
---

# AnimaEase

`AnimaEase` describes how a property animates over time — at a constant speed, starting slow and speeding up, bouncing, springing into place, or one of several other curve shapes. Every [`AnimaPropertyMotion`](./anima-property-motion.md) uses one.

```gdscript
class_name AnimaEase
extends Resource
```

## Overview

An easing curve is what makes motion feel natural instead of mechanical. Without one, a property changes at a perfectly constant rate for its whole duration — with one, it can start slowly and accelerate, overshoot and settle back, or bounce like a dropped ball.

You create an `AnimaEase`, pick a `kind`, set whichever fields that kind reads, and assign it to a motion's `ease` property. If you don't assign one, `AnimaPropertyMotion` uses a plain linear curve by default.

Every `kind` except `SPRING` works the same way: [`evaluate(t)`](#evaluate) takes a plain `0.0`-`1.0` progress and returns the eased progress for that same moment — a pure function of time. `SPRING` is the one exception. A spring doesn't have a fixed duration to divide progress against; it's a physical simulation that settles at its own pace, so it's driven frame-by-frame by the runtime instead of being sampled with `evaluate(t)`. See [Spring easing](#spring-easing) below.

## Inheritance

```text
Object
└── RefCounted
    └── Resource
        └── AnimaEase
```

## Quick example

```gdscript
var ease := AnimaEase.new()
ease.kind = AnimaEase.Kind.SINE

var motion := AnimaPropertyMotion.new()
motion.target_property = NodePath("position:x")
motion.to_value = 200.0
motion.duration = 0.5
motion.ease = ease

Anima.play(motion, $Sprite2D)
```

> This example assumes Anima is installed and enabled in the current Godot project, and that `$Sprite2D` refers to a node already in your scene.

## Properties

| Property | Type | Default | Used by |
|---|---|---:|---|
| [`kind`](#kind) | `Kind` | `LINEAR` | every kind |
| [`exponent`](#exponent) | `float` | `2.0` | `POLYNOMIAL` |
| [`back_overshoot`](#back_overshoot) | `float` | `1.70158` | `BACK` |
| [`elastic_amplitude`](#elastic_amplitude) | `float` | `1.0` | `ELASTIC` |
| [`elastic_period`](#elastic_period) | `float` | `0.3` | `ELASTIC` |
| [`bezier_p1`](#bezier_p1) | `Vector2` | `(0.42, 0.0)` | `CUBIC_BEZIER` |
| [`bezier_p2`](#bezier_p2) | `Vector2` | `(0.58, 1.0)` | `CUBIC_BEZIER` |
| [`curve`](#curve) | `Curve` | `null` | `CURVE` |
| [`evaluator`](#evaluator) | `Callable` | (unset) | `CALLABLE` |
| [`decay_rate`](#decay_rate) | `float` | `0.998` | `DECAY` |
| [`custom_samples`](#custom_samples) | `PackedFloat32Array` | `[]` | `CUSTOM_SAMPLED` |
| [`spring_model`](#spring_model) | `SpringModel` | `SIMPLE` | `SPRING` |
| [`spring_response`](#spring_response) | `float` | `0.5` | `SPRING` (`SIMPLE`) |
| [`spring_bounce`](#spring_bounce) | `float` | `0.0` | `SPRING` (`SIMPLE`) |
| [`spring_mass`](#spring_mass) | `float` | `1.0` | `SPRING` (both models) |
| [`spring_stiffness`](#spring_stiffness) | `float` | `100.0` | `SPRING` (`ADVANCED`) |
| [`spring_damping`](#spring_damping) | `float` | `10.0` | `SPRING` (`ADVANCED`) |
| [`spring_initial_velocity`](#spring_initial_velocity) | `float` | `0.0` | `SPRING` |
| [`spring_completion_mode`](#spring_completion_mode) | `SpringCompletionMode` | `STRICTLY_SETTLED` | `SPRING` |
| [`spring_settle_velocity`](#spring_settle_velocity) | `float` | `0.01` | `SPRING` |
| [`spring_settle_distance`](#spring_settle_distance) | `float` | `0.001` | `SPRING` |
| [`spring_preview_duration`](#spring_preview_duration) | `float` | `1.0` | `SPRING` (`FIXED_PREVIEW_DURATION` only) |

---

### `kind`

```gdscript
var kind: Kind = Kind.LINEAR
```

Selects which curve shape this easing uses. See [Enumerations](#enumerations) below for every available value.

---

### `exponent`

```gdscript
var exponent: float = 2.0
```

Only has an effect when `kind` is `POLYNOMIAL`. A value of `2.0` gives a gentle acceleration; higher values accelerate more sharply.

---

### `back_overshoot`

```gdscript
var back_overshoot: float = 1.70158
```

Only has an effect when `kind` is `BACK`. Controls how far the curve dips below its start (or past its end) before settling — higher values overshoot further.

---

### `elastic_amplitude`

```gdscript
var elastic_amplitude: float = 1.0
```

Only has an effect when `kind` is `ELASTIC`. Controls how far the oscillation swings; values below `1.0` are clamped up to `1.0`.

---

### `elastic_period`

```gdscript
var elastic_period: float = 0.3
```

Only has an effect when `kind` is `ELASTIC`. Controls how fast the oscillation repeats — a smaller period oscillates faster.

---

### `bezier_p1`

```gdscript
var bezier_p1: Vector2 = Vector2(0.42, 0.0)
```

The first control point, only used when `kind` is `CUBIC_BEZIER`. Only the `y` component affects the curve shape — `evaluate(t)` parametrizes directly by `t`, it doesn't solve `x` for a given input as CSS-style Bézier easings do.

---

### `bezier_p2`

```gdscript
var bezier_p2: Vector2 = Vector2(0.58, 1.0)
```

The second control point, only used when `kind` is `CUBIC_BEZIER`. As with `bezier_p1`, only the `y` component affects the curve shape.

---

### `curve`

```gdscript
var curve: Curve
```

A Godot `Curve` resource to sample, only used when `kind` is `CURVE`. If left `null`, `evaluate(t)` falls back to a linear curve.

---

### `evaluator`

```gdscript
var evaluator: Callable
```

A custom `(t: float) -> float` function, only used when `kind` is `CALLABLE`. If left unset (invalid), `evaluate(t)` falls back to a linear curve.

---

### `decay_rate`

```gdscript
var decay_rate: float = 0.998
```

Only has an effect when `kind` is `DECAY`. Values closer to `1.0` decay more slowly (a longer-feeling ease-out); smaller values decay faster.

---

### `custom_samples`

```gdscript
var custom_samples: PackedFloat32Array = PackedFloat32Array()
```

A list of evenly-spaced sample values across the `0.0`-`1.0` range, only used when `kind` is `CUSTOM_SAMPLED`. `evaluate(t)` linearly interpolates between the two nearest samples. An empty array falls back to linear; a single-value array returns that value for every `t`.

---

### `spring_model`

```gdscript
var spring_model: SpringModel = SpringModel.SIMPLE
```

Only has an effect when `kind` is `SPRING`. Selects which set of fields the spring simulation reads — `SIMPLE` (response/bounce, the default) or `ADVANCED` (raw stiffness/damping). See [Spring easing](#spring-easing) below.

---

### `spring_response`

```gdscript
var spring_response: float = 0.5
```

Roughly how long the spring takes to feel settled, in seconds. Only read when `spring_model` is `SIMPLE`.

---

### `spring_bounce`

```gdscript
var spring_bounce: float = 0.0
```

Overshoot amount, from `-1.0` to `1.0`. `0.0` is critically damped (no overshoot); positive values overshoot and oscillate before settling. Only read when `spring_model` is `SIMPLE`.

---

### `spring_mass`

```gdscript
var spring_mass: float = 1.0
```

The mass of the simulated body. Read by both spring models — a heavier mass responds more sluggishly for the same stiffness and damping.

---

### `spring_stiffness`

```gdscript
var spring_stiffness: float = 100.0
```

The spring's stiffness — higher values pull toward the target more forcefully, producing a snappier motion. Only read when `spring_model` is `ADVANCED`.

---

### `spring_damping`

```gdscript
var spring_damping: float = 10.0
```

The spring's damping — higher values settle faster with less oscillation. Only read when `spring_model` is `ADVANCED`.

---

### `spring_initial_velocity`

```gdscript
var spring_initial_velocity: float = 0.0
```

The velocity the spring starts with, read by both spring models. Useful for chaining a spring motion out of an existing velocity (for example, a drag gesture's release velocity).

---

### `spring_completion_mode`

```gdscript
var spring_completion_mode: SpringCompletionMode = SpringCompletionMode.STRICTLY_SETTLED
```

Controls when a `SPRING`-eased motion reports itself finished. See [Enumerations](#enumerations) below.

---

### `spring_settle_velocity`

```gdscript
var spring_settle_velocity: float = 0.01
```

Below this velocity, the spring is considered settled. Only relevant when `spring_completion_mode` is `STRICTLY_SETTLED` or `VISUALLY_SETTLED`.

---

### `spring_settle_distance`

```gdscript
var spring_settle_distance: float = 0.001
```

Below this distance from the target value, the spring is considered settled. Only relevant when `spring_completion_mode` is `STRICTLY_SETTLED` or `VISUALLY_SETTLED`.

---

### `spring_preview_duration`

```gdscript
var spring_preview_duration: float = 1.0
```

A fixed number of seconds after which the motion reports finished, regardless of the spring's actual physical state. Only read when `spring_completion_mode` is `FIXED_PREVIEW_DURATION`.

## Methods

| Method | Returns | Description |
|---|---|---|
| [`evaluate()`](#evaluate) | `float` | Given a progress from `0.0` to `1.0`, returns the eased progress. Not implemented for `SPRING`. |
| [`spring_stiffness_and_damping()`](#spring_stiffness_and_damping) | `Vector2` | Resolves the active spring model down to a `(stiffness, damping)` pair. |
| [`spring_estimated_seconds()`](#spring_estimated_seconds) | `float` | A rough settle-time estimate for a `SPRING` ease. |

---

### `evaluate()`

```gdscript
func evaluate(t: float) -> float
```

Takes a plain linear progress value between `0.0` (start) and `1.0` (end) and returns the eased value for that same moment. You don't normally call this yourself — [`AnimaPropertyMotion`](./anima-property-motion.md) calls it internally every frame — but it's useful if you want to preview or graph a curve.

Not implemented for `kind = SPRING` — a spring is stateful and is advanced frame-by-frame by the runtime instead. See [Spring easing](#spring-easing).

---

### `spring_stiffness_and_damping()`

```gdscript
func spring_stiffness_and_damping() -> Vector2
```

Derives a `(stiffness, damping)` pair from whichever `spring_model` is active — used internally by the runtime instance that simulates a `SPRING`-eased motion frame by frame. When `spring_model` is `ADVANCED`, this simply returns `spring_stiffness` and `spring_damping` directly. When it's `SIMPLE`, it converts `spring_response` and `spring_bounce` into the equivalent physical parameters.

Returns a `Vector2` where `x` is stiffness and `y` is damping.

---

### `spring_estimated_seconds()`

```gdscript
func spring_estimated_seconds() -> float
```

A rough settle-time estimate for a `SPRING` ease, derived from its current parameters. This is what [`AnimaPropertyMotion.estimate_duration()`](./anima-property-motion.md#estimate_duration) calls to report an `ESTIMATED` [`AnimaDuration`](./anima-duration.md) for a spring-eased motion — since a spring doesn't have a fixed, exactly-known length, this is a best guess rather than a precise figure.

## Spring easing

`SPRING` behaves differently from every other `kind`. Instead of a curve sampled by `evaluate(t)` against a fixed duration, it's a damped-harmonic-oscillator simulation advanced frame by frame — closer to a physics body settling toward a target than a pre-shaped curve.

Two parameter sets describe the same underlying physics, chosen via `spring_model`:

- **`SIMPLE`** (the default) — tune `spring_response` (roughly how long it takes to feel settled) and `spring_bounce` (how much it overshoots, `-1.0` to `1.0`, with `0.0` meaning no overshoot). This is the friendlier surface for most use.
- **`ADVANCED`** — tune `spring_stiffness` and `spring_damping` directly, for direct control over the underlying physics.

Because a spring doesn't have a fixed duration, a `SPRING`-eased [`AnimaPropertyMotion`](./anima-property-motion.md) reports its [`estimate_duration()`](./anima-property-motion.md#estimate_duration) as `AnimaDuration.Kind.ESTIMATED` rather than `FIXED` — see that page for details.

`spring_completion_mode` decides when the motion considers itself finished: waiting for the spring to physically settle below `spring_settle_velocity`/`spring_settle_distance` (`STRICTLY_SETTLED`, the default, or the more lenient `VISUALLY_SETTLED`), stopping after a fixed `spring_preview_duration` regardless of physical state (`FIXED_PREVIEW_DURATION`), or leaving completion to be triggered manually (`MANUAL`).

## Enumerations

### `Kind`

```gdscript
enum Kind {
    LINEAR,
    POLYNOMIAL,
    SINE,
    EXPONENTIAL,
    CIRCULAR,
    BACK,
    BOUNCE,
    ELASTIC,
    CUBIC_BEZIER,
    CURVE,
    CALLABLE,
    DECAY,
    CUSTOM_SAMPLED,
    SPRING,
}
```

| Value | Description |
|---|---|
| `LINEAR` | Constant speed from start to end. |
| `POLYNOMIAL` | Accelerates according to `exponent`. |
| `SINE` | A gentle, sine-wave-shaped acceleration. |
| `EXPONENTIAL` | Starts very slowly, then accelerates sharply near the end. |
| `CIRCULAR` | A curve based on a quarter-circle arc. |
| `BACK` | Dips past the start (or end) before settling, controlled by `back_overshoot`. |
| `BOUNCE` | Bounces like a dropped ball settling to rest. |
| `ELASTIC` | Oscillates like a stretched elastic band, controlled by `elastic_amplitude`/`elastic_period`. |
| `CUBIC_BEZIER` | A cubic Bézier shape, controlled by `bezier_p1`/`bezier_p2`. |
| `CURVE` | Samples an assigned `curve` resource. |
| `CALLABLE` | Calls a custom `evaluator` function. |
| `DECAY` | An asymptotic ease-out, controlled by `decay_rate`. |
| `CUSTOM_SAMPLED` | Interpolates between explicit `custom_samples` values. |
| `SPRING` | A stateful, physically-simulated spring. See [Spring easing](#spring-easing). |

### `SpringModel`

```gdscript
enum SpringModel {
    SIMPLE,
    ADVANCED,
}
```

| Value | Description |
|---|---|
| `SIMPLE` | Tune `spring_response`/`spring_bounce` — the default, user-friendly surface. |
| `ADVANCED` | Tune `spring_stiffness`/`spring_damping` directly. |

### `SpringCompletionMode`

```gdscript
enum SpringCompletionMode {
    STRICTLY_SETTLED,
    VISUALLY_SETTLED,
    FIXED_PREVIEW_DURATION,
    MANUAL,
}
```

| Value | Description |
|---|---|
| `STRICTLY_SETTLED` | Finishes once velocity and distance are both below their settle thresholds. The default. |
| `VISUALLY_SETTLED` | A more lenient settle check, for cases where `STRICTLY_SETTLED` would keep the motion "playing" longer than it looks like it's moving. |
| `FIXED_PREVIEW_DURATION` | Finishes after a fixed `spring_preview_duration`, regardless of physical state. |
| `MANUAL` | Never finishes on its own — completion must be triggered some other way. |

## Related API

- [`AnimaPropertyMotion`](./anima-property-motion.md)
- [`AnimaDuration`](./anima-duration.md)

## Source

- [`anima_ease.gd`](https://github.com/ceceppa/anima/blob/main/addons/anima/motion/resources/anima_ease.gd)
