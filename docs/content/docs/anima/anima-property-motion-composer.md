---
title: "AnimaPropertyMotionComposer"
description: "Edits one [AnimaPropertyMotion] inside the Motion Composer workspace."
---

# AnimaPropertyMotionComposer

## Overview

Edits one [AnimaPropertyMotion] inside the Motion Composer workspace.

Shows its semantic convenience name (when it was created through [method
Anima.on] or [method Anima.item] — see [member AnimaMotion.metadata]'s
`convenience_method`/`convenience_factory` keys) alongside the canonical
property path, target, values, timing, and easing it actually holds.
Editing here changes the same authored Resource code and playback read;
the panel is another view of that one Resource, never a second format
(`tech-spec.md` §Target-bound authoring contract).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### set_undo_redo

Connects this panel to Godot's editor undo and redo history.

### show_motion

Shows [param motion] and uses [param scene_node] (when present) as the
live target read for current values, the generic property search, and
validation feedback.
