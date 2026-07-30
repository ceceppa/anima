extends "res://addons/gut/test.gd"

func test_to_builds_and_plays_a_property_motion_with_defaults():
	var node := Node2D.new()
	add_child_autofree(node)

	var playback := Anima.of(node).to(NodePath("position:x"), 100.0)
	var motion := playback.motion as AnimaPropertyMotion

	assert_not_null(motion)
	assert_eq(motion.target_property, NodePath("position:x"))
	assert_eq(motion.to_value, 100.0)
	assert_eq(motion.duration, AnimaNodeProxy.DEFAULT_DURATION)
	assert_eq(motion.ease.kind, AnimaEase.Kind.SINE)
	assert_eq(playback.target, node)

	playback.cancel() # no active playback lingers in the runtime singleton

func test_to_accepts_an_override_duration_and_ease():
	var node := Node2D.new()
	add_child_autofree(node)

	var custom_ease := AnimaEase.new()
	custom_ease.kind = AnimaEase.Kind.LINEAR

	var playback := Anima.of(node).to(NodePath("position:x"), 100.0, 0.75, custom_ease)
	var motion := playback.motion as AnimaPropertyMotion

	assert_eq(motion.duration, 0.75)
	assert_eq(motion.ease, custom_ease)

	playback.cancel()

func test_transition_to_builds_a_parallel_of_one_motion_per_property():
	var node := Node2D.new()
	add_child_autofree(node)

	var playback := Anima.of(node).transition_to({
		NodePath("position:x"): 100.0,
		NodePath("modulate:a"): 0.5,
	})
	var parallel := playback.motion as AnimaParallel

	assert_not_null(parallel)
	assert_eq(parallel.children.size(), 2)

	playback.cancel()

func test_enter_fades_in_from_zero_to_one():
	var node := Node2D.new()
	add_child_autofree(node)

	var playback := Anima.of(node).enter()
	var motion := playback.motion as AnimaPropertyMotion

	assert_eq(motion.target_property, NodePath("modulate:a"))
	assert_eq(motion.from_value, 0.0)
	assert_eq(motion.to_value, 1.0)

	playback.cancel()

func test_exit_fades_toward_zero():
	var node := Node2D.new()
	add_child_autofree(node)

	var playback := Anima.of(node).exit()
	var motion := playback.motion as AnimaPropertyMotion

	assert_eq(motion.target_property, NodePath("modulate:a"))
	assert_eq(motion.to_value, 0.0)

	playback.cancel()
