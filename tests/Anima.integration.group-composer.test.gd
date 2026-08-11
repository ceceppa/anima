extends "res://addons/gut/test.gd"

const GroupComposer = preload("res://addons/anima/editor/anima_group_composer.gd")

func test_a_group_created_and_edited_in_the_composer_plays_through_anima():
	var composer := GroupComposer.new()
	var parent := _AnimaSequence.new()
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
	var parent := _AnimaSequence.new()

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

## Regression: the "not a group" messages only ever pointed at picking a
## Group Motion, even though selecting a Property Motion elsewhere in the
## graph is an equally reachable next step from this same state.
func test_not_a_group_messages_also_name_property_motion_as_an_option():
	var composer := GroupComposer.new()
	add_child_autofree(composer)

	composer.show_motion(_AnimaSequence.new(), null)
	assert_string_contains(composer.status_message(), "Property Motion")

	composer.show_motion(AnimaPropertyMotion.new(), null)
	assert_string_contains(composer.status_message(), "Property Motion")

## An unconfigured Group Motion has nothing for Preview to act on yet — the
## status names the concrete next step instead, and the Preview/Stop/Reverse
## controls stay hidden until both fields are assigned.
func test_status_names_assign_target_and_item_motion_when_group_is_unconfigured():
	var composer := GroupComposer.new()
	add_child_autofree(composer)
	var group := AnimaGroupMotion.new()

	composer.show_motion(group, null)

	assert_string_contains(composer.status_message(), "target collection")
	assert_string_contains(composer.status_message(), "item motion")
	assert_eq(_find_button_with_text(composer, "Preview"), null, "Preview should not show until the group is configured")

func test_preview_controls_appear_once_the_group_is_configured():
	var composer := GroupComposer.new()
	add_child_autofree(composer)
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)

	composer.show_motion(group, null)

	assert_not_null(_find_button_with_text(composer, "Preview"), "Preview should show once the group has a target collection and item motion")

func _find_button_with_text(node: Node, text: String) -> Button:
	for child in node.get_children():
		if child is Button and child.text == text:
			return child
		var found: Button = _find_button_with_text(child, text)
		if found != null:
			return found
	return null
