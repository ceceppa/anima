---
title: "AnimaEase"
description: "Typed easing/curve resource shared by every leaf motion. `evaluate(t)` is"
---

# AnimaEase

## Overview

Typed easing/curve resource shared by every leaf motion. `evaluate(t)` is
the contract every non-stateful [member kind] implements; [constant Kind.SPRING]
is the one exception (see anima_property_motion.gd).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Kind

Curve shapes `evaluate(t: float) -> float` can produce. [constant Kind.SPRING]
is stateful and does not implement `evaluate(t)`.

### SpringModel

Which parameter set a [constant Kind.SPRING] reads. [constant SIMPLE]
(response/bounce) is the default, user-friendly surface; [constant ADVANCED]
exposes the underlying physics directly.

### SpringCompletionMode

When a [constant Kind.SPRING]-eased motion reports itself finished.

## Properties and constants

### DECAY_SCALE

Internal tuning constant for [constant Kind.DECAY]'s asymptotic curve shape.

### kind

Which curve shape [method evaluate] produces.

### exponent

Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].

### back_overshoot

Overshoot amount used only when [member kind] is [constant Kind.BACK].

### elastic_amplitude

Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].

### elastic_period

Oscillation period used only when [member kind] is [constant Kind.ELASTIC].

### bezier_p1

First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].

### bezier_p2

Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].

### curve

Sampled curve used only when [member kind] is [constant Kind.CURVE].

### evaluator

Custom evaluator `(t: float) -> float`, used only when [member kind] is
[constant Kind.CALLABLE].

### decay_rate

Decay rate used only when [member kind] is [constant Kind.DECAY].

### custom_samples

Evenly-spaced sample values used only when [member kind] is
[constant Kind.CUSTOM_SAMPLED].

### spring_model

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.

### spring_response

Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.

### spring_bounce

Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.

### spring_mass

Mass of the simulated body. Used by both spring models.

### spring_stiffness

Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.

### spring_damping

Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.

### spring_initial_velocity

Velocity the spring starts with.

### spring_completion_mode

When the spring-eased motion reports itself finished.

### spring_settle_velocity

Below this velocity, the spring is considered settled (`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).

### spring_settle_distance

Below this distance from the target, the spring is considered settled
(`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).

### spring_preview_duration

Fixed time to report finished after, used only when [member spring_completion_mode]
is [constant SpringCompletionMode.FIXED_PREVIEW_DURATION].

## Methods

### spring_stiffness_and_damping

Derives (stiffness, damping) from whichever [member spring_model] is active,
for the runtime instance that simulates a SPRING-eased motion frame by frame.

### spring_estimated_seconds

A rough settle-time estimate for a SPRING ease, derived from its parameters —
used by AnimaPropertyMotion.estimate_duration() to report AnimaDuration.ESTIMATED.

### from

Coerces [param value] into an [AnimaEase]: returned unchanged if it
already is one; wrapped in a fresh [AnimaEase] (only [member kind] set,
every other field at its own default) if it's a bare [enum Kind] value —
so a caller who only needs a named curve, the common case, never has to
construct and configure a whole resource for it (the same shorthand Anima
v1 offered). Reports an error and returns a default `AnimaEase.new()`
(`Kind.LINEAR`) for any other input type. Used by [method
AnimaKeyframeMotion.with_ease] and [method AnimaGridMotionFactory.with_ease]
(`tech-spec.md` §Easing curve library) — not by [member AnimaPropertyMotion.ease]
or its own `with_ease()`, which keep their existing `AnimaEase`-only signature.

### mirrored

Returns a copy of this ease with [member kind] swapped for its named
opposite (see [constant _MIRRORED_KIND]) — same curve family, opposite
direction. Every other field (amplitude, period, overshoot, spring/bezier
parameters, etc.) survives via [method Resource.duplicate]; a kind with no
mirror entry returns an otherwise-identical copy.

### evaluate

Returns the eased value for normalized time [param t] (`0.0`-`1.0`).
Not implemented for [constant Kind.SPRING] — that kind is stateful and is
advanced frame-by-frame instead (see anima_property_motion.gd).
