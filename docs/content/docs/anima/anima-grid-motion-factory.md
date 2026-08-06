---
title: "AnimaGridMotionFactory"
description: "Returned by [method Anima.grid] — builds and plays an [AnimaGridMotion]"
---

# AnimaGridMotionFactory

## Overview

Returned by [method Anima.grid] — builds and plays an [AnimaGridMotion]
against [member container] with one line, mirroring [method Anima.on]'s
ergonomics for the one motion kind it doesn't cover. Only ever builds an
[AnimaGridMotion], so — unlike [AnimaOnMotionFactory], which needs a
factory because one target maps to many possible property-motion kinds —
this factory exists purely to keep [member container] in scope across the
chain (`tech-spec.md` §Grid convenience shorthand).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### container

The node whose children this grid motion targets.

### motion

The grid motion this factory builds. Every field keeps [AnimaGridMotion]'s
own constructor default except [member AnimaGroupMotion.target_collection],
set to [constant AnimaTargetCollection.Kind.CHILDREN] against [member container].

## Methods

### with_item_motion

Sets [member AnimaGroupMotion.item_motion]. Required before [method play] —
a grid motion with no item motion has nothing to animate. Returns self so
calls can keep chaining.

### with_dimensions

Sets [member AnimaGridMotion.grid_dimensions]. Returns self so calls can
keep chaining.

### with_distance_formula

Sets [member AnimaGridMotion.distance_formula]. Returns self so calls can
keep chaining.

### with_start_point

Sets [member AnimaGridMotion.start_point]. Returns self so calls can keep
chaining.

### with_stagger_interval

Sets [member AnimaGroupDistribution.stagger_interval]. Returns self so
calls can keep chaining.

### keyframes

Builds an [AnimaKeyframeMotion] from [param initial] (the same shape
[method Motion.keyframes] parses) and [param duration], then sets it as
[member AnimaGroupMotion.item_motion] — the same name [method
AnimaOnMotionFactory.keyframes] uses, but returns this factory (not the
built motion), so [method play] stays reachable at the end of the chain
the same way every other method here does (`tech-spec.md` §Grid
convenience shorthand).

### with_duration

Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
duration — [member AnimaPropertyMotion.duration] or [member
AnimaKeyframeMotion.duration], whichever applies. Reports an error and
leaves the factory otherwise unchanged when no item motion is set yet, or
when it's a kind with no duration of its own (a composite like
[AnimaSequence]). Returns self so calls can keep chaining — e.g. directly
after [method keyframes] (`tech-spec.md` §Grid convenience shorthand).

### with_ease

Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
easing — [member AnimaPropertyMotion.ease] or [member
AnimaKeyframeMotion.default_ease], whichever applies. [param value] is a
full [AnimaEase] or a bare [enum AnimaEase.Kind], coerced via [method
AnimaEase.from] (`tech-spec.md` §Easing curve library). Same missing- or
incompatible-item-motion error behaviour as [method with_duration].

### with_pivot

Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
pivot — [member AnimaPropertyMotion.pivot] or [member
AnimaKeyframeMotion.default_pivot], whichever applies. Same missing- or
incompatible-item-motion error behaviour as [method with_duration].

### play

Plays [member motion] against [member container] — [code]Anima.play(motion, container)[/code].
Reports an error and returns `null` when [method with_item_motion] was
never called, instead of playing an empty grid.
