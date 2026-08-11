---
title: "AnimaGroupMotionFactory"
description: "Returned by [method Anima.group] — builds and plays an [AnimaGroupMotion]"
---

# AnimaGroupMotionFactory

## Overview

Returned by [method Anima.group] — builds and plays an [AnimaGroupMotion]
against a chosen target set with one line, mirroring [method Anima.grid]'s
ergonomics for the general (non-grid) group case. Only ever builds an
[AnimaGroupMotion], so — like [AnimaGridMotionFactory] — this factory
exists purely to keep the resolved target collection in scope across the
chain (`tech-spec.md` §Group convenience shorthand).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### container

The container whose children this group targets, when [method Anima.group]
was given a [Node]. `null` when given an explicit target array instead —
[constant AnimaTargetCollection.Kind.EXPLICIT] resolves its own [member
AnimaTargetCollection.reference_data] directly and needs no root
(`tech-spec.md` §Group convenience shorthand).

### motion

The group motion this factory builds. [member AnimaGroupMotion.item_motion]
stays unset until [method with_item_motion]/[method keyframes] is called —
required before [method play].

## Methods

### with_item_motion

Sets [member AnimaGroupMotion.item_motion]. Required before [method play] —
a group motion with no item motion has nothing to animate. Returns self so
calls can keep chaining.

### keyframes

Builds an [AnimaKeyframeMotion] from [param initial] (the same shape
[method Motion.keyframes] parses) and [param duration], then sets it as
[member AnimaGroupMotion.item_motion] — the same name [method
AnimaGridMotionFactory.keyframes] uses, but returns this factory (not the
built motion), so [method play] stays reachable at the end of the chain
(`tech-spec.md` §Group convenience shorthand).

### with_duration

Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
duration — [member AnimaPropertyMotion.duration] or [member
AnimaKeyframeMotion.duration], whichever applies. Reports an error and
leaves the factory otherwise unchanged when no item motion is set yet, or
when it's a kind with no duration of its own. Returns self so calls can
keep chaining — e.g. directly after [method keyframes].

### with_ease

Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
easing — [member AnimaPropertyMotion.ease] or [member
AnimaKeyframeMotion.default_ease], whichever applies. [param value] is a
full [AnimaEase] or a bare [enum AnimaEase.Kind], coerced via [method
AnimaEase.from]. Same missing- or incompatible-item-motion error behaviour
as [method with_duration].

### with_pivot

Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
pivot — [member AnimaPropertyMotion.pivot] or [member
AnimaKeyframeMotion.default_pivot], whichever applies. Same missing- or
incompatible-item-motion error behaviour as [method with_duration].

### with_delay

Sets [member AnimaMotion.delay] on the group motion as a whole — delays
the group's overall start, independent of its own per-item
stagger/distribution delay. Returns self so calls can keep chaining.

### wait

Delegates to [member motion]'s own [method AnimaMotion.wait] — delays the
start of whatever gets combined next via [method then]/[method with],
reachable mid-chain the same way [method with_delay] already is. Returns
this factory (not [member motion]) so [method play] stays reachable at
the end of the chain.

### on_started

Sets [member AnimaMotion.on_started_callback], invoked once when the group
motion starts. Returns self so calls can keep chaining.

### on_completed

Sets [member AnimaMotion.on_completed_callback], invoked once immediately
before a successful finish — never on cancellation. Returns self so calls
can keep chaining.

### then

Builds an [_AnimaSequence] playing [member motion], then [param other] — the
same resource [method AnimaMotion.then] would build, since [member motion]
already carries [member AnimaMotion.convenience_target] (set in [method
_init]). Returns the composite motion itself, not this factory — combining
the group with something else means nothing further configures this group
specifically. [param other] accepts the same types [method AnimaMotion.then]
does — an [AnimaMotion], or another convenience factory exposing `motion`.

### with

Same as [method then], but folds [param other] into the same
[_AnimaParallel] group instead of a new sequential step — see [method
AnimaMotion.with].

### play

Plays [member motion] against [member container] — [code]Anima.play(motion,
container)[/code]. Reports an error and returns `null` when [method
with_item_motion]/[method keyframes] was never called, instead of playing
an empty group.
