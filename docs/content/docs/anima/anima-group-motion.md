---
title: "AnimaGroupMotion"
description: "Plays one shared motion across a collection of nodes as one coordinated group."
---

# AnimaGroupMotion

## Overview

Plays one shared motion across a collection of nodes as one coordinated group.

A collection chooses the nodes, and the item motion describes what each node
does. Playback, distribution, and order describe when each visible item starts.

```gdscript
var group := AnimaGroupMotion.new()
group.target_collection = AnimaTargetCollection.new()
group.item_motion = Motion.to(NodePath("position:x"), 120.0)
```

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### PlaybackMode

Chooses whether group items wait, begin together, or use staggered starts.

### CompletionPolicy

Chooses how a group treats item completion.

### ReverseOrderPolicy

Chooses how a reverse run reuses the recorded forward order.

### InvalidTargetPolicy

Chooses what happens when an item target cannot be used.

### EmptyGroupPolicy

Chooses what happens when a collection resolves to no targets.

## Properties and constants

### target_collection

The nodes this group will resolve when it plays.

### item_motion

The shared motion each resolved target receives.

### playback_mode

The relationship between item starts.

### distribution

Stagger timing choices, used only for [constant PlaybackMode.STAGGERED].

### order

The resolved-target order and starting point.

### sequential_gap

Extra wait after each completed item in [constant PlaybackMode.SEQUENTIAL].

### completion_policy

The completion event an author wants to observe.

### reverse_order_policy

The order policy used when the author reverses a group.

### invalid_target_policy

The response when a resolved target cannot play.

### empty_group_policy

The response when no targets are found.

## Methods

### estimate_duration

Reports the shared item motion’s duration because group scheduling is runtime work.

### create_runtime

Builds the runtime instance that resolves, schedules, and plays this group.
See [method AnimaMotion.create_runtime] for [param context].

### validate

Returns messages describing missing or incompatible authored group settings.
