extends "res://addons/gut/test.gd"

func test_add_frames_returns_the_correct_length():
	var tween := AnimaTween.new(AnimaTween.PLAY_MODE.NORMAL)
	var node := Control.new()

	add_child(tween)
	add_child(node)

	var duration = tween.add_frames(
		{ node = node, duration = 42 },
		{
			from = {
				opacity = 0,
			},
			to = {
				opacity = 1
			}
		}
	)

	assert_eq(duration, 42.0)

	node.free()
	tween.free()
