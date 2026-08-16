extends "res://addons/gut/test.gd"

## Animation Catalog Playground scene (phase-18, story-1).

var _scene: Control

func before_each():
	var packed := load("res://examples/playground/animation_catalog_playground.tscn")
	_scene = packed.instantiate()
	add_child_autofree(_scene)
	await wait_process_frames(2)

func test_opens_with_all_categories_and_default_selection_playing():
	assert_eq(_scene.get_node("%Sidebar").get_item_count(), 16)
	assert_eq(_scene._current_category, "attention_seeker")
	assert_eq(_scene._current_name, "bounce")
	assert_eq(_scene.get_node("%StageTitle").text, "bounce")
	assert_eq(_scene.get_node("%Grid").get_item_count(), 12)

func test_selecting_a_category_repopulates_the_grid_and_autoplays_the_first_preset():
	_scene.select_category("specials")
	await wait_process_frames(1)
	assert_eq(_scene.get_node("%Grid").get_item_count(), 4)
	assert_eq(_scene._current_name, "hinge")
	assert_eq(_scene.get_node("%StageTitle").text, "hinge")

func test_selecting_a_preset_replays_it():
	_scene.select_preset("tada")
	await wait_process_frames(1)
	assert_eq(_scene._current_name, "tada")
	assert_eq(_scene.get_node("%StageTitle").text, "tada")
	assert_not_null(_scene._active_playback)

func test_light_speed_presets_play_on_the_sprite_not_the_card():
	_scene.select_category("lightspeed")
	_scene.select_preset("light_speed_in_left")
	await wait_process_frames(1)
	assert_false(_scene.get_node("%Card").visible)
	assert_true(_scene.get_node("%Sprite").visible)

func test_non_light_speed_presets_play_on_the_card():
	_scene.select_preset("tada")
	await wait_process_frames(1)
	assert_true(_scene.get_node("%Card").visible)
	assert_false(_scene.get_node("%Sprite").visible)

func test_playback_controls_act_on_the_currently_playing_preset():
	_scene.select_preset("pulse")
	await wait_process_frames(1)
	var card: Card = _scene.get_node("%Card")

	_scene.get_node("%PlaybackControls").complete_pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(card.scale.x, 1.0, 0.01)

	_scene.get_node("%PlaybackControls").revert_pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(card.scale.x, 1.0, 0.01)

	_scene.get_node("%PlaybackControls").speed_selected.emit(2.0)
	assert_almost_eq(_scene._active_playback.speed_scale, 2.0, 0.01)

func test_reduced_motion_toggle_reaches_the_global_flag():
	var before := Anima.reduced_motion
	_scene.get_node("%PlaybackControls").reduced_motion_toggled.emit(not before)
	assert_eq(Anima.reduced_motion, not before)
	Anima.reduced_motion = before # restore for other tests

func test_every_category_reaches_every_preset_with_none_missing():
	var seen: Dictionary = {}
	for category in AnimationCatalogIndex.categories():
		_scene.select_category(category)
		await wait_process_frames(1)
		for preset_name in _scene._current_names:
			seen[preset_name] = true
	assert_eq(seen.size(), 99)

func test_selecting_a_preset_never_mutates_the_shared_cached_resource():
	var cached_before := Anima.animation("swing")
	var duration_before: float = cached_before.duration
	_scene.select_preset("swing")
	await wait_process_frames(1)
	_scene.get_node("%PlaybackControls").speed_selected.emit(2.0)
	var cached_after := Anima.animation("swing")
	assert_same(cached_before, cached_after)
	assert_eq(cached_after.duration, duration_before)
	assert_true(is_zero_approx(cached_after.reduced_motion_speed - (-1.0)), "cached preset's reduced_motion_speed must stay at the unset sentinel")
