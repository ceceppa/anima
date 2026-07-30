extends "res://addons/gut/test.gd"

func test_defaults():
	var behaviour := AnimaBehaviour.new()

	assert_eq(behaviour.motion_id, "")
	assert_null(behaviour.motion_in)
	assert_null(behaviour.motion_out)
	assert_false(behaviour.play_in_on_ready)
	assert_false(behaviour.hide_after_out)
	assert_eq(behaviour.default_duration, 0.3)
	assert_null(behaviour.default_ease)
	assert_false(behaviour.layout_transition_enabled)
	assert_eq(behaviour.state_bindings, {})
	assert_eq(behaviour.reduced_motion, AnimaBehaviour.ReducedMotion.SYSTEM)
