---
title: "AnimaAnimationRegistry"
description: "Backs [method Anima.animation] — a name-to-path lookup for the ported v1"
---

# AnimaAnimationRegistry

## Overview

Backs [method Anima.animation] — a name-to-path lookup for the ported v1
animation catalog (`tech-spec.md` §Animation catalog). Each entry's `.tres`
is loaded once and cached, so every later request for the same name
returns the identical [AnimaMotion] instance — the same object a user gets
by referencing the `.tres` directly, per this phase's "reachable two ways"
contract. Internal to [Anima]; not part of the public authoring surface.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Methods

### get_animation

Returns the cached, shared [AnimaMotion] for [param name], loading it from
its `.tres` on first request. `null` and an error for an unregistered name
(`tech-spec.md` §Animation catalog).
