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
