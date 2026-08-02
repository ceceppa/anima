---
title: "AnimaGroupOrder"
description: "Describes the order and starting point a group uses to reveal its targets."
---

# AnimaGroupOrder

## Overview

Describes the order and starting point a group uses to reveal its targets.

A resolved target collection is just a flat list of nodes. `AnimaGroupOrder`
decides which one visibly starts first, which starts last, and which ones
start together as part of the same "wave" — without the author calculating
any of that by hand. [AnimaGroupScheduler] reads this resource to turn a
plain node list into that visible sequence.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Kind

The broad ordering strategy for a resolved target collection.

### Origin

The point from which an order starts when that strategy uses an origin.
Only [constant Kind.GRID] and [constant Kind.DISTANCE] read this — every
other [member kind] has its own fixed starting point.

## Properties and constants

### kind

The ordering strategy used for the group.

### origin

The ordering strategy used for the group.
The start point for origin-based ordering. First preserves list traversal.

### origin_index

The ordering strategy used for the group.
The start point for origin-based ordering. First preserves list traversal.
The resolved-list position used when [member origin] is [constant Origin.INDEX].

### origin_point

The ordering strategy used for the group.
The start point for origin-based ordering. First preserves list traversal.
The resolved-list position used when [member origin] is [constant Origin.INDEX].
The virtual position used when [member origin] is [constant Origin.POINT].
See [constant Origin.POINT] for how [constant Kind.GRID] and
[constant Kind.DISTANCE] each interpret this differently.

### seed

The ordering strategy used for the group.
The start point for origin-based ordering. First preserves list traversal.
The resolved-list position used when [member origin] is [constant Origin.INDEX].
The virtual position used when [member origin] is [constant Origin.POINT].
See [constant Origin.POINT] for how [constant Kind.GRID] and
[constant Kind.DISTANCE] each interpret this differently.
Optional seed that makes a [constant Kind.RANDOM] order repeatable.

### grid_columns

The ordering strategy used for the group.
The start point for origin-based ordering. First preserves list traversal.
The resolved-list position used when [member origin] is [constant Origin.INDEX].
The virtual position used when [member origin] is [constant Origin.POINT].
See [constant Origin.POINT] for how [constant Kind.GRID] and
[constant Kind.DISTANCE] each interpret this differently.
Optional seed that makes a [constant Kind.RANDOM] order repeatable.
Column count used only by [constant Kind.GRID].
