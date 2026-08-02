---
title: "AnimaStaggerInstance"
description: "Runtime instance for [AnimaStagger] — advances one [member AnimaStagger.template]"
---

# AnimaStaggerInstance

## Overview

Runtime instance for [AnimaStagger] — advances one [member AnimaStagger.template]
instance per target, started per the resolved stagger order.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### advance

Ignores the target this instance's own advance() receives — each entry
drives its own target from `targets`, per AnimaStagger's contract.
