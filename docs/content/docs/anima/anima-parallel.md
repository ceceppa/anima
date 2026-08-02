---
title: "AnimaParallel"
description: "Starts every enabled child in [member children] together; [member completion_policy]"
---

# AnimaParallel

## Overview

Starts every enabled child in [member children] together; [member completion_policy]
decides which child (or children) must finish for the group to complete.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### CompletionPolicy

Which child (or children) must finish for the group to complete.

## Properties and constants

### children

The motions to run together.

### completion_policy

The motions to run together.
Which child (or children) must finish for the group to complete.

### completion_child_name

The motions to run together.
Which child (or children) must finish for the group to complete.
The [member AnimaMotion.display_name] to match against when
[member completion_policy] is [constant CompletionPolicy.NAMED_CHILD].

## Methods

### get_completion_child

Returns the single child whose completion decides the group's completion
for FIRST_CHILD/NAMED_CHILD policies, or null for ALL_CHILDREN / no match.

### estimate_duration

Under [constant CompletionPolicy.ALL_CHILDREN], the slowest enabled child's
duration (worst-kind-wins across children first). Otherwise defers entirely
to [method get_completion_child]'s own duration.

### create_runtime

Builds the runtime instance that plays every enabled child together.

### validate

Validates every child recursively.
