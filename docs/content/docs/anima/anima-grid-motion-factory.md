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

### DEFAULT_DURATION

Duration a distance-formula preset's own default item motion uses, when it
supplies one (`tech-spec.md` §Grid convenience shorthand).

### DEFAULT_EASE

Ease a distance-formula preset's own default item motion uses. Scoped to
this default only — [member AnimaKeyframeMotion.default_ease]'s own
general `LINEAR` default is untouched.

### container

The node whose children this grid motion targets.

### motion

The grid motion this factory builds. Every field keeps [AnimaGridMotion]'s
own constructor default — except [member AnimaGroupMotion.target_collection],
set to [constant AnimaTargetCollection.Kind.CHILDREN] against [member
container], and [member AnimaGridMotion.distance_formula], set to
[constant AnimaGridMotion.DistanceFormula.EUCLIDEAN] — a factory-level
default distinct from [AnimaGridMotion]'s own general-purpose `ROW`
default, since this shorthand's own common case is radiating outward from
a point (`tech-spec.md` §Grid convenience shorthand).

## Methods

### with_item_motion

Sets [member AnimaGroupMotion.item_motion]. Required before [method play] —
a grid motion with no item motion has nothing to animate. Returns self so
calls can keep chaining.

### with_dimensions

Sets [member AnimaGridMotion.grid_dimensions]. Also auto-derives a centred
[member AnimaGridMotion.start_point] — `Vector2i(floori(value.x / 2.0),
floori(value.y / 2.0))` — unless [method with_start_point] has already been
called explicitly on this factory (`tech-spec.md` §Grid convenience
shorthand). Floored, not rounded, so an odd dimension centres on the
middle index rather than one rounded up past it. Returns self so calls can
keep chaining.

### with_distance_formula

Sets [member AnimaGridMotion.distance_formula]. Returns self so calls can
keep chaining.

### radial

Named presets for every [enum AnimaGridMotion.DistanceFormula] value — pure
sugar for [method with_distance_formula], one name per formula with no
aliases (`tech-spec.md` §Grid convenience shorthand). Preset for
[constant AnimaGridMotion.DistanceFormula.EUCLIDEAN].

### diamond

Preset for [constant AnimaGridMotion.DistanceFormula.MANHATTAN].

### box

Preset for [constant AnimaGridMotion.DistanceFormula.CHEBYSHEV].

### by_row

Preset for [constant AnimaGridMotion.DistanceFormula.ROW].

### by_column

Preset for [constant AnimaGridMotion.DistanceFormula.COLUMN].

### diagonal

Preset for [constant AnimaGridMotion.DistanceFormula.DIAGONAL].

### anti_diagonal

Preset for [constant AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL].

### clockwise

Preset for [constant AnimaGridMotion.DistanceFormula.CLOCKWISE].

### counter_clockwise

Preset for [constant AnimaGridMotion.DistanceFormula.ANTICLOCKWISE].

### spiral_in

Preset for [constant AnimaGridMotion.DistanceFormula.SPIRAL_INWARD].

### spiral_out

Preset for [constant AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD].

### serpentine_row

Preset for [constant AnimaGridMotion.DistanceFormula.SERPENTINE_ROW].

### serpentine_column

Preset for [constant AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN].

### with_start_point

Sets [member AnimaGridMotion.start_point] and marks it explicit, so no
later [method with_dimensions] call auto-derives over it — whether this is
called before or after [method with_dimensions] in the chain. Returns self
so calls can keep chaining.

### with_stagger_interval

Sets [member AnimaGroupDistribution.stagger_interval]. Returns self so
calls can keep chaining.

### with_delay

Sets [member AnimaMotion.delay] on the grid motion as a whole — delays the
grid's overall start, independent of its own per-item stagger/distribution
delay. Returns self so calls can keep chaining.

### wait

Delegates to [member motion]'s own [method AnimaMotion.wait] — delays the
start of whatever gets combined next via [method then]/[method with],
reachable mid-chain the same way [method with_delay] already is. Returns
this factory (not [member motion]) so [method play] stays reachable at
the end of the chain.

### on_started

Sets [member AnimaMotion.on_started_callback], invoked once when the grid
motion starts. Returns self so calls can keep chaining.

### on_completed

Sets [member AnimaMotion.on_completed_callback], invoked once immediately
before a successful finish — never on cancellation. Returns self so calls
can keep chaining.

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
[_AnimaSequence]). Returns self so calls can keep chaining — e.g. directly
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

### then

Builds an [_AnimaSequence] playing [member motion], then [param other] — the
same resource [method AnimaMotion.then] would build, since [member motion]
already carries [member AnimaMotion.convenience_target] (set in [method _init]).
Returns the composite motion itself, not this factory: combining the grid
with something else means nothing further configures this grid specifically
(`tech-spec.md` §Grid convenience shorthand, "`.then()`/`.with()` (phase-15)").
[param other] accepts the same types [method AnimaMotion.then] does —
an [AnimaMotion], or another convenience factory exposing `motion`.

### with

Same as [method then], but folds [param other] into the same [_AnimaParallel]
group instead of a new sequential step — see [method AnimaMotion.with].

### play

Plays [member motion] against [member container] — [code]Anima.play(motion, container)[/code].
Reports an error and returns `null` when [method with_item_motion] was
never called, instead of playing an empty grid.
