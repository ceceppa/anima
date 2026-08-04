---
title: "AnimaMotion"
description: "Base [Resource] every composite and leaf motion extends. Defines the shared"
---

# AnimaMotion

## Overview

Base [Resource] every composite and leaf motion extends. Defines the shared
contract — [method estimate_duration], [method create_runtime],
[method validate] — every subtype must implement explicitly.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### DelayBasis

Which sibling instant [member delay] is measured from, inside an [AnimaSequence].

### CompletionValuePolicy

The value left on the target once a playback reaches [constant
AnimaPlayback.State.FINISHED] — whether by playing to the end naturally or
via [method AnimaPlayback.complete]. Unrelated to [constant
AnimaGroupMotion.CompletionPolicy] / [constant AnimaParallel.CompletionPolicy],
which decide *when* a composite counts as done, never what value is left
behind — see tech-spec.md's Key technical decisions.

### CancellationValuePolicy

The value left on the target when [method AnimaPlayback.cancel] is called.

## Properties and constants

### display_name

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].

### enabled

Disabled motions are skipped by every composite that contains them.

### delay

Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
this and [member delay_basis] this phase. May be negative (an overlap).

### delay_basis

Which sibling instant [member delay] is measured from.

### speed

Playback speed multiplier applied regardless of direction — pairs with
[member forward_speed]/[member reverse_speed], which apply only for their
matching direction. Set via [method with_speed].

### forward_speed

Multiplier applied only while this motion plays forward (root-level
playback only — see tech-spec.md §Speed, direction, and reduced motion).
Composes with [member speed] and [AnimaPlayback.speed_scale].

### reverse_speed

Multiplier applied only while this motion plays in reverse — via [method
AnimaPlayback.reverse] or [method Anima.play_backwards] — instead of
[member forward_speed]. Lets a motion's structural reverse (e.g. a closing
animation) play at a different pace than its forward run without
duplicating the motion or hand-adjusting durations.

### tags

Optional categorisation metadata — no logic reads or filters on this.

### metadata

Optional free-form metadata — no logic reads this.

### on_started_callback

Optional callback [AnimaPlayback] invokes exactly once, at the moment this
motion begins playing — including a fresh reversed run (see [method on_started]).

### on_completed_callback

Optional callback [AnimaPlayback] invokes exactly once, immediately before
it reports a successful finish — never on cancellation (see [method on_completed]).

### completion_value_policy

The value left behind once this motion's playback finishes — natural finish
or [method AnimaPlayback.complete]. See [enum CompletionValuePolicy].

### cancellation_value_policy

The value left behind when this motion's playback is cancelled. See
[enum CancellationValuePolicy].

## Methods

### estimate_duration

Reports this motion's duration kind and (when known) its length in seconds.
Every subtype must override this explicitly.

### create_runtime

Builds the runtime instance that [method AnimaMotionInstance.advance]s this
motion frame by frame. Every subtype must override this explicitly.

### validate

Returns a list of human-readable configuration errors, or an empty array
when this motion (and its children, if any) are valid.

### then

Builds an [AnimaSequence] that plays this motion, then [param other],
in order — the same resource [method Motion.sequence] would build.
Chaining a second `.then()` appends another step to one flat sequence
instead of nesting (`a.then(b).then(c)` is a 3-step sequence, not a
sequence of sequences). See [method with] for combining steps that
should start together instead.

### with

Folds [param other] into the same [AnimaParallel] group as whatever was
most recently chained — the group open since the last [method then], or
the whole chain when no [method then] preceded it. Multiple consecutive
`.with()` calls join one growing group rather than nesting
(`a.then(b).with(c).with(d)` is `b`, `c`, and `d` all starting together,
after `a`).

### on_started

Sets [member on_started_callback], invoked exactly once by [AnimaPlayback]
when this motion begins playing. Returns self so calls can keep chaining.

### on_completed

Sets [member on_completed_callback], invoked exactly once by [AnimaPlayback]
immediately before it reports a successful finish — never on cancellation.
Returns self so calls can keep chaining.

### repeat

Wraps this motion in a new [AnimaRepeat] that plays it [param count] times
— the same resource [method Motion.repeat] would build, now reachable as a
chain call on any motion, including one built through [method Anima.on].
[param count] defaults to `-1`, which repeats indefinitely instead of a
fixed number of times. [param alternate] `true` ping-pongs every other
iteration between forward and backward (v1's `loop_in_circle`) instead of
repeating identically.

### with_speed

Sets [member speed] directly. Named `with_speed` rather than `speed()` for
the same reason as `with_duration`/`with_ease`/`with_delay` on
[AnimaPropertyMotion] — a bare method name would collide with the field of
the same name. Returns self so calls can keep chaining.
