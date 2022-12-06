extends "res://addons/gut/test.gd"

func test_simple_backwards():
	var node := Control.new()
	var cross := Sprite2D.new()

	cross.texture = load("res://demos/resources/cross.png")

	node.add_child(cross)
	add_child(node)

	node.position = Vector2(100, 100)
	node.size = Vector2(100, 10)

	var anima := Anima.begin(self) \
		.with(
			Anima.Node(node).anima_animation_frames({
				0: {
					"translate:x": "-:size:x",
				},
				100: {
					"translate:x": 0,
				}
			})
		) \
		.play()

	await anima.animation_completed

	assert_eq(node.position, Vector2(100, 100))

	anima.play_backwards()

	await anima.animation_completed

	assert_eq(node.position, Vector2(0, 100))

	await get_tree().idle_frame

	# only the original tween and the timer should exists
	assert_eq(anima.get_child_count(), 2)

	anima.free()
	node.free()

func test_on_started():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_started(_on_callback, null, "backwards") ) \
		.play_backwards()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, "backwards")

	node.free()

func test_on_started_multiple_params():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_started(self, "_on_callback_two_params", null, [42, "ciao"]) ) \
		.play_backwards()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, [42, "ciao"])

	node.free()

func test_on_completed():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_completed(self, "_on_callback", null, "completed-backwards") ) \
		.play_backwards()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, "completed-backwards")

	node.free()

func test_on_completed_multiple_params():
	var node := Sprite2D.new()

	node.texture = load("res://demos/resources/cross.png")
	node.set_position(Vector2(42, 42))

	add_child(node)

	_on_callback_called_params = "__not_called__"

	var anima = Anima.begin_single_shot(self) \
		.set_default_duration(0.15) \
		.then( Anima.Node(node).anima_fade_in(1).anima_on_started(self, "_on_callback_two_params", null, [":)", "yay"]) ) \
		.play_backwards()

	assert_ne(_on_callback_called_params, null)

	await anima.animation_completed

	assert_eq(_on_callback_called_params, [":)", "yay"])

	node.free()

var _on_callback_called_params

func _on_callback(params):
	_on_callback_called_params = params

func _on_callback_two_params(p1, p2):
	_on_callback_called_params = [p1, p2]
