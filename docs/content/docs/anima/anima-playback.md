---
title: "AnimaPlayback"
description: "Returned by [method Anima.play] — one call's live playback state and controls."
---

# AnimaPlayback

## Overview

Returned by [method Anima.play] — one call's live playback state and controls.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### State

Which lifecycle stage this playback is in.

## Signals

### finished

Emitted exactly once, on [constant State.FINISHED] or [constant State.CANCELLED].
[param success] is `true` only for a natural finish, `false` for a cancel.

## Properties and constants

### motion

The motion being played.

### target

The node it's playing against.

### state

Which lifecycle stage this playback is in.

### speed_scale

A multiplier applied to every frame this playback advances by. `1.0` is
normal speed; `2.0` runs twice as fast; `0.5` runs at half speed. When
[member motion] is an [AnimaGroupMotion], every active item shares this
same scaled delta, so changing it affects the whole group as one playback.

## Methods

### pause

Freezes the animated value in place until [method resume].

### resume

Continues playback from wherever [method pause] froze it.

### cancel

Stops playback and resolves [signal finished] as not-successful.

### retarget

Redirects a still-moving SPRING-eased AnimaPropertyMotion to a new
destination, preserving its current value/velocity instead of restarting
it from scratch. An error (not silently ignored) for any other motion
shape — composites and non-SPRING eases have no defined retarget behaviour.

### reverse

Reverses this playback, returning the target to what was actually observed
when the run began. For an [AnimaGroupMotion] (including [AnimaGridMotion]),
reuses its recorded target sequence instead of resolving and scheduling it
again — a [constant AnimaGroupOrder.Kind.RANDOM] order does not reshuffle —
and restarts this same playback from the top, respecting [member
AnimaGroupMotion.reverse_order_policy]. For a leaf [AnimaPropertyMotion] or
an [AnimaSequence]/[AnimaParallel] composition of them (e.g. a target-bound
motion authored through [method Anima.on]), replaces [member motion] with a
freshly built reversed motion and restarts playback against it — see
[method AnimaMotionInstance.build_reversed]. An error (not silently
ignored) when nothing has been captured yet to reverse to.
