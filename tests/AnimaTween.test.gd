extends "res://addons/gut/test.gd"

func test_add_frames_returns_the_correct_length():
	var tween := AnimaTween.new()
	var node := Control.new()

	add_child(tween)
	add_child(node)

	var duration = tween.add_frames(
		{ node = node, duration = 42 },
		{
			from = {
				opacity = 0,
			},
			50: {
				opacity = 1,
			},
			to = {
				opacity = 0
			}
		}
	)

	assert_eq(duration, 42.0)

	node.free()
	tween.free()

func test_calculate_the_real_duration():
	var tween := AnimaTween.new()
	var node := Label.new()

	node.text = "The quick brown fox jumps over the lazy dog"

	add_child(tween)
	add_child(node)

	var duration = tween.add_frames(
		{ node = node, duration = 0.05 },
		{
			0: {
				percent_visible = 0,
			},
			100: {
				percent_visible = 1,
			},
			"initial_values": {
				percent_visible = 0,
			},
			"_duration": "{duration} * :text:length"
		}
	)

	assert_eq(duration, node.text.length() * 0.05)

	node.free()
	tween.free()
