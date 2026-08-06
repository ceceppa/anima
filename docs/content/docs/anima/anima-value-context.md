---
title: "AnimaValueContext"
description: "Transient, per-resolution context an [AnimaValue] resolves against — never"
---

# AnimaValueContext

## Overview

Transient, per-resolution context an [AnimaValue] resolves against — never
serialized, built fresh for each resolution. A plain (non-group) motion's
context has [member target] and [member root] pointing at the same node; a
group/grid item's context has [member root] pointing at the group's own
container instead (`tech-spec.md` §Dynamic values).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### target

The node this specific value resolution is happening for — [constant
AnimaValue.Kind.TARGET] reads from this node.

### root

The node [constant AnimaValue.Kind.ROOT] reads from, and [constant
AnimaValue.Kind.NODE] paths resolve relative to. Equal to [member target]
for a plain motion; the group's own container for a group/grid item.

### context_data

Arbitrary data supplied to the playback before it starts, read by
[constant AnimaValue.Kind.CONTEXT]. Shares the same [Dictionary] object as
[member AnimaPlayback.context_data] — mutate that dictionary in place
rather than reassigning it, or a context already built keeps pointing at
the old one.

### group_index

This item's position in start order among its group, or `-1` outside a
group/grid item.

### group_count

The group's total item count, or `-1` outside a group/grid item.

### group_normalised_index

[member group_index] normalised to `0.0`-`1.0` across the group, or `-1.0`
outside a group/grid item.

### grid_row

This item's row within an [AnimaGridMotion], or `-1` outside one.

### grid_column

This item's column within an [AnimaGridMotion], or `-1` outside one.
