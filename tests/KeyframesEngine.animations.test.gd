extends "res://addons/gut/test.gd"

func test_bounce_animation():
	var frames = AnimaAnimationsUtils.get_animation_keyframes("bounce")
	var node := Label.new()

	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 5 },
		frames
	)

	assert_eq_deep(output, [
		{_wait_time=1.0, duration=1.0, easing=[0.215, 0.61, 0.355, 1], from=0, node=node, property="position:y", relative=true, to=-30},
		{_wait_time=1.0, duration=1.0, easing=[0.215, 0.61, 0.355, 1], from=1.0, node=node, property="scale:y", to=1.1},
		{_wait_time=2.15, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=-30, node=node, property="position:y", relative=true, to=0},
		{_wait_time=2.15, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=1.1, node=node, property="scale:y", to=1.0},
		{_wait_time=2.65, duration=0.85, easing=[0.215, 0.61, 0.355, 1], from=0, node=node, property="position:y", relative=true, to=-15},
		{_wait_time=2.65, duration=0.85, easing=[0.215, 0.61, 0.355, 1], from=1.0, node=node, property="scale:y", to=1.05},
		{_wait_time=3.5, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=-15, node=node, property="position:y", relative=true, to=0},
		{_wait_time=3.5, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=1.05, node=node, property="scale:y", to=0.95},
		{_wait_time=4.0, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=0, node=node, property="position:y", relative=true, to=-4},
		{_wait_time=4.0, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=0.95, node=node, property="scale:y", to=1.02},
		{_wait_time=4.5, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=-4, node=node, property="position:y", relative=true, to=0},
		{_wait_time=4.5, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=1.02, node=node, property="scale:y", to=1.0}

	])

	node.free()
