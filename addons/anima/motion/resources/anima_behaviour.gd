## Per-node configuration resource, attached to an ordinary node via
## [method Anima.attach_behaviour] — no node subclass required. A group played
## against a node with reduced motion enabled starts its items together, without
## sequential or staggered waiting.
class_name AnimaBehaviour
extends Resource

## How reduced-motion preference is resolved for this behaviour.
enum ReducedMotion {
	SYSTEM,
	ENABLED,
	DISABLED,
}

## Optional identity for this behaviour, independent of the node's own name.
@export var motion_id: String = ""
## Motion to play when the node enters, once something consumes it (reserved).
@export var motion_in: AnimaMotion = null
## Motion to play when the node exits, once something consumes it (reserved).
@export var motion_out: AnimaMotion = null
## Whether [member motion_in] should auto-play on the node's `_ready()`, once
## something consumes it (reserved).
@export var play_in_on_ready: bool = false
## Whether the node should hide after [member motion_out] finishes, once
## something consumes it (reserved).
@export var hide_after_out: bool = false
## Default duration for motions authored against this behaviour, once
## something consumes it (reserved).
@export var default_duration: float = 0.3
## Default ease for motions authored against this behaviour, once something
## consumes it (reserved). `null` falls back to linear.
@export var default_ease: AnimaEase = null
## Whether layout-transition behaviour is enabled for this node, once that
## feature exists (reserved).
@export var layout_transition_enabled: bool = false
## Reserved slot for per-state (Idle/Hover/Pressed/etc.) motion bindings — no
## runtime consumer yet. See "State bindings for common control states" in
## the backlog for the feature that will actually use this field.
@export var state_bindings: Dictionary = {}
## Reduced-motion preference for this behaviour. [constant ReducedMotion.ENABLED]
## removes group sequencing and staggering when this node is the group's root;
## [constant ReducedMotion.SYSTEM] and [constant ReducedMotion.DISABLED] retain
## the authored group timing until a system-preference adapter is introduced.
@export var reduced_motion: ReducedMotion = ReducedMotion.SYSTEM
