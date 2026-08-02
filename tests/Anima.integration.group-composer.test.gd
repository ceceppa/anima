extends "res://addons/gut/test.gd"

const GroupComposer = preload("res://addons/anima/editor/anima_group_composer.gd")

func test_a_group_created_and_edited_in_the_composer_plays_through_anima():
	var composer := GroupComposer.new()
	var parent := AnimaSequence.new()
	var group := composer.add_group(parent)
	var root := Node.new()
	add_child_autofree(root)
	var target := Node2D.new()
	root.add_child(target)

	assert_ne(group, null)
	assert_eq(parent.children, [group])
	assert_true(composer.set_group_property("item_motion", Motion.to(NodePath("position:x"), 10.0)))
	assert_true(composer.set_group_property("playback_mode", AnimaGroupMotion.PlaybackMode.PARALLEL))

	var playback := Anima.play(group, root)
	for i in range(10):
		playback._advance(0.1)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(target.position.x, 10.0, 0.01)
	composer.free()
