---
title: "AnimaKeyframeStop"
description: "One canonical stop within an [AnimaKeyframeTrack] — one property's value at"
---

# AnimaKeyframeStop

## Overview

One canonical stop within an [AnimaKeyframeTrack] — one property's value at
one normalised offset, with optional per-segment easing.

Never constructed by hand in ordinary authoring; [AnimaKeyframeMotion]
builds these while parsing an authored keyframe declaration.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### offset

Normalised position within the motion's duration, from 0.0 ("from") to 1.0 ("to").

### value

This stop's value for its track's property.

### ease

Easing for the segment arriving at this stop, from the previous stop's
offset to this one. `null` falls back to [member AnimaKeyframeMotion.default_ease].
