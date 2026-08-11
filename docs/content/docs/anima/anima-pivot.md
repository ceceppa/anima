---
title: "AnimaPivot"
description: "Namespace for [enum Kind] — the anchor positions a scale or rotation motion"
---

# AnimaPivot

## Overview

Namespace for [enum Kind] — the anchor positions a scale or rotation motion
can transform around, instead of the target's default origin
(`tech-spec.md` §Motion pivot control). A lightweight, non-[Resource]
helper — like [Motion]/[AnimaEase] — that exists only to hold this enum
under its own name, since a pivot value is shared by [AnimaPropertyMotion]
and [AnimaKeyframeMotion]/[AnimaKeyframeStop] and no longer belongs to
either one specifically (`project-rules.md` §Folder Structure).

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### Kind

Restored Anima v1 anchor positions a scale or rotation motion can
transform around, instead of the target's default origin. Only takes
effect when the motion's canonical property is
`scale`/`scale:x`/`scale:y` or `rotation` — see [member AnimaPropertyMotion.pivot]
(`tech-spec.md` §Motion pivot control).
