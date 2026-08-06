extends "res://addons/gut/test.gd"

func test_targets_the_containers_children():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)

	assert_eq(factory.motion.target_collection.kind, AnimaTargetCollection.Kind.CHILDREN)

func test_chain_methods_set_the_matching_grid_motion_fields():
	var container := Node.new()
	add_child_autofree(container)
	var item_motion := Anima.item().opacity(0.0, 0.1)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_item_motion(item_motion) \
		.with_dimensions(Vector2i(4, 5)) \
		.with_distance_formula(AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD) \
		.with_start_point(Vector2i(1, 2)) \
		.with_stagger_interval(0.25)

	assert_eq(factory.motion.item_motion, item_motion)
	assert_eq(factory.motion.grid_dimensions, Vector2i(4, 5))
	assert_eq(factory.motion.distance_formula, AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD)
	assert_eq(factory.motion.start_point, Vector2i(1, 2))
	assert_almost_eq(factory.motion.distribution.stagger_interval, 0.25, 0.0001)

func test_play_with_no_item_motion_reports_an_error_and_returns_null():
	var container := Node.new()
	add_child_autofree(container)

	var playback := AnimaGridMotionFactory.new(container).play()

	assert_null(playback)
	assert_push_error("with_item_motion")

func test_play_returns_a_running_playback_against_the_container():
	var container := Node.new()
	add_child_autofree(container)
	var cell := Node2D.new()
	container.add_child(cell)

	var playback := AnimaGridMotionFactory.new(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.play()

	assert_not_null(playback)
	assert_eq(playback.target, container)

func test_keyframes_builds_a_keyframe_item_motion_and_returns_the_factory():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)
	var returned := factory.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}, 0.4)

	assert_eq(returned, factory, "keyframes() should return the factory itself, not the built motion")
	assert_true(factory.motion.item_motion is AnimaKeyframeMotion)
	assert_almost_eq((factory.motion.item_motion as AnimaKeyframeMotion).duration, 0.4, 0.0001)

func test_keyframes_stays_chainable_into_further_calls_and_play():
	var container := Node.new()
	add_child_autofree(container)
	var cell := Node2D.new()
	container.add_child(cell)

	var playback := AnimaGridMotionFactory.new(container) \
		.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}, 0.1) \
		.with_dimensions(Vector2i(1, 1)) \
		.play()

	assert_not_null(playback, "keyframes() should stay chainable through with_dimensions() and into play()")

func test_with_duration_and_with_ease_set_fields_on_a_property_item_motion():
	var container := Node.new()
	add_child_autofree(container)
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_IN_OUT

	var factory := AnimaGridMotionFactory.new(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.0)) \
		.with_duration(0.6) \
		.with_ease(ease)

	var item_motion := factory.motion.item_motion as AnimaPropertyMotion
	assert_almost_eq(item_motion.duration, 0.6, 0.0001)
	assert_eq(item_motion.ease, ease)

func test_with_duration_and_with_ease_set_fields_on_a_keyframe_item_motion():
	var container := Node.new()
	add_child_autofree(container)
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_IN_OUT

	var factory := AnimaGridMotionFactory.new(container) \
		.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}) \
		.with_duration(0.6) \
		.with_ease(ease)

	var item_motion := factory.motion.item_motion as AnimaKeyframeMotion
	assert_almost_eq(item_motion.duration, 0.6, 0.0001)
	assert_eq(item_motion.default_ease, ease)

func test_with_duration_with_no_item_motion_reports_an_error_and_stays_chainable():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)
	var returned := factory.with_duration(0.5)

	assert_eq(returned, factory, "with_duration() should still return the factory even when it can't apply")
	assert_push_error("requires an item motion")

func test_with_ease_with_no_item_motion_reports_an_error_and_stays_chainable():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)
	var returned := factory.with_ease(AnimaEase.new())

	assert_eq(returned, factory, "with_ease() should still return the factory even when it can't apply")
	assert_push_error("requires an item motion")

func test_with_duration_against_an_incompatible_item_motion_reports_an_error():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_item_motion(Motion.sequence([Anima.item().opacity(0.0, 0.1)]))
	factory.with_duration(0.5)

	assert_push_error("only applies to a property or keyframe item motion")

func test_with_ease_accepts_a_bare_kind():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}) \
		.with_ease(AnimaEase.Kind.EASE_IN_OUT)

	var item_motion := factory.motion.item_motion as AnimaKeyframeMotion
	assert_eq(item_motion.default_ease.kind, AnimaEase.Kind.EASE_IN_OUT)

func test_with_pivot_sets_pivot_on_a_property_item_motion():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.0)) \
		.with_pivot(AnimaPropertyMotion.Pivot.CENTER)

	var item_motion := factory.motion.item_motion as AnimaPropertyMotion
	assert_eq(item_motion.pivot, AnimaPropertyMotion.Pivot.CENTER)

func test_with_pivot_sets_default_pivot_on_a_keyframe_item_motion():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.keyframes({"from": {"scale": Vector2.ONE}, "to": {"scale": Vector2(1.1, 1.1)}}) \
		.with_pivot(AnimaPropertyMotion.Pivot.CENTER)

	var item_motion := factory.motion.item_motion as AnimaKeyframeMotion
	assert_eq(item_motion.default_pivot, AnimaPropertyMotion.Pivot.CENTER)

func test_with_pivot_with_no_item_motion_reports_an_error_and_stays_chainable():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)
	var returned := factory.with_pivot(AnimaPropertyMotion.Pivot.CENTER)

	assert_eq(returned, factory, "with_pivot() should still return the factory even when it can't apply")
	assert_push_error("requires an item motion")
