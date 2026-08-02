---
title: "AnimaComposerSession"
description: "Keeps one Motion Composer workspace focused on an authored motion graph."
---

# AnimaComposerSession

## Overview

Keeps one Motion Composer workspace focused on an authored motion graph.

A motion graph is one motion Resource and the child motions it contains.
The session remembers what an author is editing and which scene node gives
group previews their context; it never stores a second copy of that motion.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### View

Chooses whether the workspace is editing settings or showing inspection.

## Properties and constants

### root_motion

The motion Resource that was opened in this workspace.

### selected_motion

The motion currently shown in the workspace.

### selected_scene_node

The scene node used to resolve group targets and run previews.

### active_view

The workspace view currently shown to the author.

## Methods

### open_motion

Opens [param motion] as this workspace's resource graph.

The root and selected motion initially refer to the same authored Resource.
Any prior selection and preview context belongs to the previous workspace and
is cleared.

### select_motion

Selects [param motion] when it belongs to the open motion graph.

Returns `true` after changing the editing context. A motion outside the
graph is ignored so the workspace never starts editing a different asset.

### select_scene_node

Sets [param node] as the scene context for resolving and previewing groups.

Passing `null` keeps the resource editable but clears the context that a
group needs to find its target nodes.

### has_scene_node_context

Returns whether this workspace has a usable scene node for group actions.

### scene_node_context_message

Explains why resolution and preview are unavailable when no node is selected.

### graph_motions

Returns every motion in the opened graph, with the root first.

The order follows the Resource properties that hold child motions. Each
Resource appears once even when more than one parent property references it.
