---
title: "AnimaTargetCollection"
description: "Names the source a group will later resolve into animation targets."
---

# AnimaTargetCollection

## Overview

Names the source a group will later resolve into animation targets.

A target is a Godot node that visibly changes. This resource stores the
author’s choice; resolving the actual nodes belongs to group playback.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Kind

The supported ways an author can supply nodes to a group.

### Filter

Limits a collection to alternating zero-based positions before it is ordered.

`ODD_ONLY` keeps positions `1`, `3`, and so on. `EVEN_ONLY` keeps positions
`0`, `2`, and so on. Choose [constant Filter.NONE] to keep every target.

## Properties and constants

### kind

The source used to find the group’s target nodes.

### reference_data

References used by the selected source.

For [constant Kind.EXPLICIT], add nodes or paths relative to the supplied
root node. For [constant Kind.SCENE_GROUP], add the names of Godot scene
groups. Runtime-supplied collections receive their nodes from code instead.

### filter

Chooses whether every target or only alternating zero-based positions play.

Filtering happens before a group chooses its animation order, so these
positions always refer to the visible collection order.

### resolve_on_play

Whether targets are chosen when the group begins playing.

Keep this enabled when a scene can add or remove nodes before the animation
starts. Disable it only when later playback code supplies a fixed snapshot.
