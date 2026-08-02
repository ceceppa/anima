extends "res://addons/gut/test.gd"

const PlaygroundRoot := preload("res://examples/shared/components/example_playground.gd")

func test_shared_playground_root_can_enter_the_scene_tree():
	var playground: Control = PlaygroundRoot.new()
	add_child_autofree(playground)

	assert_true(playground.is_inside_tree())
