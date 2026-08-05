extends "res://addons/gut/test.gd"

func test_two_stop_track_animates_from_first_to_second_value():
	var motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var instance: AnimaKeyframeMotionInstance = motion.create_runtime()

	instance.advance(node, 0.5)
	assert_almost_eq(node.position.x, 50.0, 0.01)

	var finished: bool = instance.advance(node, 0.5)
	assert_true(finished)
	assert_almost_eq(node.position.x, 100.0, 0.01)

func test_mid_point_stop_is_visibly_passed_through():
	var motion := Motion.keyframes({
		"from": {"position:x": 0.0},
		50: {"position:x": 100.0},
		"to": {"position:x": 0.0},
	})
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var instance: AnimaKeyframeMotionInstance = motion.create_runtime()

	instance.advance(node, 0.5)
	assert_almost_eq(node.position.x, 100.0, 0.01, "at the mid-point offset the track should reach its mid-point value")

	instance.advance(node, 0.5)
	assert_almost_eq(node.position.x, 0.0, 0.01)

func test_multiple_properties_animate_together():
	var motion := Motion.keyframes({
		"from": {"opacity": 0.0, "scale": Vector2(0.5, 0.5)},
		"to": {"opacity": 1.0, "scale": Vector2.ONE},
	})
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var instance: AnimaKeyframeMotionInstance = motion.create_runtime()
	instance.advance(node, 1.0)

	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.scale.x, 1.0, 0.01)

func test_single_stop_track_holds_its_value_for_the_whole_motion():
	var motion := Motion.keyframes({50: {"position:x": 42.0}})
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var instance: AnimaKeyframeMotionInstance = motion.create_runtime()

	instance.advance(node, 0.1)
	assert_almost_eq(node.position.x, 42.0, 0.01)
	instance.advance(node, 0.9)
	assert_almost_eq(node.position.x, 42.0, 0.01)

func test_per_segment_easing_is_respected():
	var ease_in := AnimaEase.new()
	ease_in.kind = AnimaEase.Kind.EASE_IN

	var eased_motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0, "_ease": ease_in}})
	eased_motion.duration = 1.0
	var linear_motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	linear_motion.duration = 1.0

	var eased_node := Node2D.new()
	autofree(eased_node)
	var linear_node := Node2D.new()
	autofree(linear_node)

	eased_motion.create_runtime().advance(eased_node, 0.5)
	linear_motion.create_runtime().advance(linear_node, 0.5)

	assert_lt(eased_node.position.x, linear_node.position.x, "an EASE_IN segment should lag behind a linear one at the midpoint")

func test_speed_scales_how_fast_a_keyframe_motion_plays():
	var motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	motion.duration = 1.0
	motion.speed = 2.0

	var node := Node2D.new()
	autofree(node)
	var instance: AnimaKeyframeMotionInstance = motion.create_runtime()
	instance.advance(node, 0.25)

	assert_almost_eq(node.position.x, 50.0, 0.01, "2x speed should cover twice the progress for the same delta")

func test_reduced_motion_and_direction_speed_reach_keyframes_through_playback():
	var motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	motion.duration = 1.0
	motion.forward_speed = 4.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.05)

	assert_gt(node.position.x, 15.0, "forward_speed should reach AnimaKeyframeMotionInstance the same way it reaches every other leaf")
	playback.cancel()

func test_build_reversed_flips_offsets_and_shifts_easing_ownership():
	var ease_in := AnimaEase.new()
	ease_in.kind = AnimaEase.Kind.EASE_IN

	var motion := Motion.keyframes({
		"from": {"position:x": 0.0},
		50: {"position:x": 100.0, "_ease": ease_in},
		"to": {"position:x": 200.0},
	})
	motion.duration = 1.0

	var instance: AnimaKeyframeMotionInstance = motion.create_runtime()
	var reversed := instance.build_reversed() as AnimaKeyframeMotion
	var stops := reversed.tracks[0].stops

	assert_eq(stops.size(), 3)
	assert_almost_eq(stops[0].offset, 0.0, 0.0001)
	assert_almost_eq(stops[0].value, 200.0, 0.0001)
	assert_null(stops[0].ease, "the new first stop has nothing arriving at it")

	assert_almost_eq(stops[1].offset, 0.5, 0.0001)
	assert_almost_eq(stops[1].value, 100.0, 0.0001)
	assert_eq(stops[1].ease.kind, motion.default_ease.mirrored().kind, "this segment's easing came from the original last stop's default_ease, mirrored")

	assert_almost_eq(stops[2].offset, 1.0, 0.0001)
	assert_almost_eq(stops[2].value, 0.0, 0.0001)
	assert_eq(stops[2].ease.kind, AnimaEase.Kind.EASE_OUT, "EASE_IN reversed should mirror to EASE_OUT, not replay the same shape backward")

func test_reversing_a_keyframe_motion_plays_it_backward():
	var motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.5)
	assert_almost_eq(node.position.x, 50.0, 1.0)

	assert_true(playback.reverse(), "reversing a keyframe motion should succeed even before any frame played, since nothing needs to be captured first")
	for i in range(10):
		playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 0.0, 0.01, "a fully reversed keyframe motion should end back at its starting value")

func test_reversing_before_any_frame_played_still_succeeds():
	var motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)

	assert_true(playback.reverse(), "backward playback for keyframe motions must not silently fail — everything a keyframe needs is already in its authored tracks")
	playback.cancel()

func test_integration_through_anima_play():
	var node := Node2D.new()
	autofree(node)
	var motion := Motion.keyframes({"from": {"position:x": 0.0}, "to": {"position:x": 100.0}})
	motion.duration = 0.1

	var playback := Anima.play(motion, node)
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 100.0, 0.01)
