extends "res://addons/gut/test.gd"

func _make_scene() -> Control:
	var scene: Control = preload("res://examples/showcase/grid/grid_showcase.tscn").instantiate()
	add_child_autofree(scene)
	return scene

## `grid_showcase.gd`'s own pacing between beats runs on real [SceneTreeTimer]s
## (`_wait_for_next()`), not manually-stepped deltas, so this file drives time
## by letting real engine frames elapse rather than the fixed-delta
## `AnimaRuntime` stepping earlier showcase tests used.
func _wait_real(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func test_run_show_completes_without_error():
	var scene := _make_scene()
	await get_tree().process_frame

	await scene._run_show()

	assert_true(true, "the full sequence should run start to finish with no errors")

func test_zoom_transition_fades_scene1_out_and_scene2_in():
	var scene := _make_scene()
	await get_tree().process_frame
	scene._run_show()

	assert_almost_eq(scene.get_node("%Scene1").modulate.a, 1.0, 0.01, "Scene 1 should still be fully visible before its own reveal finishes")

	await _wait_real(2.5) # comfortably covers Scene 1's reveal and the zoom transition

	assert_almost_eq(scene.get_node("%Scene1").modulate.a, 0.0, 0.05, "Scene 1 should have faded out once the zoom transition to Scene 2 completes")
	assert_almost_eq(scene.get_node("%Scene2").modulate.a, 1.0, 0.05, "Scene 2 should be fully visible once the zoom transition completes")

func test_scene3_plays_after_scene1_and_scene2():
	var scene := _make_scene()
	await get_tree().process_frame
	var default_label: String = scene.get_node("%Scene3").get_node("%Label").text
	scene._run_show()

	await _wait_real(4.5) # comfortably covers Scene 1, the zoom transition, and Scene 2's own wait before Scene 3 starts

	var label: String = scene.get_node("%Scene3").get_node("%Label").text
	assert_ne(label, default_label, "Scene 3 should have started and set its own label, replacing the scene's static placeholder text")
