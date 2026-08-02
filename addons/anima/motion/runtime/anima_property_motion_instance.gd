## Runtime instance for [AnimaPropertyMotion] — animates one property toward
## its target value each frame, via a normalized-time curve for most eases or
## a stateful physics simulation for [constant AnimaEase.Kind.SPRING].
class_name AnimaPropertyMotionInstance
extends AnimaMotionInstance

var _elapsed: float = 0.0
var _from_value: Variant = null
var _from_value_captured: bool = false

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
		_from_value_captured = true

	if property_motion.ease.kind == AnimaEase.Kind.SPRING:
		return _advance_spring(target, property_motion, delta)

	_elapsed += delta * motion.speed
	var duration := property_motion.duration
	var t: float = 1.0 if duration <= 0.0 else clampf(_elapsed / duration, 0.0, 1.0)
	var eased_t := property_motion.ease.evaluate(t)

	target.set_indexed(property_motion.target_property, lerp(_from_value, property_motion.to_value, eased_t))

	return t >= 1.0 or is_equal_approx(t, 1.0)

## Advances a SPRING-eased motion one physics step (semi-implicit Euler on a
## damped harmonic oscillator) instead of evaluating a normalized-time curve.
func _advance_spring(target: Node, property_motion: AnimaPropertyMotion, delta: float) -> bool:
	var easing := property_motion.ease

	if not _spring_initialized:
		_spring_value = float(_from_value)
		_spring_velocity = easing.spring_initial_velocity
		_spring_target = float(property_motion.to_value)
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
