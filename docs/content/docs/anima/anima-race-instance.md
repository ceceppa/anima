---
title: "AnimaRaceInstance"
description: "Runtime instance for [AnimaRace] — advances every enabled child each frame"
---

# AnimaRaceInstance

## Overview

Runtime instance for [AnimaRace] — advances every enabled child each frame
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
