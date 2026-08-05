---
title: "AnimaKeyframeTrack"
description: "One animated property's canonical, offset-sorted list of keyframe stops."
---

# AnimaKeyframeTrack

## Overview

One animated property's canonical, offset-sorted list of keyframe stops.

Never constructed by hand in ordinary authoring; [AnimaKeyframeMotion]
builds and owns these while parsing an authored keyframe declaration.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### property_path

The property this track animates, already resolved to its canonical path —
a semantic declaration like `opacity` resolves to `modulate:a` here.

### stops

This track's stops. Always kept sorted by [member AnimaKeyframeStop.offset]
after every merge, regardless of the order they were declared in.
