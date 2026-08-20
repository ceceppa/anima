extends "res://addons/gut/test.gd"

const PlaygroundRoot := preload("res://examples/playground/shared/components/example_playground.gd")

func test_shared_playground_root_can_enter_the_scene_tree():
	var playground: Control = PlaygroundRoot.new()
	add_child_autofree(playground)

	assert_true(playground.is_inside_tree())

func test_wires_a_header_descendants_back_pressed_signal():
	var playground: Control = PlaygroundRoot.new()
	var header: ExampleHeader = preload("res://examples/playground/shared/components/example_header.tscn").instantiate()
	playground.add_child(header)
	add_child_autofree(playground)

	assert_gt(header.back_pressed.get_connections().size(), 0)
