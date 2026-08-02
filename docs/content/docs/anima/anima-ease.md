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

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].

### back_overshoot

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].

### elastic_amplitude

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].

### elastic_period

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].

### bezier_p1

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].

### bezier_p2

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].

### curve

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Sampled curve used only when [member kind] is [constant Kind.CURVE].

### evaluator

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Sampled curve used only when [member kind] is [constant Kind.CURVE].
Custom evaluator `(t: float) -> float`, used only when [member kind] is
[constant Kind.CALLABLE].

### decay_rate

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Sampled curve used only when [member kind] is [constant Kind.CURVE].
Custom evaluator `(t: float) -> float`, used only when [member kind] is
[constant Kind.CALLABLE].
Decay rate used only when [member kind] is [constant Kind.DECAY].

### custom_samples

Which curve shape [method evaluate] produces.
Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
Overshoot amount used only when [member kind] is [constant Kind.BACK].
Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
Sampled curve used only when [member kind] is [constant Kind.CURVE].
Custom evaluator `(t: float) -> float`, used only when [member kind] is
[constant Kind.CALLABLE].
Decay rate used only when [member kind] is [constant Kind.DECAY].
Evenly-spaced sample values used only when [member kind] is
[constant Kind.CUSTOM_SAMPLED].

### spring_model

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.

### spring_response

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.

### spring_bounce

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.

### spring_mass

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.

### spring_stiffness

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.

### spring_damping

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.

### spring_initial_velocity

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.
Velocity the spring starts with.

### spring_completion_mode

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.
Velocity the spring starts with.
When the spring-eased motion reports itself finished.

### spring_settle_velocity

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.
Velocity the spring starts with.
When the spring-eased motion reports itself finished.
Below this velocity, the spring is considered settled (`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).

### spring_settle_distance

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.
Velocity the spring starts with.
When the spring-eased motion reports itself finished.
Below this velocity, the spring is considered settled (`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).
Below this distance from the target, the spring is considered settled
(`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).

### spring_preview_duration

Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
(response/bounce) by default.
Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
Mass of the simulated body. Used by both spring models.
Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.
Velocity the spring starts with.
When the spring-eased motion reports itself finished.
Below this velocity, the spring is considered settled (`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).
Below this distance from the target, the spring is considered settled
(`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).
Fixed time to report finished after, used only when [member spring_completion_mode]
is [constant SpringCompletionMode.FIXED_PREVIEW_DURATION].

## Methods

### spring_stiffness_and_damping

Derives (stiffness, damping) from whichever [member spring_model] is active,
for the runtime instance that simulates a SPRING-eased motion frame by frame.

### spring_estimated_seconds

A rough settle-time estimate for a SPRING ease, derived from its parameters —
used by AnimaPropertyMotion.estimate_duration() to report AnimaDuration.ESTIMATED.

### evaluate

Returns the eased value for normalized time [param t] (`0.0`-`1.0`).
Not implemented for [constant Kind.SPRING] — that kind is stateful and is
advanced frame-by-frame instead (see anima_property_motion.gd).
