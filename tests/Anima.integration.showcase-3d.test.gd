extends "res://addons/gut/test.gd"

## The storyboard runs on real timers for about 20 seconds. Tests speed the
## engine up instead of waiting that long; Anima and SceneTreeTimers both
## follow Engine.time_scale, and so does GUT's own wait timeout — it is
## given in scene seconds.
const SPEED_UP := 8.0

func before_each():
	Engine.time_scale = SPEED_UP

func after_each():
	Engine.time_scale = 1.0
	for playback in AnimaRuntime.get_singleton().active_playbacks.duplicate():
		playback.cancel()

func _make_scene() -> Showcase3D:
	var scene: Showcase3D = preload("res://examples/showcase/3d/showcase_3d.tscn").instantiate()
	add_child_autofree(scene)
	return scene

func _opacity(node: Node3D) -> float:
	return AnimaPlanarAccess.read(node, ^"modulate:a", true)

func test_scene_holds_the_shapes_and_a_hidden_five_by_five_grid():
	var scene := _make_scene()
	await get_tree().process_frame

	assert_eq(scene.get_node("%Tiles").get_child_count(), 25)
	for tile in scene.get_node("%Tiles").get_children():
		assert_false((tile as Node3D).visible, "%s starts hidden until Act 3" % tile.name)
	assert_true(scene.get_node("%Cube").visible)
	assert_false(scene.get_node("%Sphere").visible)
	assert_false(scene.get_node("%Cylinder").visible)
	assert_false(scene.get_node("%Outro").visible)

func test_full_show_ends_with_every_tile_shown_at_rest_and_the_outro_visible():
	var scene := _make_scene()
	await wait_for_signal(scene.show_finished, 30.0)

	assert_signal_emitted(scene, "show_finished")
	for tile in scene.get_node("%Tiles").get_children():
		var tile_node := tile as Node3D
		assert_true(tile_node.visible, tile.name)
		assert_almost_eq(_opacity(tile_node), 1.0, 0.01, "%s should be fully opaque" % tile.name)
		assert_true(tile_node.scale.is_equal_approx(Vector3.ONE), "%s should be back at rest" % tile.name)
		assert_almost_eq(tile_node.position.y, 0.0, 0.001, "%s should be back on the floor" % tile.name)
	assert_true(scene.get_node("%Outro").visible)
	assert_almost_eq(scene.get_node("%Logo").modulate.a, 1.0, 0.01)
	assert_almost_eq(scene.get_node("%CodePanel").modulate.a, 0.0, 0.01, "the code panel fades out under the outro")

func test_shapes_play_their_presets_and_zoom_out_before_the_grid():
	var scene := _make_scene()
	await wait_for_signal(scene.show_finished, 30.0)

	for shape_name in ["Sphere", "Cube", "Cylinder"]:
		var shape: Node3D = scene.get_node("%" + shape_name)
		assert_true(shape.visible, shape_name)
		assert_almost_eq(_opacity(shape), 0.0, 0.01, "%s should have zoomed out" % shape_name)
		assert_almost_eq(shape.rotation.z, 0.0, 0.001, "%s rotation" % shape_name)
		assert_almost_eq(shape.position.y, 0.0, 0.001, "%s position" % shape_name)

func test_camera_ends_on_the_grid_shot():
	var scene := _make_scene()
	await wait_for_signal(scene.show_finished, 30.0)

	var camera: Camera3D = scene.get_node("%Camera")
	assert_true(camera.transform.is_equal_approx(scene.get_node("%GridShot").transform))

func test_code_snippet_is_fully_shown_after_typing():
	var scene := _make_scene()
	await get_tree().process_frame

	await scene._show_code("Anima.group([sphere, cylinder]).play()")

	var code: RichTextLabel = scene.get_node("%Code")
	assert_eq(code.visible_characters, -1)
	assert_eq(code.get_parsed_text(), "Anima.group([sphere, cylinder]).play()", "square brackets must be escaped, not parsed as BBCode")
