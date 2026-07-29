extends "res://addons/gut/test.gd"

func test_validate_fails_without_target_property():
	var motion := AnimaPropertyMotion.new()
	motion.to_value = 1.0
	motion.duration = 0.3

	assert_eq(motion.validate(), ["target_property is required"])

func test_validate_passes_with_target_property_end_value_and_duration():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("modulate:a")
	motion.to_value = 1.0
	motion.duration = 0.3

	assert_eq(motion.validate(), [])

func test_default_ease_is_linear():
	var motion := AnimaPropertyMotion.new()

	assert_eq(motion.ease.kind, AnimaEase.Kind.LINEAR)

func test_estimate_duration_returns_duration():
	var motion := AnimaPropertyMotion.new()
	motion.duration = 0.75

	var result := motion.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_eq(result.seconds, 0.75)
