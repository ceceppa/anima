extends "res://addons/gut/test.gd"

func _play(motion: AnimaMotion, target: Node, frames: int = 30, dt: float = 1.0 / 60.0) -> AnimaPlayback:
	var playback := Anima.play(motion, target)
	for i in range(frames):
		playback._advance(dt)
	return playback

func test_position_moves_a_node2d_and_matches_the_canonical_motion():
	var node: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	_play(Anima.on(node).position(Vector2(100.0, 0.0), 0.5), node)
	_play(Motion.to(NodePath("position"), Vector2(100.0, 0.0)).with_duration(0.5), canonical)

	assert_almost_eq(node.position.x, canonical.position.x, 0.01)

func test_move_by_offsets_from_the_actual_start_value():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position = Vector2(10.0, 0.0)

	_play(Anima.on(node).move_by(Vector2(40.0, 0.0), 0.5), node)

	assert_almost_eq(node.position.x, 50.0, 0.01)

func test_property_by_produces_the_same_result_as_move_by_for_an_equivalent_property():
	var move_by_node: Node2D = add_child_autofree(Node2D.new())
	move_by_node.position = Vector2(10.0, 0.0)
	var property_by_node: Node2D = add_child_autofree(Node2D.new())
	property_by_node.position = Vector2(10.0, 0.0)

	_play(Anima.on(move_by_node).move_by(Vector2(40.0, 0.0), 0.5), move_by_node)
	_play(Anima.on(property_by_node).property_by(NodePath("position"), Vector2(40.0, 0.0), 0.5), property_by_node)

	assert_almost_eq(property_by_node.position.x, move_by_node.position.x, 0.01)
	assert_almost_eq(property_by_node.position.x, 50.0, 0.01)

func test_scale_and_rotation_change_a_control_target():
	var control: Control = add_child_autofree(Control.new())

	_play(Anima.on(control).scale(Vector2(2.0, 2.0), 0.5), control)
	assert_almost_eq(control.scale.x, 2.0, 0.01)

	var rotation_control: Control = add_child_autofree(Control.new())
	_play(Anima.on(rotation_control).rotation(1.5, 0.5), rotation_control)
	assert_almost_eq(rotation_control.rotation, 1.5, 0.01)

func test_opacity_maps_to_modulate_alpha():
	var control: Control = add_child_autofree(Control.new())

	_play(Anima.on(control).opacity(0.4, 0.5), control)

	assert_almost_eq(control.modulate.a, 0.4, 0.01)

func test_opacity_outside_unit_range_is_allowed_and_not_clamped():
	var control: Control = add_child_autofree(Control.new())

	_play(Anima.on(control).opacity(1.5, 0.5), control)

	assert_almost_eq(control.modulate.a, 1.5, 0.01)
	assert_push_warning("outside 0.0..1.0")

func test_color_maps_to_modulate():
	var control: Control = add_child_autofree(Control.new())

	_play(Anima.on(control).color(Color(1.0, 0.0, 0.0), 0.5), control)

	assert_almost_eq(control.modulate.r, 1.0, 0.01)

func test_size_changes_a_control_target():
	var control: Control = add_child_autofree(Control.new())
	control.size = Vector2(10.0, 10.0)

	_play(Anima.on(control).size(Vector2(50.0, 50.0), 0.5), control)

	assert_almost_eq(control.size.x, 50.0, 0.5)

func test_generic_property_delegates_to_the_canonical_property_path():
	var node: Node2D = add_child_autofree(Node2D.new())

	_play(Anima.on(node).property(NodePath("position:x"), 75.0, 0.5), node)

	assert_almost_eq(node.position.x, 75.0, 0.01)

func test_explicit_from_starts_at_the_supplied_value_not_the_current_one():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position.x = 5.0

	var motion := Anima.on(node).position(Vector2(100.0, 0.0), 1.0).from(Vector2(0.0, 0.0))
	var playback := Anima.play(motion, node)
	playback._advance(0.0)

	assert_almost_eq(node.position.x, 0.0, 0.01, "first frame should read the explicit from(), not the pre-existing 5.0")
	playback.cancel()

func test_omitted_from_starts_at_the_value_visible_when_playback_starts():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position.x = 5.0

	var motion := Anima.on(node).position(Vector2(100.0, 0.0), 1.0)
	var playback := Anima.play(motion, node)
	playback._advance(0.0)

	assert_almost_eq(node.position.x, 5.0, 0.01, "first frame should read the node's actual current value")
	playback.cancel()

func test_position_z_requires_a_node3d_target():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := Anima.on(node).position_z(1.0)

	assert_null(motion)
	assert_push_error("Node3D")

func test_position_with_wrong_value_type_fails_validation_before_playback():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := Anima.on(node).position(Vector3(1.0, 2.0, 3.0))

	assert_null(motion)
	assert_push_error("Vector2")

func test_opacity_on_a_non_canvasitem_target_fails_validation():
	var node3d: Node3D = add_child_autofree(Node3D.new())

	var motion := Anima.on(node3d).opacity(0.5)

	assert_null(motion)
	assert_push_error("CanvasItem")

func test_rotation_on_a_node3d_target_fails_validation():
	var node3d: Node3D = add_child_autofree(Node3D.new())

	var motion := Anima.on(node3d).rotation(1.0)

	assert_null(motion)
	assert_push_error("Node3D")

func test_size_on_a_non_control_target_fails_validation():
	var node2d: Node2D = add_child_autofree(Node2D.new())

	var motion := Anima.on(node2d).size(Vector2(10.0, 10.0))

	assert_null(motion)
	assert_push_error("Control")

func test_anima_on_null_target_reports_an_error_and_returns_null():
	var factory := Anima.on(null)

	assert_null(factory)
	assert_push_error("non-null target")
