extends "res://addons/gut/test.gd"

func test_kind_values_match_the_original_pivot_ordinals():
	# Ordinals must stay stable so a value serialized before the AnimaPivot
	# rename (an int, under the hood) still resolves to the same pivot.
	assert_eq(AnimaPivot.Kind.NONE, 0)
	assert_eq(AnimaPivot.Kind.TOP_LEFT, 1)
	assert_eq(AnimaPivot.Kind.TOP_CENTER, 2)
	assert_eq(AnimaPivot.Kind.TOP_RIGHT, 3)
	assert_eq(AnimaPivot.Kind.CENTER_LEFT, 4)
	assert_eq(AnimaPivot.Kind.CENTER, 5)
	assert_eq(AnimaPivot.Kind.CENTER_RIGHT, 6)
	assert_eq(AnimaPivot.Kind.BOTTOM_LEFT, 7)
	assert_eq(AnimaPivot.Kind.BOTTOM_CENTER, 8)
	assert_eq(AnimaPivot.Kind.BOTTOM_RIGHT, 9)

func test_a_motion_authored_with_the_old_ordinal_still_resolves_correctly():
	var control: Control = add_child_autofree(Control.new())
	control.size = Vector2(100.0, 80.0)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("scale")
	motion.to_value = Vector2(2.0, 2.0)
	motion.duration = 0.1
	# Simulates a value loaded from a resource saved before the AnimaPivot
	# rename — the raw int ordinal for the old CENTER value.
	motion.pivot = 5

	var instance = motion.create_runtime()
	instance.advance(control, 0.0)

	assert_eq(control.pivot_offset, Vector2(50.0, 40.0), "old CENTER ordinal (5) should still resolve to AnimaPivot.Kind.CENTER's anchor")
