extends "res://addons/gut/test.gd"

const TargetResolver = preload("res://addons/anima/motion/runtime/anima_target_resolver.gd")

func test_explicit_targets_keep_their_visible_order_before_filtering():
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	var first := Node.new()
	var second := Node.new()
	var third := Node.new()
	var fourth := Node.new()
	collection.reference_data = [third, first, fourth, second]

	var resolution := TargetResolver.resolve(collection, null)

	assert_eq(resolution.targets, [third, first, fourth, second])
	for target in resolution.targets:
		target.free()

func test_odd_and_even_filters_select_disjoint_zero_based_positions():
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	var first := Node.new()
	var second := Node.new()
	var third := Node.new()
	var fourth := Node.new()
	collection.reference_data = [first, second, third, fourth]

	collection.filter = AnimaTargetCollection.Filter.ODD_ONLY
	var odd_resolution := TargetResolver.resolve(collection, null)
	collection.filter = AnimaTargetCollection.Filter.EVEN_ONLY
	var even_resolution := TargetResolver.resolve(collection, null)

	assert_eq(odd_resolution.targets, [second, fourth])
	assert_eq(even_resolution.targets, [first, third])
	assert_ne(odd_resolution.targets[0], even_resolution.targets[0])
	for target in even_resolution.targets:
		target.free()
	for target in odd_resolution.targets:
		if is_instance_valid(target):
			target.free()

func test_invalid_and_empty_target_policies_explain_why_a_group_cannot_play():
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	collection.reference_data = [null]

	var cancelled := TargetResolver.resolve(
		collection,
		null,
		[],
		AnimaGroupMotion.InvalidTargetPolicy.CANCEL_GROUP,
		AnimaGroupMotion.EmptyGroupPolicy.REPORT_ERROR,
	)

	assert_false(cancelled.can_play())
	assert_true(cancelled.cancelled)
	assert_string_contains(cancelled.messages[0], "no longer available")
