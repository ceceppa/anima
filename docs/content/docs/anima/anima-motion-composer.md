---
title: "AnimaMotionComposer"
description: "Shows one authored motion graph in the Motion Composer bottom panel."
---

# AnimaMotionComposer

## Overview

Shows one authored motion graph in the Motion Composer bottom panel.

The panel lets an author move between motions and see whether a selected
scene node can provide group targets. It is an editor view of the original
Resource, not a separate motion format.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### session

The transient selection and scene-node context for this open workspace.

## Methods

### set_undo_redo

Connects child editor surfaces to Godot's undo and redo history.

### open_motion

Opens [param motion] and shows it as the root of this workspace.

### select_motion

Selects [param motion] in the open graph and refreshes the visible context.

### select_scene_node

Sets [param node] as the current scene-node context for group actions.

### selected_motion

Returns the authored motion currently selected in this workspace.

### has_scene_node_context

Returns whether a selected scene node can supply group target context.

### scene_node_context_message

Returns the author-facing explanation of the current scene-node context.

### workspace_status_message

Returns the workspace's own top status line — the next-step message shown
when nothing has been opened yet (`project-rules.md` §Editor Boundaries).
