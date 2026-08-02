extends "res://addons/gut/test.gd"

func test_group_motion_keeps_its_authored_configuration_after_save_and_load():
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.SEQUENTIAL
	group.sequential_gap = 0.2

	var save_path := "user://anima_group_motion_round_trip.tres"
	assert_eq(ResourceSaver.save(group, save_path), OK)
	var restored := load(save_path) as AnimaGroupMotion
	assert_eq(restored.playback_mode, AnimaGroupMotion.PlaybackMode.SEQUENTIAL)
	assert_eq(restored.sequential_gap, 0.2)
	assert_ne(restored.target_collection, null)
	assert_ne(restored.item_motion, null)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

func test_group_motion_reports_required_configuration():
	var group := AnimaGroupMotion.new()
	var errors := group.validate()
	assert_has(errors, "target_collection is required")
	assert_has(errors, "item_motion is required")
