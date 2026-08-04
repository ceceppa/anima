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
