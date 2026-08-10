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

### is_reduced_motion_active

Resolves whether reduced motion is active for [param target] right now,
per the three-way rule documented on [member reduced_motion]. Shared by
[AnimaPlayback] and [AnimaGroupPlayback] so both consult the exact same rule.

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

### play_backwards

Same as [method play], except playback begins already running backward —
no prior forward run needed. Captures [param motion]'s start/end with one
zero-length frame (so nothing visibly moves first), then reverses in
place, the same way [method AnimaPlayback.reverse] would after a forward
run — see [method AnimaMotionInstance.build_reversed]. To choose direction
from a condition at play time, branch between [method play] and this
method (v1's `play_as_backwards_when`); no dedicated third method exists
for it.

### play_referenced

Resolves [param target_reference] then plays [param motion] against that
node. Supply [param scene_root] for a saved scene-relative reference or
[param playback_target] for a playback-context reference. Returns `null`
and reports the reason when the reference cannot safely resolve.

### of

Returns a lightweight proxy for animating [param node] directly —
`Anima.of(node).to(...)` — without building an [AnimaMotion] resource by hand.

### on

Returns a factory for authoring a common property change against [param
target] by name — `Anima.on(panel).opacity(1.0)` — instead of a raw
property path. Each factory method builds the same canonical
[AnimaPropertyMotion] direct [method Motion.to] authoring would, so the
result plays, composes, and reverses exactly like any other property
motion (`tech-spec.md` §Target-bound authoring contract). Reports an error
and returns `null` when [param target] is `null`.

### item

Returns a factory for authoring a common per-item change against an
[AnimaGroupMotion]'s [member AnimaGroupMotion.item_motion] by name —
`group.item_motion = Anima.item().opacity(1.0)` — the same methods
[method on] exposes, except no fixed target: the group resolves and
supplies each item's own target when it plays
(`tech-spec.md` §Target-bound authoring contract).

### grid

Returns a factory for playing [param container]'s children as a grid with
one line — `Anima.grid(container).with_item_motion(pulse).play()` —
instead of hand-building an [AnimaTargetCollection] and [AnimaGridMotion]
and calling [method play] separately (`tech-spec.md` §Grid convenience
shorthand). Reports an error and returns `null` when [param container] is
`null`, the same as [method on]. [param grid_size] accepts a [Vector2i],
[Vector2], [Node], or `null` — see [method AnimaGridMotionFactory._init].

### attach_behaviour

Attaches [param behaviour] to [param node] via node metadata — [param node]'s
class and script are unchanged. Retrieve it later with [method get_behaviour].

### get_behaviour

Returns the [AnimaBehaviour] attached to [param node], or `null` if none.
