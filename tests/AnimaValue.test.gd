extends "res://addons/gut/test.gd"

func test_constant_resolves_to_the_wrapped_literal():
	var value := AnimaValue.constant(42.0)
	var context := AnimaValueContext.new()

	assert_eq(value.resolve(context), 42.0)

func test_target_resolves_the_context_targets_own_property():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position = Vector2(10.0, 20.0)

	var value := AnimaValue.target(NodePath("position"))
	var context := AnimaValueContext.new(node)

	assert_eq(value.resolve(context), Vector2(10.0, 20.0))

func test_node_resolves_another_nodes_property_relative_to_root():
	var root: Node2D = add_child_autofree(Node2D.new())
	var other: Node2D = Node2D.new()
	other.name = "Other"
	root.add_child(other)
	other.position = Vector2(5.0, 7.0)

	var value := AnimaValue.node(NodePath("Other"), NodePath("position"))
	var context := AnimaValueContext.new(root)

	assert_eq(value.resolve(context), Vector2(5.0, 7.0))

func test_node_with_a_missing_path_fails_and_returns_null():
	var root: Node2D = add_child_autofree(Node2D.new())

	var value := AnimaValue.node(NodePath("DoesNotExist"), NodePath("position"))
	var context := AnimaValueContext.new(root)

	assert_null(value.resolve(context))
	assert_push_error("no node found")

func test_root_resolves_the_contexts_own_root_not_the_target():
	var target: Node2D = add_child_autofree(Node2D.new())
	var container: Node2D = add_child_autofree(Node2D.new())
	container.position = Vector2(1.0, 2.0)
	target.position = Vector2(99.0, 99.0)

	var value := AnimaValue.root(NodePath("position"))
	var context := AnimaValueContext.new(target)
	context.root = container

	assert_eq(value.resolve(context), Vector2(1.0, 2.0))

func test_context_reads_from_the_supplied_context_data():
	var value := AnimaValue.context("speed_hint")
	var context := AnimaValueContext.new()
	context.context_data = {"speed_hint": 3.5}

	assert_eq(value.resolve(context), 3.5)

func test_context_with_no_matching_key_resolves_to_null():
	var value := AnimaValue.context("missing")
	var context := AnimaValueContext.new()

	assert_null(value.resolve(context))

func test_add_combines_two_dynamic_values():
	var parent: Node2D = add_child_autofree(Node2D.new())
	var node_a: Node2D = Node2D.new()
	node_a.name = "NodeA"
	node_a.position = Vector2(10.0, 0.0)
	parent.add_child(node_a)
	var node_b: Node2D = Node2D.new()
	node_b.name = "NodeB"
	node_b.position = Vector2(4.0, 0.0)
	parent.add_child(node_b)

	var value := AnimaValue.target(NodePath("position:x")) \
		.add(AnimaValue.node(NodePath("NodeB"), NodePath("position:x")))
	var context := AnimaValueContext.new(node_a)
	context.root = parent

	assert_eq(value.resolve(context), 14.0)

func test_add_with_a_plain_literal_does_not_require_wrapping():
	var value := AnimaValue.constant(10.0).add(5.0)
	var context := AnimaValueContext.new()

	assert_eq(value.resolve(context), 15.0)

func test_subtract_multiply_divide():
	var context := AnimaValueContext.new()

	assert_eq(AnimaValue.constant(10.0).subtract(3.0).resolve(context), 7.0)
	assert_eq(AnimaValue.constant(4.0).multiply(2.5).resolve(context), 10.0)
	assert_eq(AnimaValue.constant(9.0).divide(3.0).resolve(context), 3.0)

func test_clamp_never_resolves_outside_its_bounds():
	var context := AnimaValueContext.new()

	assert_eq(AnimaValue.constant(50.0).clamp(0.0, 10.0).resolve(context), 10.0)
	assert_eq(AnimaValue.constant(-5.0).clamp(0.0, 10.0).resolve(context), 0.0)
	assert_eq(AnimaValue.constant(5.0).clamp(0.0, 10.0).resolve(context), 5.0)

func test_custom_resolves_through_the_supplied_callable():
	var value := AnimaValue.custom(func(context: AnimaValueContext) -> float:
		return 123.0
	)
	var context := AnimaValueContext.new()

	assert_eq(value.resolve(context), 123.0)

func test_group_and_grid_position_sources_resolve_to_their_sentinel_outside_a_group():
	var context := AnimaValueContext.new()

	assert_eq(AnimaValue.group_index().resolve(context), -1)
	assert_eq(AnimaValue.group_count().resolve(context), -1)
	assert_eq(AnimaValue.group_normalised_index().resolve(context), -1.0)
	assert_eq(AnimaValue.grid_row().resolve(context), -1)
	assert_eq(AnimaValue.grid_column().resolve(context), -1)

func test_length_resolves_to_the_character_count_of_a_string_property():
	var label := Label.new()
	add_child_autofree(label)
	label.text = "hello"

	var value := AnimaValue.target(NodePath("text")).length()
	var context := AnimaValueContext.new(label)

	assert_eq(value.resolve(context), 5)

func test_length_composes_with_arithmetic_like_any_other_value():
	var label := Label.new()
	add_child_autofree(label)
	label.text = "hello"

	var value := AnimaValue.target(NodePath("text")).length().multiply(0.7)
	var context := AnimaValueContext.new(label)

	assert_almost_eq(value.resolve(context), 3.5, 0.001)

func test_length_of_an_undefined_property_resolves_to_zero_not_an_error():
	var sprite := Sprite2D.new()
	add_child_autofree(sprite)

	var value := AnimaValue.target(NodePath("text")).length()
	var context := AnimaValueContext.new(sprite)

	assert_eq(value.resolve(context), 0)

func test_the_same_base_value_combined_two_ways_stays_independent():
	var base := AnimaValue.constant(10.0)
	var doubled := base.multiply(2.0)
	var halved := base.multiply(0.5)
	var context := AnimaValueContext.new()

	assert_eq(base.resolve(context), 10.0)
	assert_eq(doubled.resolve(context), 20.0)
	assert_eq(halved.resolve(context), 5.0)
