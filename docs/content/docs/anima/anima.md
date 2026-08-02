---
title: "Anima"
description: "Anima's public entry point — a [code]class_name[/code]-declared static"
---

# Anima

## Overview

Anima's public entry point — a [code]class_name[/code]-declared static
facade, never a [code]project.godot[/code] autoload. Zero mandatory setup:
[method play] works on the very first call.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### BEHAVIOUR_META_KEY

Node metadata key an [AnimaBehaviour] is stored under — no hidden child
node or node subclass (tech-spec.md §Data model `AnimaBehaviour` row).

### BEHAVIOUR_GROUP

Private group every node with an attached [AnimaBehaviour] is added to,
for discovery.

## Methods

### play

Plays [param motion] against [param target] and returns the resulting
[AnimaPlayback]. [param target] is optional when [param motion] supplies
its own targets (e.g. [AnimaStagger], which ignores [param target]
entirely). An [AnimaGroupMotion] is different: it still reads [param
target] as the root node its [member AnimaGroupMotion.target_collection]
resolves against — required for a [constant AnimaTargetCollection.Kind.CHILDREN]
or [constant AnimaTargetCollection.Kind.DESCENDANTS] collection, unused otherwise.

```gdscript
var collection := AnimaTargetCollection.new()
collection.kind = AnimaTargetCollection.Kind.CHILDREN
var group := Motion.group(collection, Motion.to(NodePath("modulate:a"), 1.0))

Anima.play(group, $CardRow) # $CardRow's children are the group's targets
```

### of

Returns a lightweight proxy for animating [param node] directly —
`Anima.of(node).to(...)` — without building an [AnimaMotion] resource by hand.

### attach_behaviour

Attaches [param behaviour] to [param node] via node metadata — [param node]'s
class and script are unchanged. Retrieve it later with [method get_behaviour].

### get_behaviour

Returns the [AnimaBehaviour] attached to [param node], or `null` if none.
