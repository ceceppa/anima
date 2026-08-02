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

Playback speed multiplier.

### tags

Optional categorisation metadata — no logic reads or filters on this.

### metadata

Optional free-form metadata — no logic reads this.

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
