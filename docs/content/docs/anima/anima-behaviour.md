---
title: "AnimaBehaviour"
description: "Per-node configuration resource, attached to an ordinary node via"
---

# AnimaBehaviour

## Overview

Per-node configuration resource, attached to an ordinary node via
[method Anima.attach_behaviour] — no node subclass required. A group played
against a node with reduced motion enabled starts its items together, without
sequential or staggered waiting.

## Availability

Godot 4.x and Anima 2.x.

## Quick example

See the class and member help in the Godot editor for a minimal, runnable example.

## Enumerations

### ReducedMotion

How reduced-motion preference is resolved for this behaviour.

## Properties and constants

### motion_id

Optional identity for this behaviour, independent of the node's own name.

### motion_in

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).

### motion_out

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).

### play_in_on_ready

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).

### hide_after_out

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).
Whether the node should hide after [member motion_out] finishes, once
something consumes it (reserved).

### default_duration

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).
Whether the node should hide after [member motion_out] finishes, once
something consumes it (reserved).
Default duration for motions authored against this behaviour, once
something consumes it (reserved).

### default_ease

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).
Whether the node should hide after [member motion_out] finishes, once
something consumes it (reserved).
Default duration for motions authored against this behaviour, once
something consumes it (reserved).
Default ease for motions authored against this behaviour, once something
consumes it (reserved). `null` falls back to linear.

### layout_transition_enabled

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).
Whether the node should hide after [member motion_out] finishes, once
something consumes it (reserved).
Default duration for motions authored against this behaviour, once
something consumes it (reserved).
Default ease for motions authored against this behaviour, once something
consumes it (reserved). `null` falls back to linear.
Whether layout-transition behaviour is enabled for this node, once that
feature exists (reserved).

### state_bindings

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).
Whether the node should hide after [member motion_out] finishes, once
something consumes it (reserved).
Default duration for motions authored against this behaviour, once
something consumes it (reserved).
Default ease for motions authored against this behaviour, once something
consumes it (reserved). `null` falls back to linear.
Whether layout-transition behaviour is enabled for this node, once that
feature exists (reserved).
Reserved slot for per-state (Idle/Hover/Pressed/etc.) motion bindings — no
runtime consumer yet. See "State bindings for common control states" in
the backlog for the feature that will actually use this field.

### reduced_motion

Optional identity for this behaviour, independent of the node's own name.
Motion to play when the node enters, once something consumes it (reserved).
Motion to play when the node exits, once something consumes it (reserved).
Whether [member motion_in] should auto-play on the node's `_ready()`, once
something consumes it (reserved).
Whether the node should hide after [member motion_out] finishes, once
something consumes it (reserved).
Default duration for motions authored against this behaviour, once
something consumes it (reserved).
Default ease for motions authored against this behaviour, once something
consumes it (reserved). `null` falls back to linear.
Whether layout-transition behaviour is enabled for this node, once that
feature exists (reserved).
Reserved slot for per-state (Idle/Hover/Pressed/etc.) motion bindings — no
runtime consumer yet. See "State bindings for common control states" in
the backlog for the feature that will actually use this field.
Reduced-motion preference for this behaviour. [constant ReducedMotion.ENABLED]
removes group sequencing and staggering when this node is the group's root;
[constant ReducedMotion.SYSTEM] and [constant ReducedMotion.DISABLED] retain
the authored group timing until a system-preference adapter is introduced.
