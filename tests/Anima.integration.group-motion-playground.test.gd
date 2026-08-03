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
