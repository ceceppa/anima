---
title: "AnimaSequence"
description: "Runs each enabled child in [member children] one after another; completes"
---

# AnimaSequence

## Overview

Runs each enabled child in [member children] one after another; completes
when the last one finishes.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### children

The motions to run in order.

## Methods

### compute_schedule

Returns each enabled child's scheduled start time (seconds since the
sequence's own start), honouring delay/delay_basis. Parallel array to
this sequence's enabled children, in the same order.

### estimate_duration

Sum of every enabled child's scheduled end time, once every child reports
a fixed duration (worst-kind-wins otherwise). Honours [method compute_schedule]'s
delay/overlap timing, not a plain sum of durations.

### create_runtime

Builds the runtime instance that plays each child per [method compute_schedule].

### validate

Validates every child recursively.
