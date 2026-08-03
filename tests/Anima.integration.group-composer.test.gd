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

## Regression: this state used to read "Select a Group Motion to edit it, or
## select a compatible parent to add one." with no way to tell which of the
## two applied from here. A compatible parent is selected, so the message
## now names the reachable Add Group Motion button directly.
func test_status_names_the_add_group_button_when_the_parent_can_hold_one():
	var composer := GroupComposer.new()
	add_child_autofree(composer)
	var parent := AnimaSequence.new()

	composer.show_motion(parent, null)

	assert_string_contains(composer.status_message(), "Add Group Motion")

## When the selected motion is neither a group nor a compatible parent, the
## Add Group Motion button never appears — the status must point at the
## dropdown instead, not repeat a button that isn't there.
func test_status_names_the_dropdown_when_no_group_can_be_added_here():
	var composer := GroupComposer.new()
	add_child_autofree(composer)
	var leaf := AnimaPropertyMotion.new()

	composer.show_motion(leaf, null)

	assert_string_contains(composer.status_message(), "dropdown")
	assert_false(composer.status_message().contains("Add Group Motion"), "should not point at a button that isn't visible from this state")
