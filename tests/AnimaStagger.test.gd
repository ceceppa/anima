extends "res://addons/gut/test.gd"

func _make_targets(count: int) -> Array[Node]:
	var targets: Array[Node] = []
	for i in range(count):
		var node := Node2D.new()
		autofree(node)
		targets.append(node)
	return targets

func _make_template(duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = duration
	return motion

func test_forward_order_is_list_order():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(4)
	stagger.order = _AnimaStagger.Order.FORWARD

	assert_eq(stagger.resolve_order(), [0, 1, 2, 3])

func test_reverse_order_is_opposite_of_list_order():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(4)
	stagger.order = _AnimaStagger.Order.REVERSE

	assert_eq(stagger.resolve_order(), [3, 2, 1, 0])

func test_from_center_order_starts_at_the_middle():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(5)
	stagger.order = _AnimaStagger.Order.FROM_CENTER

	assert_eq(stagger.resolve_order(), [2, 1, 3, 0, 4])

func test_from_edges_order_starts_at_both_ends():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(5)
	stagger.order = _AnimaStagger.Order.FROM_EDGES

	assert_eq(stagger.resolve_order(), [0, 4, 1, 3, 2])

func test_custom_order_uses_the_explicit_index_list():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(4)
	stagger.order = _AnimaStagger.Order.CUSTOM
	stagger.custom_order = [2, 0, 3, 1]

	assert_eq(stagger.resolve_order(), [2, 0, 3, 1])

func test_random_order_includes_every_target_exactly_once():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(6)
	stagger.order = _AnimaStagger.Order.RANDOM

	var order := stagger.resolve_order()
	order.sort()
	assert_eq(order, [0, 1, 2, 3, 4, 5])

func test_estimate_duration_reports_fixed_kind_and_staggered_value():
	var stagger := _AnimaStagger.new()
	stagger.targets = _make_targets(4)
	stagger.interval = 0.1
	stagger.template = _make_template(0.5)

	var result := stagger.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(result.seconds, 0.8, 0.0001)

func test_playback_starts_targets_one_interval_apart_in_forward_order():
	var targets := _make_targets(3)
	var stagger := _AnimaStagger.new()
	stagger.targets = targets
	stagger.template = _make_template(0.3)
	stagger.interval = 0.1

	var playback := AnimaPlayback.new(stagger, null)

	playback._advance(0.05)
	assert_gt(targets[0].position.x, 0.0)
	assert_eq(targets[1].position.x, 0.0)
	assert_eq(targets[2].position.x, 0.0)

	playback._advance(0.05)
	assert_gt(targets[1].position.x, 0.0)
	assert_eq(targets[2].position.x, 0.0)

	playback._advance(0.1)
	assert_gt(targets[2].position.x, 0.0)

func test_playback_runs_every_target_through_the_template_to_completion():
	var targets := _make_targets(3)
	var stagger := _AnimaStagger.new()
	stagger.targets = targets
	stagger.template = _make_template(0.2)
	stagger.interval = 0.05

	var playback := AnimaPlayback.new(stagger, null)

	for i in range(20):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for target in targets:
		assert_almost_eq(target.position.x, 10.0, 0.01)
