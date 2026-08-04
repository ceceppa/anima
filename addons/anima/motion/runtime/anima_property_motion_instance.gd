## Runtime instance for [AnimaPropertyMotion] — animates one property toward
## its target value each frame, via a normalized-time curve for most eases or
## a stateful physics simulation for [constant AnimaEase.Kind.SPRING].
class_name AnimaPropertyMotionInstance
extends AnimaMotionInstance

var _elapsed: float = 0.0
var _from_value: Variant = null
var _to_value: Variant = null
var _from_value_captured: bool = false
## The duration this run actually uses — [member AnimaPropertyMotion.duration]
## when explicitly positive, otherwise resolved once at capture time through
## the duration chain (see [method _resolve_duration]).
var _resolved_duration: float = 0.0

## Spring-only state ([constant AnimaEase.Kind.SPRING]) — a stateful
## simulation, not a `t`-normalized evaluate() like every other ease.
var _spring_value: float = 0.0
var _spring_velocity: float = 0.0
var _spring_target: float = 0.0
var _spring_initialized: bool = false

## Advances this motion by [param delta] seconds and writes the new value to
## [param target]. Returns `true` once finished.
func advance(target: Node, delta: float) -> bool:
	var property_motion := motion as AnimaPropertyMotion

	if not _from_value_captured:
		_from_value = property_motion.from_value
		if _from_value == null:
			_from_value = target.get_indexed(property_motion.target_property)
		_to_value = _from_value + property_motion.to_value if property_motion.is_relative else property_motion.to_value
		_from_value_captured = true
		_resolved_duration = _resolve_duration(target, property_motion)
		_apply_pivot(target, property_motion)

	if property_motion.ease.kind == AnimaEase.Kind.SPRING:
		return _advance_spring(target, property_motion, delta)

	_elapsed += delta * motion.speed
	var duration := _resolved_duration
	var t: float = 1.0 if duration <= 0.0 else clampf(_elapsed / duration, 0.0, 1.0)
	var eased_t := property_motion.ease.evaluate(t)

	target.set_indexed(property_motion.target_property, lerp(_from_value, _to_value, eased_t))

	return t >= 1.0 or is_equal_approx(t, 1.0)

## Resolves the duration this run actually uses: [member AnimaPropertyMotion.duration]
## when explicitly positive (an explicit `.with_duration()`/positional call
## always wins); otherwise the chain tech-spec.md §Target-bound authoring
## contract defines — [param target]'s attached [AnimaBehaviour.default_duration]
## when one is attached, else the project-level [member Anima.default_duration].
## Read live at capture time rather than authoring time, so a default changed
## after the motion was built but before it plays still applies.
func _resolve_duration(target: Node, property_motion: AnimaPropertyMotion) -> float:
	if property_motion.duration > 0.0:
		return property_motion.duration

	var behaviour := Anima.get_behaviour(target)
	if behaviour != null:
		return behaviour.default_duration
	return Anima.default_duration

## Normalized (x, y) position of each [enum AnimaPropertyMotion.Pivot] anchor
## within a target's own bounds — `(0, 0)` is the top-left corner, `(1, 1)`
## the bottom-right, matching Control.size / Sprite2D.texture-space.
const _PIVOT_ANCHORS := {
	AnimaPropertyMotion.Pivot.TOP_LEFT: Vector2(0.0, 0.0),
	AnimaPropertyMotion.Pivot.TOP_CENTER: Vector2(0.5, 0.0),
	AnimaPropertyMotion.Pivot.TOP_RIGHT: Vector2(1.0, 0.0),
	AnimaPropertyMotion.Pivot.CENTER_LEFT: Vector2(0.0, 0.5),
	AnimaPropertyMotion.Pivot.CENTER: Vector2(0.5, 0.5),
	AnimaPropertyMotion.Pivot.CENTER_RIGHT: Vector2(1.0, 0.5),
	AnimaPropertyMotion.Pivot.BOTTOM_LEFT: Vector2(0.0, 1.0),
	AnimaPropertyMotion.Pivot.BOTTOM_CENTER: Vector2(0.5, 1.0),
	AnimaPropertyMotion.Pivot.BOTTOM_RIGHT: Vector2(1.0, 1.0),
}

