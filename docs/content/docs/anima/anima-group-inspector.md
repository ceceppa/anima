---
title: "AnimaGroupInspector"
description: "Shows resolved targets, generated timing, validation, and compilation status for one group."
---

# AnimaGroupInspector

## Overview

Shows resolved targets, generated timing, validation, and compilation status for one group.

Inspection reads the same resolver and scheduler used by playback. It does
not create a timeline or a second schedule, so the details shown here match
what the group will use when it plays.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Signals

### setup_requested

Requests a return to the Group Setup view for the same authored resource.

## Properties and constants

### targets

The latest resolved targets in collection order.

### start_offsets

The latest generated per-target start offsets.

### messages

Plain-language validation and compilation messages for this inspection.

### compile_eligible

Whether the current group can compile into a native Animation.

## Methods

### inspect

Inspects [param group] against [param root] and refreshes its derived details.

### validate

Recalculates target resolution, generated timing, validation, and compile eligibility.

### compile

Compiles the inspected group when it is eligible, otherwise keeps its blocker visible.

### resolved_targets_message

Returns this view's own resolved-target detail text — including the
next-step message shown when the resolved target list is empty
(`project-rules.md` §Editor Boundaries).
