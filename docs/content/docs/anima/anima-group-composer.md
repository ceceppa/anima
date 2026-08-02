---
title: "AnimaGroupComposer"
description: "Edits one [AnimaGroupMotion] inside the Motion Composer workspace."
---

# AnimaGroupComposer

## Overview

Edits one [AnimaGroupMotion] inside the Motion Composer workspace.

It changes the authored Resource directly, so a group configured here is the
same group played by code. Preview controls use the workspace's selected
scene node and never create a second schedule or motion format.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### set_undo_redo

Connects this setup surface to Godot's editor undo and redo history.

### show_motion

Shows [param motion] when it is a group, or offers group creation for a compatible parent.

### add_group

Adds a new group to [param parent] and returns it, or returns `null` when the parent cannot contain children.

### can_add_group

Returns whether [param motion] is a composite parent that can contain a group.

### set_group_property

Changes one authored group setting through the Composer's undo-aware edit path.

Returns `false` when no group is selected. This is used by the setup controls
so edits made in the panel change the same Resource code later plays.

### preview_forward

Starts a forward preview when the selected group has a usable scene-node context.

### stop_preview

Stops the current preview without changing the authored group.

### preview_reverse

Reverses the current group preview after it has started forward.
