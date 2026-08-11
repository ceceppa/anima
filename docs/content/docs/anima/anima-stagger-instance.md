---
title: "AnimaStaggerInstance"
description: "Runtime instance for [_AnimaStagger] — advances one [member _AnimaStagger.template]"
---

# AnimaStaggerInstance

## Overview

Runtime instance for [_AnimaStagger] — advances one [member _AnimaStagger.template]
instance per target, started per the resolved stagger order.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Ignores the target this instance's own advance() receives — each entry
drives its own target from `targets`, per _AnimaStagger's contract.

### restore_initial

Restores every started entry's own captured initial value on its own
target — [param _target] is ignored, the same way [method advance]'s is.

### force_complete

Forces every entry to its own final state on its own target, starting any
that have not begun yet.
