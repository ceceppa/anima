---
title: "AnimaMotionInstance"
description: "Base runtime instance every [AnimaMotion] subtype's [method AnimaMotion.create_runtime]"
---

# AnimaMotionInstance

## Overview

Base runtime instance every [AnimaMotion] subtype's [method AnimaMotion.create_runtime]
returns. [method advance] is the shared per-frame contract every subtype implements.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Properties and constants

### motion

The motion resource this instance is advancing.

## Methods

### advance

Advances playback by delta seconds and applies the motion's effect to target.
Returns true once the motion has finished.
