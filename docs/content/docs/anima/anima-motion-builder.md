---
title: "Motion"
description: "Fluent, chainable factory layer over the [AnimaMotion] resource hierarchy —"
---

# Motion

## Overview

Fluent, chainable factory layer over the [AnimaMotion] resource hierarchy —
builds the same resources direct construction does, nothing new at runtime.
Unprefixed by design; see `project-rules.md` §Naming.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### sequence

Builds an [AnimaSequence] playing [param children] one after another.

### parallel

Builds an [AnimaParallel] playing [param children] together.

### stagger

Builds an [AnimaStagger] playing [param template] against each of [param targets],
[param interval] seconds apart.

### repeat

Builds an [AnimaRepeat] playing [param child] [param count] times.

### race

Builds an [AnimaRace] that completes as soon as the fastest of [param children] finishes.

### conditional

Builds an [AnimaConditional] that plays [param when_true] or [param when_false]
depending on [param condition].

### to

Builds an [AnimaPropertyMotion] animating [param target_property] to [param to_value].

### group

Builds an [AnimaGroupMotion] playing [param item_motion] against every
target [param target_collection] resolves. The rest of a group's
configuration — [member AnimaGroupMotion.playback_mode], [member
AnimaGroupMotion.distribution], [member AnimaGroupMotion.order], and its
policies — all have working defaults, so set only the ones you need to
change directly on the returned resource.

```gdscript
var collection := AnimaTargetCollection.new()
collection.kind = AnimaTargetCollection.Kind.CHILDREN

var group := Motion.group(collection, Motion.to(NodePath("modulate:a"), 1.0))
group.order.kind = AnimaGroupOrder.Kind.CENTRED

Anima.play(group, $CardRow)
```

### keyframes

Builds an [AnimaKeyframeMotion]. [param initial], if non-empty, is parsed
immediately (the dictionary authoring form); the returned motion also
accepts further [method AnimaKeyframeMotion.at] calls (the fluent form) —
both produce the exact same resource.

```gdscript
var a := Motion.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}})
var b := Motion.keyframes().at("from", {"opacity": 0.0}).at("to", {"opacity": 1.0})
```
