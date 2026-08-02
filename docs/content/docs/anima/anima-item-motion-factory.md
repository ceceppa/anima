---
title: "AnimaItemMotionFactory"
description: "Returned by [method Anima.item] — builds a canonical [AnimaPropertyMotion]"
---

# AnimaItemMotionFactory

## Overview

Returned by [method Anima.item] — builds a canonical [AnimaPropertyMotion]
for a common per-item change, through the same named methods
[AnimaOnMotionFactory] exposes. Unlike [method Anima.on], no target is
known yet: an [AnimaGroupMotion] resolves and supplies each item's own
target when it plays this motion as its [member AnimaGroupMotion.item_motion]
— every resolved target gets its own runtime instance and its own
captured start value, the same way any other item motion does
(`tech-spec.md` §Target-bound authoring contract). Because no target is
known at creation, these methods build unconditionally instead of
validating a target class up front; an item whose resolved target can't
use the motion falls back to [member AnimaGroupMotion.invalid_target_policy]
like any other invalid group item.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### position

Animates each resolved item's position to [param to].

### move_by

Moves each resolved item by [param delta] from wherever it actually is.

### position_x

Animates just the x component of each resolved item's position.

### position_y

Animates just the y component of each resolved item's position.

### position_z

Animates just the z component of each resolved item's position (3D items only).

### scale

Animates each resolved item's scale to [param to].

### scale_by

Scales each resolved item by [param delta] from its actual current scale.

### rotation

Animates each resolved item's rotation (radians) to [param to].

### rotate_by

Rotates each resolved item by [param delta] radians from its actual current rotation.

### opacity

Fades each resolved item's opacity ([code]modulate:a[/code]) to [param to].
A value outside `0.0..1.0` is allowed and produces an editor warning,
never a clamp or a rejection.

### color

Animates each resolved item's colour ([code]modulate[/code]) to [param to].

### size

Animates each resolved item's size to [param to] (Control items only).

### property

Generic escape hatch for any other property. Delegates directly to
[method Motion.to] — the same canonical resource direct authoring would
build.
