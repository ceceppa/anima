---
title: "AnimaRaceInstance"
description: "Runtime instance for [_AnimaRace] — advances every enabled child each frame"
---

# AnimaRaceInstance

## Overview

Runtime instance for [_AnimaRace] — advances every enabled child each frame
and completes as soon as the fastest one finishes.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Completes as soon as any child finishes. Once this returns true, the
caller stops calling advance() on this instance entirely — which is the
"cancel" for every other child: they simply never advance again.

### restore_initial

Restores every child's own captured initial value — see [method
AnimaMotionInstance.restore_initial].

### force_complete

Forces the first child to its final state — a race's own notion of
"complete" is having a winner, so completing early declares the first
child the winner and force-completes only it, leaving the rest untouched
the same way a natural race finish does. See [method
AnimaMotionInstance.force_complete].
