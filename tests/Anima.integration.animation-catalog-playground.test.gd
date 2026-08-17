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
	assert_eq(_scene.get_node("%Grid").get_item_count(), 12)

func test_selecting_a_category_repopulates_the_grid_and_autoplays_the_first_preset():
	_scene.select_category("specials")
	await wait_process_frames(1)
	assert_eq(_scene.get_node("%Grid").get_item_count(), 4)
	assert_eq(_scene._current_name, "hinge")

func test_selecting_a_preset_replays_it():
	_scene.select_preset("tada")
	await wait_process_frames(1)
	assert_eq(_scene._current_name, "tada")
	assert_not_null(_scene._label_playback)

func test_playback_controls_act_on_the_currently_playing_preset():
	_scene.select_preset("pulse")
	await wait_process_frames(1)
	var label: Label = _scene.get_node("%ControlLabel")

	_scene.get_node("%PlaybackControls").complete_pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(label.scale.x, 1.0, 0.01)

	_scene.get_node("%PlaybackControls").revert_pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(label.scale.x, 1.0, 0.01)

	_scene.get_node("%PlaybackControls").speed_selected.emit(2.0)
	assert_almost_eq(_scene._label_playback.speed_scale, 2.0, 0.01)

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

## --- Target-mode dock ---

func test_target_mode_defaults_to_both_showing_both_slots():
	assert_true(_scene.get_node("%ControlSlot").visible)
	assert_true(_scene.get_node("%SpriteSlot").visible)

func test_selecting_control_mode_hides_only_the_sprite_slot():
	_scene.select_target_mode(_scene.TargetMode.CONTROL)
	assert_true(_scene.get_node("%ControlSlot").visible)
	assert_false(_scene.get_node("%SpriteSlot").visible)

func test_selecting_sprite2d_mode_hides_only_the_control_slot():
	_scene.select_target_mode(_scene.TargetMode.SPRITE2D)
	assert_false(_scene.get_node("%ControlSlot").visible)
	assert_true(_scene.get_node("%SpriteSlot").visible)

## --- Dual playback in Both mode (story-1c) ---

func test_both_mode_plays_the_preset_on_both_targets_simultaneously():
	_scene.select_preset("tada")
	await wait_process_frames(1)
	assert_not_null(_scene._label_playback)
	assert_not_null(_scene._sprite_playback)
	assert_eq(_scene._label_playback.target, _scene.get_node("%ControlLabel"))
	assert_eq(_scene._sprite_playback.target, _scene.get_node("%Sprite"))

func test_control_mode_plays_only_the_label_for_any_preset():
	_scene.select_target_mode(_scene.TargetMode.CONTROL)
	_scene.select_preset("tada")
	await wait_process_frames(1)
	assert_not_null(_scene._label_playback)
	assert_null(_scene._sprite_playback)

## Regression test: selecting Sprite2D mode previously left the sprite
## static for any preset that wasn't one of the 4 light_speed ones, because
## routing was compatibility-based rather than mode-based. Every preset now
## plays on whichever target(s) the mode says (AnimationCatalogSprite's
## synthetic `size` makes every preset genuinely compatible with Sprite2D).
func test_sprite2d_mode_plays_every_preset_not_just_lightspeed():
	_scene.select_target_mode(_scene.TargetMode.SPRITE2D)
	_scene.select_preset("tada") # not a light_speed preset
	await wait_process_frames(1)
	assert_null(_scene._label_playback)
	assert_not_null(_scene._sprite_playback)
	assert_eq(_scene._sprite_playback.target, _scene.get_node("%Sprite"))

func test_switching_target_mode_restarts_playback_for_the_new_visible_target():
	_scene.select_target_mode(_scene.TargetMode.CONTROL)
	_scene.select_preset("tada")
	await wait_process_frames(1)
	assert_null(_scene._sprite_playback)

	_scene.select_target_mode(_scene.TargetMode.SPRITE2D)
	await wait_process_frames(1)
	assert_null(_scene._label_playback)
	assert_not_null(_scene._sprite_playback)

func test_speed_applies_to_both_playbacks_in_both_mode():
	_scene.select_preset("tada")
	await wait_process_frames(1)
	_scene.get_node("%PlaybackControls").speed_selected.emit(2.0)
	assert_almost_eq(_scene._label_playback.speed_scale, 2.0, 0.01)
	assert_almost_eq(_scene._sprite_playback.speed_scale, 2.0, 0.01)

func test_complete_applies_to_both_targets_in_both_mode():
	_scene.select_preset("pulse")
	await wait_process_frames(1)
	_scene.get_node("%PlaybackControls").complete_pressed.emit()
	await wait_process_frames(1)
	var label: Label = _scene.get_node("%ControlLabel")
	var sprite: Sprite2D = _scene.get_node("%Sprite")
	assert_almost_eq(label.scale.x, 1.0, 0.01)
	assert_almost_eq(sprite.scale.x, 1.0, 0.01)

func test_light_speed_preset_in_both_mode_plays_on_both_targets():
	_scene.select_category("lightspeed")
	_scene.select_preset("light_speed_in_left")
	await wait_process_frames(1)
	assert_not_null(_scene._label_playback)
	assert_not_null(_scene._sprite_playback)

## --- Content-length-scaled duration (story-1d) ---

func test_typewrite_reveals_the_labels_text_progressively_to_completion():
	_scene.select_category("text")
	_scene.select_preset("typewrite")
	await wait_process_frames(1)
	var label: Label = _scene.get_node("%ControlLabel")
	assert_almost_eq(label.visible_ratio, 0.0, 0.05)

	_scene.get_node("%PlaybackControls").complete_pressed.emit()
	await wait_process_frames(1)
	assert_almost_eq(label.visible_ratio, 1.0, 0.01)

func test_sprite_uses_the_card_atlas_artwork_not_a_flat_placeholder():
	var sprite: Sprite2D = _scene.get_node("%Sprite")
	assert_true(sprite.texture is AtlasTexture)
	var atlas_texture: AtlasTexture = sprite.texture
	assert_eq(atlas_texture.atlas, load("res://examples/playground/images/cards.jpg"))