## Resolves and applies [member AnimaPropertyMotion.pivot] once, at the same
## point the start value is resolved (tech-spec.md §Motion pivot control).
## Only scale/rotation motions on a Control (native pivot_offset) or a 2D
## node exposing both offset and texture (Sprite2D-like) are affected;
## anything else is left untouched, same as an unsupported [member is_relative].
func _apply_pivot(target: Node, property_motion: AnimaPropertyMotion) -> void:
	if property_motion.pivot == AnimaPropertyMotion.Pivot.NONE:
		return
	var base_property := String(property_motion.target_property).split(":")[0]
	if base_property != "scale" and base_property != "rotation":
		return

	var anchor: Vector2 = _PIVOT_ANCHORS.get(property_motion.pivot, Vector2(0.5, 0.5))

	if target is Control:
		(target as Control).pivot_offset = anchor * (target as Control).size
	elif target is Node2D and _supports_offset_pivot(target):
		var texture: Texture2D = target.texture
		if texture == null:
			return
		var size: Vector2 = texture.get_size() * (target as Node2D).scale
		var delta: Vector2 = size * (Vector2(0.5, 0.5) - anchor)
		var basis_delta: Vector2 = (target as Node2D).global_transform.basis_xform(delta)
		target.offset += delta
		(target as Node2D).global_position -= basis_delta

## Whether [param target] exposes both `offset` and `texture` — the
## Sprite2D-like shape pivot uses to shift artwork instead of a native pivot.
func _supports_offset_pivot(target: Node) -> bool:
	var has_offset := false
	var has_texture := false
	for property in target.get_property_list():
		if property.name == "offset":
			has_offset = true
		elif property.name == "texture":
			has_texture = true
	return has_offset and has_texture

## Builds a new [AnimaPropertyMotion] that reverses this instance's actually
## resolved run — the captured start and effective end values swapped, so
## reverse playback returns to what was actually observed at start, even for
## a relative (`move_by`-style) motion. `null` before any value is captured.
func build_reversed() -> AnimaMotion:
	if not _from_value_captured:
		return null

	var property_motion := motion as AnimaPropertyMotion
	var reversed := AnimaPropertyMotion.new()
	reversed.target_property = property_motion.target_property
	reversed.from_value = _to_value
	reversed.to_value = _from_value
	reversed.duration = property_motion.duration
	reversed.ease = property_motion.ease
	reversed.speed = property_motion.speed
	reversed.delay = property_motion.delay
	reversed.delay_basis = property_motion.delay_basis
	reversed.on_started_callback = property_motion.on_started_callback
	reversed.on_completed_callback = property_motion.on_completed_callback
	return reversed

## Advances a SPRING-eased motion one physics step (semi-implicit Euler on a
## damped harmonic oscillator) instead of evaluating a normalized-time curve.
func _advance_spring(target: Node, property_motion: AnimaPropertyMotion, delta: float) -> bool:
	var easing := property_motion.ease

	if not _spring_initialized:
		_spring_value = float(_from_value)
		_spring_velocity = easing.spring_initial_velocity
		_spring_target = float(_to_value)
		_spring_initialized = true

	_elapsed += delta * motion.speed

	var stiffness_damping := easing.spring_stiffness_and_damping()
	var stiffness: float = stiffness_damping.x
	var damping: float = stiffness_damping.y
	var mass: float = maxf(easing.spring_mass, 0.001)

	var acceleration: float = (stiffness * (_spring_target - _spring_value) - damping * _spring_velocity) / mass
	_spring_velocity += acceleration * delta
	_spring_value += _spring_velocity * delta

	target.set_indexed(property_motion.target_property, _spring_value)

	return _spring_is_finished(easing)

## Redirects a still-moving spring to a new destination, preserving its
## current value/velocity instead of resetting them (see [method AnimaPlayback.retarget]).
## Restarts the elapsed clock so FIXED_PREVIEW_DURATION measures from the retarget point.
func retarget_spring(new_to_value: Variant) -> void:
	_spring_target = float(new_to_value)
	_elapsed = 0.0

func _spring_is_finished(easing: AnimaEase) -> bool:
	match easing.spring_completion_mode:
		AnimaEase.SpringCompletionMode.FIXED_PREVIEW_DURATION:
			return _elapsed >= easing.spring_preview_duration
		AnimaEase.SpringCompletionMode.MANUAL:
			return false
		AnimaEase.SpringCompletionMode.VISUALLY_SETTLED:
			return absf(_spring_target - _spring_value) < easing.spring_settle_distance * 10.0 \
				and absf(_spring_velocity) < easing.spring_settle_velocity * 10.0
		_: # STRICTLY_SETTLED
			return absf(_spring_target - _spring_value) < easing.spring_settle_distance \
				and absf(_spring_velocity) < easing.spring_settle_velocity
