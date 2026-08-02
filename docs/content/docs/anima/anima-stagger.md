---
title: "AnimaStagger"
description: "Plays one instance of [member template] per entry in [member targets],"
---

# AnimaStagger

## Overview

Plays one instance of [member template] per entry in [member targets],
started [member interval] seconds apart in the resolved [member order].

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Order

The order [member targets] start in.

## Properties and constants

### template

The motion played against every entry in [member targets].

### targets

Untyped (not Array[Node]): a typed Node array on a Resource script fails
Godot 4.6's external-class-member static resolution when set from another script.

### interval

Seconds between one target starting and the next.

### order

The order [member targets] start in.

### custom_order

Explicit start-order target indices, used only when [member order] is
[constant Order.CUSTOM].

## Methods

### resolve_order

Returns target indices in the order each entry should start, per `order`.

### estimate_duration

The template's own kind, combined with the staggered start offsets — not a
sum of per-target durations, since targets start staggered rather than end-to-end.

### create_runtime

Builds the runtime instance that plays [member template] across [member targets].

### validate

Requires [member template], and one [member custom_order] entry per target
when [member order] is [constant Order.CUSTOM].
