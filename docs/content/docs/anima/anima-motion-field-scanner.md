---
title: "AnimaMotionFieldScanner"
description: "Finds which of an object's exported properties are typed as [AnimaMotion]"
---

# AnimaMotionFieldScanner

## Overview

Finds which of an object's exported properties are typed as [AnimaMotion]
(or a subtype) — the detection [AnimaMotionInspectorPlugin] uses to decide
whether an ordinary node gets an "Anima" Inspector entry point
(`tech-spec.md` §Motion Composer entry point). A plain `RefCounted`
helper, not an `EditorInspectorPlugin`, so it can be exercised directly
outside a real editor session.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### motion_fields

Names of [param object]'s exported properties typed as [AnimaMotion] or a subtype.
