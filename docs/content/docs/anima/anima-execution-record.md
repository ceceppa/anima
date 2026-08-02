---
title: "AnimaExecutionRecord"
description: "A retained snapshot of exactly how one group execution was resolved and"
---

# AnimaExecutionRecord

## Overview

A retained snapshot of exactly how one group execution was resolved and
scheduled.

Playing an [AnimaGroupMotion] resolves its targets and derives a schedule
once, right at the start. This record is that snapshot, kept for the rest
of the run. Reversing, tracing, or inspecting the group afterward reads
this record instead of resolving and scheduling the group again, so a
reverse always replays exactly what actually happened — including which
targets were actually found — rather than a fresh, and potentially
different, resolution.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### entries

Every resolved target for this execution, already in start order —
[code]entries[0][/code] is the target that started first.

### seed

The random seed this execution was resolved with. Only meaningful when
the group's order is [constant AnimaGroupOrder.Kind.RANDOM]; kept here
regardless so a caller can always trace or replay an execution without
reaching back into the group's resource.

## Methods

### from_schedule

Builds a record from a freshly-derived [member AnimaGroupScheduler.Schedule].

### reversed

Returns a new record with every entry's rank and start offset mirrored
around this one, so the target that started last now starts first —
without reshuffling a [constant AnimaGroupOrder.Kind.RANDOM] order or
resolving targets again.
