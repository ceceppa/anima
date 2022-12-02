extends "res://addons/gut/test.gd"

func test_bounce_animation():
	var frames = AnimaAnimationsUtils.get_animation_keyframes("bounce")
	var node := Label.new()

	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 5 },
		frames
	)

	assert_eq_deep(output, [
		{_wait_time=1.0, duration=1.0, easing=[0.215, 0.61, 0.355, 1], from=0, node=node, property="position:y", relative=true, _is_translation=true, to=-30},
		{_wait_time=1.0, duration=1.0, easing=[0.215, 0.61, 0.355, 1], from=1.0, node=node, property="scale:y", to=1.1},
		{_wait_time=2.15, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=-30, node=node, property="position:y", relative=true, _is_translation=true, to=0},
		{_wait_time=2.15, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=1.1, node=node, property="scale:y", to=1.0},
		{_wait_time=2.65, duration=0.85, easing=[0.215, 0.61, 0.355, 1], from=0, node=node, property="position:y", relative=true, _is_translation=true, to=-15},
		{_wait_time=2.65, duration=0.85, easing=[0.215, 0.61, 0.355, 1], from=1.0, node=node, property="scale:y", to=1.05},
		{_wait_time=3.5, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=-15, node=node, property="position:y", relative=true, _is_translation=true, to=0},
		{_wait_time=3.5, duration=0.5, easing=[0.755, 0.05, 0.855, 0.06], from=1.05, node=node, property="scale:y", to=0.95},
		{_wait_time=4.0, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=0, node=node, property="position:y", relative=true, _is_translation=true, to=-4},
		{_wait_time=4.0, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=0.95, node=node, property="scale:y", to=1.02},
		{_wait_time=4.5, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=-4, node=node, property="position:y", relative=true, _is_translation=true, to=0},
		{_wait_time=4.5, duration=0.5, easing=[0.215, 0.61, 0.355, 1], from=1.02, node=node, property="scale:y", to=1.0}

	])

	node.free()

func test_3d_boxes():
	var frames = load("res://demos/3d/3DBoxes.gd").new()
	var box_scene = load("res://tests/Box.tscn").instance()

	add_child(box_scene)

	var output = AnimaKeyframesEngine.parse_frames(
		{ node = box_scene, duration = 5 },
		frames._boxes_animation()
	)

	assert_eq_deep(output, [
		{ node = box_scene, _wait_time = 0.0, duration = 1.75, property ="x", from = null, to = -28.117, relative = true, easing = ANIMA.EASING.EASE_OUT_QUAD },
		{ node = box_scene, _wait_time = 0.0, duration = 5.0, property ="rotation:x", from = null, to = 360, relative = true, easing = ANIMA.EASING.EASE_IN_CIRC },
		{ node = box_scene, _wait_time = 1.5, duration = 0.25, property ="shader_param:albedo", from = Color('#6b9eb1'), to = Color('#e63946'), initial_value = Color('#6b9eb1'), easing = ANIMA.EASING.EASE_OUT_QUAD },
		{ node = box_scene, _wait_time = 2.0, duration = 3.0, property ="shader_param:albedo", from = Color('#e63946'), to =  Color('#6b9eb1'), easing = ANIMA.EASING.EASE_IN_CIRC },
		{ node = box_scene, _wait_time = 3.25, duration = 1.75, property ="x", from = -28.117, to =  -25.619, relative = true, easing = ANIMA.EASING.EASE_IN_CIRC },
		{ node = box_scene, _wait_time = 3.25, duration = 1.0, property ="scale", from = Vector3(0.1, 1, 1), to = Vector3.ZERO, initial_value = Vector3(0.1, 1, 1) },
	])

	box_scene.free()
	frames.free()
