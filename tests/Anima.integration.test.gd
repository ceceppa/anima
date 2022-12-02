extends "res://addons/gut/test.gd"

func test_simple_animation():
	var node := Control.new()

	add_child(node)

	var anima = Anima.begin_single_shot(self) \
		.with(
			Anima.Node(node) \
				.anima_animation_frames({
					from = {
						scale = Vector2.ZERO,
					},
					to = {
						scale = Vector2(10, 10)
					}
				}, 0.3)
		) \
		.play()

	yield(anima, "animation_completed")

	assert_eq(node.rect_scale, Vector2(10, 10))

	yield(get_tree(), "idle_frame")

	assert_false(is_instance_valid(anima))

	node.free()

func test_simple_relative_animation():
	var node := Control.new()

	node.set_position(Vector2(42, 42))

	add_child(node)

	var anima = Anima.begin_single_shot(self) \
		.with(
			Anima.Node(node) \
				.anima_animation_frames({
					to = {
						"translate:x": 100
					}
				}, 0.3)
		) \
		.play()

	yield(anima, "animation_completed")

	assert_eq(node.rect_position, Vector2(142, 42))

	node.free()

func test_simple_relative_from_to_animation():
	var node := Control.new()

	node.set_position(Vector2(42, 42))

	add_child(node)

	var anima = Anima.begin_single_shot(self) \
		.with(
			Anima.Node(node) \
			.anima_animation_frames({
				0: {
					"translate:x": 0,
				},
				50: {
					"translate:x": -100,
				},
				100: {
					"translate:x": 100,
				}
			}, 0.3)
		) \
		.play()

	yield(anima, "animation_completed")

	assert_eq(node.rect_position, Vector2(142, 42))

	node.free()


func test_relative_from_to_animation_with_multiple_frames():
	var node := Control.new()

	node.set_position(Vector2(42, 42))

	add_child(node)

	var anima = Anima.begin_single_shot(self) \
		.with(
			Anima.Node(node) \
			.anima_animation_frames({
				0: {
					"translate:x": 0,
				},
				25: {
					"translate:x": -100,
				},
				50: {
					"translate:x": 100,
				},
				75: {
					"translate:x": -50,
				},
				100: {
					"translate:x": 0,
				}
			}, 0.3)
		) \
		.play()

	yield(anima, "animation_completed")

	assert_eq(node.rect_position, Vector2(42, 42))

	node.free()

func test_relative_x_animation() -> void:
	var node := Sprite.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_relative_position_x(100).anima_easing(ANIMA.EASING.EASE_IN_SINE) ) \
		.with( Anima.Node(node).anima_rotate(360).anima_from(0).anima_easing(ANIMA.EASING.EASE_IN_SINE) ) \
		\
		.then( Anima.Node(node).anima_relative_position_y(100) ) \
		.with( Anima.Node(node).anima_rotate(-360).anima_from(0) ) \
		\
		.then( Anima.Node(node).anima_relative_position_x(-100) ) \
		.with( Anima.Node(node).anima_rotate(0).anima_from(360) ) \
		\
		.then( Anima.Node(node).anima_relative_position_y(-100).anima_easing(ANIMA.EASING.EASE_OUT_CIRC) ) \
		.with( Anima.Node(node).anima_rotate(-360).anima_from(0).anima_easing(ANIMA.EASING.EASE_OUT_CIRC) ) \
		\
		.play()

	yield(anima, "animation_completed")

	assert_eq(node.position, Vector2(42, 42))

	node.free()
#
#func test_3d_boxes():
#	var frames = load("res://demos/3d/3DBoxes.gd").new()
#	var box_scene = load("res://tests/Box.tscn").instance()
#
#	add_child(box_scene)
#
#	var output = AnimaKeyframesEngine.parse_frames(
#		{ node = box_scene, duration = 5 },
#		frames._boxes_animation()
#	)
#
#	assert_eq_deep(output, [
#		{ node = box_scene, _wait_time = 0.0, duration = 1.5, property ="shader_param:albedo", from = Color('#6b9eb1'), to = Color('#e63946') },
#		{ node = box_scene, _wait_time = 0.0, duration = 1.75, property ="x", from = null, to = -28.117, relative = true, easing = ANIMA.EASING.EASE_OUT_QUAD },
#		{ node = box_scene, _wait_time = 0.0, duration = 5.0, property ="rotation:x", from = null, to = 360, relative = true, easing = ANIMA.EASING.EASE_IN_CIRC },
#		{ node = box_scene, _wait_time = 2.0, duration = 3.0, property ="shader_param:albedo", from = Color('#e63946'), to =  Color('#6b9eb1'), easing = ANIMA.EASING.EASE_IN_CIRC },
#		{ node = box_scene, _wait_time = 3.25, duration = 1.75, property ="x", from = -28.117, to =  -25.619, relative = true, easing = ANIMA.EASING.EASE_IN_CIRC },
#		{ node = box_scene, _wait_time = 3.25, duration = 1.0, property ="scale", from = Vector3(0.1, 1, 1), to = Vector3.ZERO, initial_value = Vector3(0.1, 1, 1) },
#	])
#
#	box_scene.free()
#	frames.free()
