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

func test_defaults_to_euclidean_distance_formula():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)

	assert_eq(factory.motion.distance_formula, AnimaGridMotion.DistanceFormula.EUCLIDEAN)

func test_with_dimensions_auto_derives_a_centred_start_point():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container).with_dimensions(Vector2i(4, 4))

	assert_eq(factory.motion.start_point, Vector2i(2, 2))

func test_with_dimensions_floors_an_odd_dimension_to_the_middle_index():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container).with_dimensions(Vector2i(5, 5))

	assert_eq(factory.motion.start_point, Vector2i(2, 2), "5/2 should floor to 2, not round up to 3")

func test_explicit_start_point_set_before_with_dimensions_is_not_overwritten():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_start_point(Vector2i(1, 1)) \
		.with_dimensions(Vector2i(4, 4))

	assert_eq(factory.motion.start_point, Vector2i(1, 1))

func test_explicit_start_point_set_after_with_dimensions_is_not_later_overwritten():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_dimensions(Vector2i(4, 4)) \
		.with_start_point(Vector2i(0, 0)) \
		.with_dimensions(Vector2i(6, 6))

	assert_eq(factory.motion.start_point, Vector2i(0, 0), "a later with_dimensions() call should not re-derive over an explicit start point")

func _node_with_script(source: String) -> Node:
	var script := GDScript.new()
	script.source_code = source
	script.reload()
	var node := Node.new()
	node.set_script(script)
	return node

func test_grid_size_vector2i_sets_dimensions_directly():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container, Vector2i(9, 5))

	assert_eq(factory.motion.grid_dimensions, Vector2i(9, 5))
	assert_eq(factory.motion.start_point, Vector2i(4, 2), "explicit grid_size should still auto-derive a centred start point")

func test_grid_size_vector2_floors_to_whole_cells():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container, Vector2(9.7, 5.2))

	assert_eq(factory.motion.grid_dimensions, Vector2i(9, 5), "a fractional size should floor, never round up past what fits")

func test_grid_size_omitted_infers_from_containers_own_rows_and_columns():
	var container := _node_with_script("extends Node\nvar rows: int = 3\nvar columns: int = 4\n")
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container)

	assert_eq(factory.motion.grid_dimensions, Vector2i(4, 3))

func test_grid_size_omitted_infers_rows_from_grid_container_columns_and_child_count():
	var container := GridContainer.new()
	container.columns = 3
	add_child_autofree(container)
	for i in 7:
		container.add_child(Node.new())

	var factory := AnimaGridMotionFactory.new(container)

	assert_eq(factory.motion.grid_dimensions, Vector2i(3, 3), "7 children at 3 columns should round up to 3 rows")

func test_grid_size_omitted_falls_back_to_a_single_column_of_containers_children():
	var container := Node.new()
	add_child_autofree(container)
	for i in 5:
		container.add_child(Node.new())

	var factory := AnimaGridMotionFactory.new(container)

	assert_eq(factory.motion.grid_dimensions, Vector2i(1, 5))

func test_grid_size_node_infers_from_that_node_but_child_count_from_container():
	var container := Node.new()
	add_child_autofree(container)
	for i in 8:
		container.add_child(Node.new())
	var layout := GridContainer.new()
	layout.columns = 4
	add_child_autofree(layout)

	var factory := AnimaGridMotionFactory.new(container, layout)

	assert_eq(factory.motion.grid_dimensions, Vector2i(4, 2), "rows should come from container's own 8 children at 4 columns, not layout's own (empty) children")

func test_grid_size_invalid_type_reports_an_error_and_falls_back_to_inference():
	var container := Node.new()
	add_child_autofree(container)
	for i in 3:
		container.add_child(Node.new())

	var factory := AnimaGridMotionFactory.new(container, "not-a-valid-grid-size")

	assert_eq(factory.motion.grid_dimensions, Vector2i(1, 3), "an invalid grid_size should still resolve via the same fallback as omitting it")
	assert_push_error("grid_size")

func test_grid_size_presets_stay_chainable_with_other_factory_methods():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container, Vector2i(4, 4)) \
		.radial() \
		.with_start_point(Vector2i(0, 0)) \
		.with_item_motion(Anima.item().opacity(0.0, 0.1))

	assert_eq(factory.motion.distance_formula, AnimaGridMotion.DistanceFormula.EUCLIDEAN)
	assert_eq(factory.motion.start_point, Vector2i(0, 0))
	assert_not_null(factory.motion.item_motion)

func test_distance_formula_presets_match_with_distance_formula():
	var container := Node.new()
	add_child_autofree(container)

	var expected := {
		"radial": AnimaGridMotion.DistanceFormula.EUCLIDEAN,
		"diamond": AnimaGridMotion.DistanceFormula.MANHATTAN,
		"box": AnimaGridMotion.DistanceFormula.CHEBYSHEV,
		"by_row": AnimaGridMotion.DistanceFormula.ROW,
		"by_column": AnimaGridMotion.DistanceFormula.COLUMN,
		"diagonal": AnimaGridMotion.DistanceFormula.DIAGONAL,
		"anti_diagonal": AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL,
		"clockwise": AnimaGridMotion.DistanceFormula.CLOCKWISE,
		"counter_clockwise": AnimaGridMotion.DistanceFormula.ANTICLOCKWISE,
		"spiral_in": AnimaGridMotion.DistanceFormula.SPIRAL_INWARD,
		"spiral_out": AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD,
		"serpentine_row": AnimaGridMotion.DistanceFormula.SERPENTINE_ROW,
		"serpentine_column": AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN,
	}

	for method_name in expected:
		var factory := AnimaGridMotionFactory.new(container)
		factory.call(method_name)
		assert_eq(factory.motion.distance_formula, expected[method_name], "%s() should set distance_formula the same way with_distance_formula() would" % method_name)

func test_preset_with_no_item_motion_set_plays_successfully():
	var container := Node.new()
	add_child_autofree(container)
	container.add_child(Node2D.new())

	var playback := AnimaGridMotionFactory.new(container).diagonal().play()

	assert_not_null(playback, "a preset should supply a default item motion so play() doesn't need one configured first")

func test_preset_default_item_motion_uses_default_duration_and_ease():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container).clockwise()

	var item_motion := factory.motion.item_motion as AnimaKeyframeMotion
	assert_not_null(item_motion, "preset should have built a keyframe item motion by default")
	assert_almost_eq(item_motion.duration, AnimaGridMotionFactory.DEFAULT_DURATION, 0.0001)
	assert_eq(item_motion.default_ease.kind, AnimaGridMotionFactory.DEFAULT_EASE)

func test_preset_does_not_overwrite_an_explicitly_set_item_motion():
	var container := Node.new()
	add_child_autofree(container)
	var explicit_motion := Anima.item().opacity(0.0, 0.1)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_item_motion(explicit_motion) \
		.diagonal()

	assert_eq(factory.motion.item_motion, explicit_motion, "a preset should never replace an item motion set before it was called")

func test_grid_with_no_preset_and_no_item_motion_still_reports_the_existing_error():
	var container := Node.new()
	add_child_autofree(container)

	var playback := AnimaGridMotionFactory.new(container).play()

	assert_null(playback)
	assert_push_error("with_item_motion")

func test_with_distance_formula_directly_does_not_supply_a_default_item_motion():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGridMotionFactory.new(container) \
		.with_distance_formula(AnimaGridMotion.DistanceFormula.DIAGONAL)

	assert_null(factory.motion.item_motion, "with_distance_formula() is not a named preset, so it should not supply the default item motion")
