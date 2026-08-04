---
title: "AnimaSequenceInstance"
description: "Runtime instance for [AnimaSequence] — advances each child per its"
---

# AnimaSequenceInstance

## Overview

Runtime instance for [AnimaSequence] — advances each child per its
scheduled start ([method AnimaSequence.compute_schedule]) and completes
once every enabled child has finished.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Children are scheduled by delay/delay_basis (AnimaSequence.compute_schedule())
rather than strictly starting one after another finishes, so more than one
child can be active at once when a negative delay overlaps them.

### restore_initial

Restores every started child's own captured initial value (see [method
AnimaMotionInstance.restore_initial]). A child that never started has
nothing to restore.

### force_complete

Forces every child to its own final state, starting any that have not
begun yet (so a sequence completes end-to-end, not just its started
prefix) — see [method AnimaMotionInstance.force_complete].

### build_reversed

Builds a reversed [AnimaSequence]: each started child's own reversed
motion, in reverse start order, keeping each child's own delay/delay_basis.
`null` when no child has started yet.
