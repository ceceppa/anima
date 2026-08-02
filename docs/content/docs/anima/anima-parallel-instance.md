---
title: "AnimaParallelInstance"
description: "Runtime instance for [AnimaParallel] — advances every enabled child each"
---

# AnimaParallelInstance

## Overview

Runtime instance for [AnimaParallel] — advances every enabled child each
frame and completes per its [member AnimaParallel.completion_policy].

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Advances every unfinished child, then completes per completion_policy —
all of them, or just the one tracked at [member _completion_index].

### build_reversed

Builds a reversed [AnimaParallel]: every child that captured a start value
gets its own reversed motion, still played together. `null` when no child
has captured one yet.
