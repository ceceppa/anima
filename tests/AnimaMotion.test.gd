extends "res://addons/gut/test.gd"

func test_default_values():
	var motion := AnimaMotion.new()

	assert_eq(motion.display_name, "")
	assert_eq(motion.enabled, true)
	assert_eq(motion.delay, 0.0)
	assert_eq(motion.delay_basis, AnimaMotion.DelayBasis.AFTER_PREVIOUS_ENDS)
	assert_eq(motion.speed, 1.0)
	assert_eq(motion.tags, [])
	assert_eq(motion.metadata, {})
