---
title: "AnimaTargetReference"
description: "Stores a target in a way an authored motion can safely find again."
---

# AnimaTargetReference

## Overview

Stores a target in a way an authored motion can safely find again.

A target is the Godot node that visibly changes during a motion. Use a
scene-relative path before saving an authored motion. A direct node is only
for immediate playback because it cannot be stored in a reusable resource.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### ResolutionMode

How this reference finds its target when a motion begins.

## Properties and constants

### resolution_mode

The way this target is resolved. New references use the portable
[constant ResolutionMode.PLAYBACK_CONTEXT] mode by default.

### scene_relative_path

The path from a supplied scene root to the target for
[constant ResolutionMode.SCENE_RELATIVE].

## Methods

### set_scene_relative

Creates a portable reference to [param target] below [param scene_root].
Returns an error when the target is not part of that scene tree.

### set_live_target

Uses [param target] for immediate playback. Call [method set_scene_relative]
before saving the resource so a reopened motion can find its target again.

### resolve

Resolves this reference using [param scene_root] or [param playback_target].
Returns `null` when the required node is unavailable.

### serialization_error

Returns a clear message when this reference cannot safely be serialized,
or an empty string when it is portable.
