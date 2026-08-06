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
		_from_value = _resolve_dynamic(property_motion.from_value, target)
		if _from_value == null:
			_from_value = target.get_indexed(property_motion.target_property)
		var resolved_to: Variant = _resolve_dynamic(property_motion.to_value, target)
		_to_value = _from_value + resolved_to if property_motion.is_relative else resolved_to
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

## Resolves and applies [member AnimaPropertyMotion.pivot] once, at the same
## point the start value is resolved (tech-spec.md §Motion pivot control).
## Only a scale/rotation motion is gated here; the anchor math and
## Control/Sprite2D-like branching are the shared [method
## AnimaMotionInstance._apply_pivot_to] every caller uses.
func _apply_pivot(target: Node, property_motion: AnimaPropertyMotion) -> void:
	if property_motion.pivot == AnimaPropertyMotion.Pivot.NONE:
		return
	var base_property := String(property_motion.target_property).split(":")[0]
	if base_property != "scale" and base_property != "rotation":
		return
	_apply_pivot_to(target, property_motion.pivot)

## Builds a new [AnimaPropertyMotion] that reverses this instance's actually
## resolved run — the captured start and effective end values swapped, so
## reverse playback returns to what was actually observed at start, even for
## a relative (`move_by`-style) motion. `null` before any value is captured.
## The easing is mirrored ([method AnimaEase.mirrored]), not replayed as-is —
## an ease-in segment reversed should look like ease-out, the same rule
## keyframe reversal already applies.
func build_reversed() -> AnimaMotion:
	if not _from_value_captured:
		return null

	var property_motion := motion as AnimaPropertyMotion
	var reversed := AnimaPropertyMotion.new()
	reversed.target_property = property_motion.target_property
	reversed.from_value = _to_value
	reversed.to_value = _from_value
	reversed.duration = property_motion.duration
	reversed.ease = property_motion.ease.mirrored()
	reversed.speed = property_motion.speed
	reversed.forward_speed = property_motion.forward_speed
	reversed.reverse_speed = property_motion.reverse_speed
	reversed.delay = property_motion.delay
	reversed.delay_basis = property_motion.delay_basis
	reversed.on_started_callback = property_motion.on_started_callback
	reversed.on_completed_callback = property_motion.on_completed_callback
	return reversed

## Restores [param target]'s property to the value captured when this
## instance began advancing. A no-op if nothing has been captured yet.
func restore_initial(target: Node) -> void:
	if not _from_value_captured:
		return
	var property_motion := motion as AnimaPropertyMotion
	target.set_indexed(property_motion.target_property, _from_value)

## Applies this motion's authored end value to [param target] immediately —
## capturing a start value first (a zero-length advance) if nothing has been
## captured yet. A SPRING-eased motion is force-settled to its spring target
## instead, since it has no fixed to-value curve.
func force_complete(target: Node) -> void:
	if not _from_value_captured:
		advance(target, 0.0)

	var property_motion := motion as AnimaPropertyMotion
	if property_motion.ease.kind == AnimaEase.Kind.SPRING:
		_spring_value = _spring_target
		_spring_velocity = 0.0
		target.set_indexed(property_motion.target_property, _spring_value)
		return

	_elapsed = _resolved_duration
	target.set_indexed(property_motion.target_property, _to_value)

## Advances a SPRING-eased motion one physics step (semi-implicit Euler on a
## damped harmonic oscillator) instead of evaluating a normalized-time curve.
## Both the elapsed clock and the simulation step itself scale by [member
## AnimaMotion.speed] — previously only elapsed did, so speed/speed_scale
## changed when a spring was considered settled without changing how fast it
## visibly moved (tech-spec.md §Speed, direction, and reduced motion).
func _advance_spring(target: Node, property_motion: AnimaPropertyMotion, delta: float) -> bool:
	var easing := property_motion.ease
	var scaled_delta := delta * motion.speed

	if not _spring_initialized:
		_spring_value = float(_from_value)
		_spring_velocity = easing.spring_initial_velocity
		_spring_target = float(_to_value)
		_spring_initialized = true

	_elapsed += scaled_delta

	var stiffness_damping := easing.spring_stiffness_and_damping()
	var stiffness: float = stiffness_damping.x
	var damping: float = stiffness_damping.y
	var mass: float = maxf(easing.spring_mass, 0.001)

	var acceleration: float = (stiffness * (_spring_target - _spring_value) - damping * _spring_velocity) / mass
	_spring_velocity += acceleration * scaled_delta
	_spring_value += _spring_velocity * scaled_delta

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
