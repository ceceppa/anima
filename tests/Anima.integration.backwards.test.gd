extends "res://addons/gut/test.gd"

func test_simple_backwards():
	var node := Control.new()
	var cross := Sprite.new()

	cross.texture = load("res://demos/resources/cross.png")

	node.add_child(cross)
	add_child(node)

	node.rect_position = Vector2(100, 100)
	node.rect_size = Vector2(100, 10)

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

	yield(anima, "animation_completed")

	assert_eq(node.rect_position, Vector2(100, 100))

	anima.play_backwards()

	yield(anima, "animation_completed")

	assert_eq(node.rect_position, Vector2(0, 100))

	yield(get_tree(), "idle_frame")

	# only the original tween and the timer should exists
	assert_eq(anima.get_child_count(), 2)

	anima.free()
	node.free()
