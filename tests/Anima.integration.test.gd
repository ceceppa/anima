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

