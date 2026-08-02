---
title: "AnimaGroupCompiler"
description: "Checks whether an [AnimaGroupMotion] can compile into a native [Animation],"
---

# AnimaGroupCompiler

## Overview

Checks whether an [AnimaGroupMotion] can compile into a native [Animation],
and compiles an eligible one.

Editor/tooling code, not something runtime playback depends on — see
`project-rules.md` §Editor Boundaries. Compiling reuses the same
[AnimaTargetResolver] and [AnimaGroupScheduler] runtime playback itself
uses, so a compiled Animation's visible item starts always match what
[method Anima.play] would have produced.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Blocker

Why a group can't compile into a native [Animation] right now. [constant NONE]
means it's eligible.

## Properties and constants

### SAMPLES_PER_ITEM

How many samples each item's eased curve is baked into. Every [AnimaEase]
kind evaluates the same way here, so this works regardless of which curve
shape the item motion uses.

## Methods

### check_eligibility

Checks whether [param group] can compile into a native [Animation] against
[param root], without compiling it. Nothing here is cached, so calling
this again after changing [param group]'s configuration always reflects
its current eligibility.

### compile

Compiles [param group] into a native [Animation] against [param root],
whose visible item starts and durations match its authored playback,
ordering, and distribution. Only call this once [method check_eligibility]
reports [constant Blocker.NONE] for the same [param group] and [param
root] — behaviour is undefined otherwise.
