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

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
Disabled motions are skipped by every composite that contains them.

### delay

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
Disabled motions are skipped by every composite that contains them.
Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
this and [member delay_basis] this phase. May be negative (an overlap).

### delay_basis

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
Disabled motions are skipped by every composite that contains them.
Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
this and [member delay_basis] this phase. May be negative (an overlap).
Which sibling instant [member delay] is measured from.

### speed

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
Disabled motions are skipped by every composite that contains them.
Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
this and [member delay_basis] this phase. May be negative (an overlap).
Which sibling instant [member delay] is measured from.
Playback speed multiplier.

### tags

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
Disabled motions are skipped by every composite that contains them.
Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
this and [member delay_basis] this phase. May be negative (an overlap).
Which sibling instant [member delay] is measured from.
Playback speed multiplier.
Optional categorisation metadata — no logic reads or filters on this.

### metadata

Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
Disabled motions are skipped by every composite that contains them.
Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
this and [member delay_basis] this phase. May be negative (an overlap).
Which sibling instant [member delay] is measured from.
Playback speed multiplier.
Optional categorisation metadata — no logic reads or filters on this.
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
