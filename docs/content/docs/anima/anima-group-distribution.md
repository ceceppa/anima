---
title: "AnimaGroupDistribution"
description: "Describes how a staggered group spreads its starts across its visible items."
---

# AnimaGroupDistribution

## Overview

Describes how a staggered group spreads its starts across its visible items.

A group animation starts one shared motion on many nodes. Choose a fixed gap
when each item should wait the same amount, or a total duration when the
first and last items should fit inside one overall spread.

```gdscript
var distribution := AnimaGroupDistribution.new()
distribution.stagger_interval = 0.08
```

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Mode

Chooses whether a stagger uses one fixed gap or one total spread duration.

## Properties and constants

### mode

The way a stagger calculates its visible start delays.

### stagger_interval

The way a stagger calculates its visible start delays.
The delay between neighbouring stagger positions when [member mode] is
[constant Mode.FIXED_INTERVAL].

### total_stagger_duration

The way a stagger calculates its visible start delays.
The delay between neighbouring stagger positions when [member mode] is
[constant Mode.FIXED_INTERVAL].
The delay from the first to last stagger position when [member mode] is
[constant Mode.TOTAL_DURATION].

### ease

The way a stagger calculates its visible start delays.
The delay between neighbouring stagger positions when [member mode] is
[constant Mode.FIXED_INTERVAL].
The delay from the first to last stagger position when [member mode] is
[constant Mode.TOTAL_DURATION].
Optional curve used to distribute starts between the first and last item.

## Methods

### validate

Returns messages describing settings that cannot produce a visible schedule.
