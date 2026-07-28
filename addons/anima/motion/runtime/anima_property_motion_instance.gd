class_name AnimaPropertyMotionInstance
extends AnimaMotionInstance

var _elapsed: float = 0.0
var _from_value: Variant = null
var _from_value_captured: bool = false

func advance(target: Node, delta: float) -> bool:
	var property_motion := motion as AnimaPropertyMotion

	if not _from_value_captured:
		_from_value = property_motion.from_value
		if _from_value == null:
			_from_value = target.get_indexed(property_motion.target_property)
		_from_value_captured = true

	_elapsed += delta * motion.speed
	var duration := property_motion.duration
	var t: float = 1.0 if duration <= 0.0 else clampf(_elapsed / duration, 0.0, 1.0)
	var eased_t := property_motion.ease.evaluate(t)

	target.set_indexed(property_motion.target_property, lerp(_from_value, property_motion.to_value, eased_t))

	return t >= 1.0 or is_equal_approx(t, 1.0)
