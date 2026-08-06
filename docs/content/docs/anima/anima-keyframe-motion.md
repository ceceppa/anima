---
title: "AnimaKeyframeMotion"
description: "A CSS-inspired keyframe motion: one or more properties, each animated"
---

# AnimaKeyframeMotion

## Overview

A CSS-inspired keyframe motion: one or more properties, each animated
through its own list of stops at normalised offsets across one duration.

Two authoring surfaces produce the exact same resource — a dictionary
declared all at once, or built up one offset at a time with [method at]:

```gdscript
var a := Motion.keyframes({"from": {"opacity": 0.0}, 50: {"opacity": 1.0, "scale": Vector2(1.2, 1.2)}, "to": {"opacity": 1.0, "scale": Vector2.ONE}})
var b := Motion.keyframes() \
    .at("from", {"opacity": 0.0}) \
    .at(50, {"opacity": 1.0, "scale": Vector2(1.2, 1.2)}) \
    .at("to", {"opacity": 1.0, "scale": Vector2.ONE})
```

Developers never call the offset-flattening/parsing logic directly — both
surfaces above funnel through the same internal merge path, so they always
agree (tech-spec.md §Keyframe motions).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### tracks

This motion's tracks, one per animated property. Built and owned by the
parser — see [method at] to add to it directly.

### duration

Total duration in seconds. `0.0` resolves through the same duration chain
[AnimaPropertyMotion] uses (attached [AnimaBehaviour.default_duration],
else [member Anima.default_duration]) at playback time.

### default_ease

Easing used for a stop that doesn't set its own [member AnimaKeyframeStop.ease].

## Methods

### at

Merges one authored keyframe declaration into [member tracks] and returns
self, so calls can keep chaining. [param offsets] is `"from"`, `"to"`, a
0-100 number (a percentage), or an [Array] of any of those (a grouped
declaration — the same [param values] block applies to every resolved
offset). [param values]' non-underscore keys are property declarations —
a semantic name ([member _SEMANTIC_PROPERTY_PATHS]) or a raw property
path; a `_ease` key sets the resulting stop(s)' easing. Other
underscore-prefixed keys (`_hold`, `_marker`, `_callback`) are reserved
for a future phase and are accepted without error, never treated as a
property.

### with_duration

Sets [member duration] directly. Named `with_duration` rather than
`duration()` for the same reason as [AnimaPropertyMotion]'s own
`with_duration`/`with_ease`/`with_delay` — a bare method name would
collide with the field of the same name. Returns self so calls can keep
chaining.

### with_ease

Sets [member default_ease] directly, accepting either a full [AnimaEase]
or a bare [enum AnimaEase.Kind] (coerced via [method AnimaEase.from] —
`tech-spec.md` §Easing curve library). Named `with_ease` for the same
`with_`-prefix reason as [method with_duration]. Returns self so calls can
keep chaining — e.g. directly onto [method AnimaOnMotionFactory.keyframes]'s
own returned motion (`tech-spec.md` §Keyframe interface).

### parse_dictionary

Parses [param source] (the dictionary authoring form) into [member tracks]
in one pass — one [method at] call per top-level key, in whatever order
[Dictionary] iteration provides; each track ends up offset-sorted
regardless, since [method at] always sorts after merging.

### estimate_duration

Reports this motion's duration — the same [code]fixed(duration)[/code]
pattern [method AnimaPropertyMotion.estimate_duration] uses, including
reporting `fixed(0.0)` verbatim when [member duration] is still
chain-resolved rather than explicit.

### create_runtime

Builds the runtime instance that advances every track together. See
[method AnimaMotion.create_runtime] for [param context].

### validate

Returns messages describing missing tracks, empty tracks, or duplicate
stops at the same offset on the same track.
