extends "res://addons/gut/test.gd"

func test_group_motion_playground_opens_and_selector_starts_a_public_group_playback():
	var scene: Control = preload("res://examples/playground/group_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%OrderSelector")
	assert_eq(selector.get_item_count(), 7)
	var cards := scene.get_node("%CardRow").get_children()
	assert_eq(cards.size(), 5)
	for index in cards.size():
		var atlas := cards[index].artwork.texture as AtlasTexture
		assert_eq(atlas.region.position, Vector2(float(index % 4) * 384.0, floorf(float(index) / 4.0) * 341.0))
	selector.get_item(0).pressed.emit()

	var playback := scene.get("active_playback") as AnimaPlayback
	assert_not_null(playback)
	playback._advance(0.0)
	assert_true(playback.motion is AnimaGroupMotion)
	var group_instance := playback._instance as AnimaGroupPlayback
	var record: AnimaExecutionRecord = group_instance.execution_record
	var forward_first: Node = record.entries[0].target
	var forward_last: Node = record.entries[-1].target
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.reverse_pressed.emit()
	var reverse_record: AnimaExecutionRecord = group_instance.execution_record
	assert_eq(reverse_record.entries[0].target, forward_last)
	assert_eq(reverse_record.entries[-1].target, forward_first)

## Confirms the playground actually goes through Anima.group()'s container
## form now (`_mano_output/phase-16/stories/story-5a-group-playground-uses-anima-group.md`)
## rather than hand-building an AnimaTargetCollection — resolving %CardRow's
## own children, the exact set _cards() already reads from.
func test_group_targets_every_card_in_card_row_via_anima_group():
	var scene: Control = preload("res://examples/playground/group_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var group: AnimaGroupMotion = scene.get("_group")
	assert_eq(group.target_collection.kind, AnimaTargetCollection.Kind.CHILDREN, "Anima.group(_card_row)'s container form resolves CHILDREN, not a captured EXPLICIT array")

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	var resolution := AnimaTargetResolver.resolve(group.target_collection, card_row)
	assert_eq(resolution.targets.size(), card_row.get_child_count())
	for index in resolution.targets.size():
		assert_eq(resolution.targets[index], card_row.get_child(index))

## Regression: picking a speed then switching playback mode/ordering (or
## pressing restart) used to silently drop back to 1x, since restart() built
## a brand-new AnimaPlayback with no speed applied
## (`_mano_output/phase-16/stories/story-5b-group-playground-speed-persists-across-restart.md`).
func test_selected_speed_survives_restart():
	var scene: Control = preload("res://examples/playground/group_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.speed_selected.emit(2.0)
	var playback: AnimaPlayback = scene.get("active_playback")
	assert_almost_eq(playback.speed_scale, 2.0, 0.0001)

	scene.select_playback(scene.PlaybackMode.PARALLEL) # triggers restart() internally
	var restarted_playback: AnimaPlayback = scene.get("active_playback")
	assert_ne(restarted_playback, playback, "sanity: a new playback should have been created")
	assert_almost_eq(restarted_playback.speed_scale, 2.0, 0.0001, "the previously selected speed should still apply after restart")

	controls.restart_pressed.emit()
	var directly_restarted_playback: AnimaPlayback = scene.get("active_playback")
	assert_almost_eq(directly_restarted_playback.speed_scale, 2.0, 0.0001, "pressing restart directly should also keep the selected speed")

## Regression: pressing reverse before the auto-started group had captured
## even one frame used to silently no-op (AnimaPlayback.reverse() had
## nothing to reverse to), leaving the original forward run untouched.
func test_pressing_reverse_before_anything_has_played_still_reverses():
	var scene: Control = preload("res://examples/playground/group_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.restart_pressed.emit()
	var original_playback := scene.get("active_playback") as AnimaPlayback
	controls.reverse_pressed.emit() # same frame as restart — nothing captured yet
	assert_push_error("nothing captured to reverse")

	var playback := scene.get("active_playback") as AnimaPlayback
	assert_ne(playback, original_playback, "reverse() failing natively should fall back to a fresh play_backwards() run, not leave the original forward playback untouched")
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	for i in range(200):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the fallback reversed run should still play through and finish")
