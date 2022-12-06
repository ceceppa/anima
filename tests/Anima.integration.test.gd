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

	await anima.animation_completed

	assert_eq(node.scale, Vector2(10, 10))

	await get_tree().idle_frame

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

	await anima.animation_completed

	assert_eq(node.position, Vector2(142, 42))

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

	await anima.animation_completed

	assert_eq(node.position, Vector2(142, 42))

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

	await anima.animation_completed

	assert_eq(node.position, Vector2(42, 42))

	node.free()

func test_relative_x_animation() -> void:
	var node := Sprite2D.new()

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

	await anima.animation_completed

	assert_eq(node.position, Vector2(42, 42))

	node.free()

func test_start_callback():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_started(_on_callback) ) \
		.play()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, null)

	node.free()

func test_start_callback_custom_params():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_started(_on_callback_two_params, [1, 2]) ) \
		.play()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, [1, 2])

	node.free()

func test_on_completed():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_completed(_on_callback) ) \
		.play()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, null)

	node.free()

func test_on_completed_multiple_params():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_completed(_on_callback_two_params, ['a', 42]) ) \
		.play()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, ['a', 42])

	node.free()

var _on_callback_called_params

func _on_callback(params):
	_on_callback_called_params = params

func _on_callback_two_params(p1, p2):
	_on_callback_called_params = [p1, p2]
