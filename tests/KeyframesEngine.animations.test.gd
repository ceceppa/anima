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
	var frames := {
		from = {
			scale = Vector3(0.1, 1, 1),
			"shader_param:albedo": Color('#6b9eb1'),
		},
		30: {
			"shader_param:albedo": Color('#e63946')
		},
		35: {
			"+x": -28.117,
			easing = ANIMA.EASING.EASE_OUT_QUAD,
		},
		40: {
			"+x": 0,
			"shader_param:albedo": Color('#e63946')
		},
		65: {
			"+x": 0,
			scale = Vector3(0.1, 1, 1)
		},
		85: {
			scale = Vector3.ZERO,
		},
		to = {
			"+x": -25.619,
			easing = ANIMA.EASING.EASE_IN_CIRC,
			"+rotation:x": 360,
			"shader_param:albedo": Color('#6b9eb1')
		},
	}

	var box_scene = load("res://tests/Box.tscn").instance()

	add_child(box_scene)

	var output = AnimaKeyframesEngine.parse_frames(
		{ node = box_scene, duration = 5 },
		frames
	)

	assert_eq_deep(output, [
		{ node = box_scene, _wait_time = 0.0, duration = 1.5, property ="shader_param:albedo", from = Color('#6b9eb1'), to = Color('#e63946') },
		{ node = box_scene, _wait_time = 0.0, duration = 5.0, property ="rotation:x", from = null, to = 360, relative = true, easing = ANIMA.EASING.EASE_IN_CUBIC },
#		{ node = box_scene, _wait_time = 0.0, duration = 1.75, property ="x", from = null, to = -28.117, relative = true },
#		{ _wait_time = 4.25, duration = 1.25, property = "scale", from = Vector2(0.1, 0.1), to = Vector2.ZERO, initial_value = Vector2(0.1, 0.1) },
	])

	box_scene.free()
