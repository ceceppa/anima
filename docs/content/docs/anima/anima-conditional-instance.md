---
title: "AnimaConditionalInstance"
description: "Runtime instance for [AnimaConditional] — selects a branch once at"
---

# AnimaConditionalInstance

## Overview

Runtime instance for [AnimaConditional] — selects a branch once at
construction and advances only that branch's own runtime instance.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Advances the branch selected at construction. Completes immediately if
`condition` had no valid branch to select.

### restore_initial

Restores the selected branch's own captured initial value — see [method
AnimaMotionInstance.restore_initial].

### force_complete

Forces the selected branch to its final state — see [method
AnimaMotionInstance.force_complete].
