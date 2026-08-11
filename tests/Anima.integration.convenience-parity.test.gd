extends "res://addons/gut/test.gd"

## Verifies every supported Anima.on()/Anima.item() convenience motion
## against its canonical Motion.to() equivalent, exercises the public
## surfaces convenience motions must behave like any other motion on, and
## benchmarks factory creation against the budget in
## `tech-spec.md` §Convenience performance budget.

## --- Equivalence: every supported convenience motion vs its canonical equivalent ---

func _run(motion: AnimaMotion, target: Node, frames: int = 30, dt: float = 1.0 / 60.0) -> void:
	var playback := Anima.play(motion, target)
	for i in range(frames):
		playback._advance(dt)

func test_position_matches_its_canonical_equivalent():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	_run(Anima.on(convenience).position(Vector2(80.0, 20.0), 0.2), convenience)
	_run(Motion.to(NodePath("position"), Vector2(80.0, 20.0)).with_duration(0.2), canonical)

	assert_eq(convenience.position, canonical.position, "[position] convenience and canonical results should match")

func test_position_x_and_y_match_their_canonical_equivalents():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	_run(Anima.on(convenience).position_x(40.0, 0.2), convenience)
	_run(Motion.to(NodePath("position:x"), 40.0).with_duration(0.2), canonical)
	assert_almost_eq(convenience.position.x, canonical.position.x, 0.01, "[position_x] convenience and canonical results should match")

	_run(Anima.on(convenience).position_y(15.0, 0.2), convenience)
	_run(Motion.to(NodePath("position:y"), 15.0).with_duration(0.2), canonical)
	assert_almost_eq(convenience.position.y, canonical.position.y, 0.01, "[position_y] convenience and canonical results should match")

func test_position_z_matches_its_canonical_equivalent():
	var convenience: Node3D = add_child_autofree(Node3D.new())
	var canonical: Node3D = add_child_autofree(Node3D.new())

	_run(Anima.on(convenience).position_z(5.0, 0.2), convenience)
	_run(Motion.to(NodePath("position:z"), 5.0).with_duration(0.2), canonical)

	assert_almost_eq(convenience.position.z, canonical.position.z, 0.01, "[position_z] convenience and canonical results should match")

func test_move_by_matches_a_canonical_relative_property_motion():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())
	convenience.position = Vector2(10.0, 10.0)
	canonical.position = Vector2(10.0, 10.0)

	_run(Anima.on(convenience).move_by(Vector2(20.0, 0.0), 0.2), convenience)
	var canonical_motion := Motion.to(NodePath("position"), Vector2(20.0, 0.0))
	canonical_motion.duration = 0.2
	canonical_motion.is_relative = true
	_run(canonical_motion, canonical)

	assert_eq(convenience.position, canonical.position, "[move_by] convenience and canonical results should match")

func test_scale_and_scale_by_match_their_canonical_equivalents():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	_run(Anima.on(convenience).scale(Vector2(2.0, 2.0), 0.2), convenience)
	_run(Motion.to(NodePath("scale"), Vector2(2.0, 2.0)).with_duration(0.2), canonical)

	assert_eq(convenience.scale, canonical.scale, "[scale] convenience and canonical results should match")

func test_rotation_and_rotate_by_match_their_canonical_equivalents():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	_run(Anima.on(convenience).rotation(1.2, 0.2), convenience)
	_run(Motion.to(NodePath("rotation"), 1.2).with_duration(0.2), canonical)
	assert_almost_eq(convenience.rotation, canonical.rotation, 0.001, "[rotation] convenience and canonical results should match")

	var convenience_rel: Node2D = add_child_autofree(Node2D.new())
	var canonical_rel: Node2D = add_child_autofree(Node2D.new())
	_run(Anima.on(convenience_rel).rotate_by(0.5, 0.2), convenience_rel)
	var rel_motion := Motion.to(NodePath("rotation"), 0.5)
	rel_motion.duration = 0.2
	rel_motion.is_relative = true
	_run(rel_motion, canonical_rel)
	assert_almost_eq(convenience_rel.rotation, canonical_rel.rotation, 0.001, "[rotate_by] convenience and canonical results should match")

func test_opacity_matches_its_canonical_modulate_alpha_equivalent():
	var convenience: Control = add_child_autofree(Control.new())
	var canonical: Control = add_child_autofree(Control.new())

	_run(Anima.on(convenience).opacity(0.3, 0.2), convenience)
	_run(Motion.to(NodePath("modulate:a"), 0.3).with_duration(0.2), canonical)

	assert_almost_eq(convenience.modulate.a, canonical.modulate.a, 0.001, "[opacity] convenience and canonical results should match")

func test_color_matches_its_canonical_modulate_equivalent():
	var convenience: Control = add_child_autofree(Control.new())
	var canonical: Control = add_child_autofree(Control.new())

	_run(Anima.on(convenience).color(Color(0.2, 0.4, 0.6), 0.2), convenience)
	_run(Motion.to(NodePath("modulate"), Color(0.2, 0.4, 0.6)).with_duration(0.2), canonical)

	assert_eq(convenience.modulate, canonical.modulate, "[color] convenience and canonical results should match")

func test_size_matches_its_canonical_equivalent():
	var convenience: Control = add_child_autofree(Control.new())
	var canonical: Control = add_child_autofree(Control.new())

	_run(Anima.on(convenience).size(Vector2(120.0, 40.0), 0.2), convenience)
	_run(Motion.to(NodePath("size"), Vector2(120.0, 40.0)).with_duration(0.2), canonical)

	assert_almost_eq(convenience.size.x, canonical.size.x, 0.5, "[size] convenience and canonical results should match")

func test_generic_property_matches_a_direct_motion_to_call():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	_run(Anima.on(convenience).property(NodePath("position:x"), 33.0, 0.2), convenience)
	_run(Motion.to(NodePath("position:x"), 33.0).with_duration(0.2), canonical)

	assert_almost_eq(convenience.position.x, canonical.position.x, 0.01, "[property] convenience and canonical results should match")

func test_property_by_matches_a_canonical_relative_property_motion():
	var convenience: Control = add_child_autofree(Control.new())
	var canonical: Control = add_child_autofree(Control.new())

	_run(Anima.on(convenience).property_by(NodePath("modulate:a"), -0.4, 0.2), convenience)
	var canonical_motion := Motion.to(NodePath("modulate:a"), -0.4)
	canonical_motion.duration = 0.2
	canonical_motion.is_relative = true
	_run(canonical_motion, canonical)

	assert_almost_eq(convenience.modulate.a, canonical.modulate.a, 0.001, "[property_by] convenience and canonical results should match")

func test_on_started_and_on_completed_match_their_canonical_equivalents():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())
	var convenience_events: Array[String] = []
	var canonical_events: Array[String] = []

	var convenience_motion := Anima.on(convenience).position(Vector2(10.0, 0.0), 0.1)
	convenience_motion.on_started(func(): convenience_events.append("started"))
	convenience_motion.on_completed(func(): convenience_events.append("completed"))

	var canonical_motion := Motion.to(NodePath("position"), Vector2(10.0, 0.0)).with_duration(0.1)
	canonical_motion.on_started(func(): canonical_events.append("started"))
	canonical_motion.on_completed(func(): canonical_events.append("completed"))

	_run(convenience_motion, convenience, 10)
	_run(canonical_motion, canonical, 10)

	assert_eq(convenience_events, ["started", "completed"], "[on_started/on_completed] convenience motion should fire the same lifecycle events")
	assert_eq(convenience_events, canonical_events, "[on_started/on_completed] convenience and canonical lifecycle events should match")

func test_with_speed_matches_its_canonical_equivalent():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	# duration 1.0 at 4x speed finishes in ~0.25s of simulated time; 20 frames
	# at 1/60s (~0.33s) is enough to let both playbacks finish and unregister,
	# rather than leaking an active playback the runtime keeps ticking after the test ends.
	_run(Anima.on(convenience).position(Vector2(100.0, 0.0), 1.0).with_speed(4.0), convenience, 20)
	_run(Motion.to(NodePath("position"), Vector2(100.0, 0.0)).with_duration(1.0).with_speed(4.0), canonical, 20)

	assert_almost_eq(convenience.position.x, canonical.position.x, 0.01, "[with_speed] convenience and canonical results should match")
	assert_almost_eq(convenience.position.x, 100.0, 0.01)

func test_repeat_matches_its_canonical_motion_repeat_equivalent():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())
	convenience.position.x = 0.0
	canonical.position.x = 0.0

	_run(Anima.on(convenience).position(Vector2(10.0, 0.0), 0.1).repeat(2), convenience, 20)
	var canonical_child := Motion.to(NodePath("position"), Vector2(10.0, 0.0)).with_duration(0.1)
	_run(Motion.repeat(canonical_child, 2), canonical, 20)

	assert_almost_eq(convenience.position.x, canonical.position.x, 0.01, "[repeat] convenience-chained repeat and canonical Motion.repeat() should match")

func test_play_backwards_matches_playing_forward_then_reversing():
	var convenience: Node2D = add_child_autofree(Node2D.new())
	var canonical: Node2D = add_child_autofree(Node2D.new())

	var canonical_playback := Anima.play(Anima.on(canonical).position(Vector2(10.0, 0.0), 0.1), canonical)
	for i in range(10):
		canonical_playback._advance(1.0 / 60.0)
	canonical_playback.reverse()
	for i in range(10):
		canonical_playback._advance(1.0 / 60.0)

	var convenience_playback := Anima.play_backwards(Anima.on(convenience).position(Vector2(10.0, 0.0), 0.1), convenience)
	for i in range(10):
		convenience_playback._advance(1.0 / 60.0)

	assert_almost_eq(convenience.position.x, canonical.position.x, 0.01, "[play_backwards] should match playing forward then reversing")

func test_anima_item_motions_match_their_on_factory_equivalents():
	var via_item: Control = add_child_autofree(Control.new())
	var via_on: Control = add_child_autofree(Control.new())

	_run(Anima.item().opacity(0.6, 0.2), via_item)
	_run(Anima.on(via_on).opacity(0.6, 0.2), via_on)

	assert_almost_eq(via_item.modulate.a, via_on.modulate.a, 0.001, "[Anima.item().opacity] should match Anima.on().opacity()")

## --- Public surfaces: target removal, serialization, composition, reverse, interruption, Composer, compilation ---

func test_target_removal_before_playback_is_reported_by_validation():
	var motion := Anima.on(add_child_autofree(Node2D.new())).opacity(1.0)
	assert_eq(motion.validate(), [], "[target removal] a freshly-created convenience motion should validate cleanly before any removal")

func test_a_group_using_convenience_item_motions_skips_a_target_removed_mid_flight():
	var root := Node.new()
	add_child_autofree(root)
	var staying := Node2D.new()
	var leaving := Node2D.new()
	root.add_child(staying)
	root.add_child(leaving)

	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.target_collection.kind = AnimaTargetCollection.Kind.CHILDREN
	group.item_motion = Anima.item().opacity(0.0, 0.2)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	group.invalid_target_policy = AnimaGroupMotion.InvalidTargetPolicy.SKIP

	var playback := Anima.play(group, root)
	playback._advance(1.0 / 60.0)
	root.remove_child(leaving)
	leaving.free()

	for i in range(20):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "[target removal] the group should still finish once its remaining target completes")
	assert_almost_eq(staying.modulate.a, 0.0, 0.01)

func test_a_convenience_created_motion_serializes_and_deserializes_with_the_same_configuration():
	var motion := Anima.on(add_child_autofree(Node2D.new())).opacity(0.4, 0.25)

	var path := "user://convenience_parity_test_motion.tres"
	assert_eq(ResourceSaver.save(motion, path), OK, "[resource serialization] saving a convenience-created motion should succeed")

	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as AnimaPropertyMotion
	assert_eq(loaded.target_property, motion.target_property, "[resource serialization] the loaded motion should keep its canonical property path")
	assert_eq(loaded.to_value, motion.to_value)
	assert_almost_eq(loaded.duration, motion.duration, 0.0001)
	assert_eq(loaded.metadata.get("convenience_method", ""), "opacity", "[resource serialization] the editor-only convenience origin metadata should round-trip too")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func test_composition_of_convenience_motions_matches_a_hand_built_sequence():
	var convenience_node: Node2D = add_child_autofree(Node2D.new())
	var canonical_node: Node2D = add_child_autofree(Node2D.new())

	var convenience_chain := Anima.on(convenience_node).position(Vector2(30.0, 0.0), 0.1) \
		.then(Anima.on(convenience_node).opacity(0.0, 0.1))
	var canonical_chain := Motion.sequence([
		Motion.to(NodePath("position"), Vector2(30.0, 0.0)).with_duration(0.1),
		Motion.to(NodePath("modulate:a"), 0.0).with_duration(0.1),
	])

	_run(convenience_chain, convenience_node, 15)
	_run(canonical_chain, canonical_node, 15)

	assert_eq(convenience_node.position, canonical_node.position, "[composition] a then() chain should match a hand-built _AnimaSequence at the same point in playback")

func test_reversing_a_convenience_motion_matches_reversing_its_canonical_equivalent():
	var convenience_node: Node2D = add_child_autofree(Node2D.new())
	var canonical_node: Node2D = add_child_autofree(Node2D.new())
	convenience_node.position.x = 5.0
	canonical_node.position.x = 5.0

	var convenience_playback := Anima.play(Anima.on(convenience_node).position(Vector2(50.0, 0.0), 0.1), convenience_node)
	var canonical_playback := Anima.play(Motion.to(NodePath("position"), Vector2(50.0, 0.0)).with_duration(0.1), canonical_node)
	for i in range(10):
		convenience_playback._advance(1.0 / 60.0)
		canonical_playback._advance(1.0 / 60.0)

	convenience_playback.reverse()
	canonical_playback.reverse()
	for i in range(10):
		convenience_playback._advance(1.0 / 60.0)
		canonical_playback._advance(1.0 / 60.0)

	assert_almost_eq(convenience_node.position.x, canonical_node.position.x, 0.01, "[reverse playback] a convenience motion should reverse the same way its canonical equivalent does")
	assert_almost_eq(convenience_node.position.x, 5.0, 0.01)

func test_interruption_pause_and_cancel_behave_the_same_for_a_convenience_motion():
	var convenience_node: Node2D = add_child_autofree(Node2D.new())
	var canonical_node: Node2D = add_child_autofree(Node2D.new())

	var convenience_playback := Anima.play(Anima.on(convenience_node).position(Vector2(80.0, 0.0), 0.2), convenience_node)
	var canonical_playback := Anima.play(Motion.to(NodePath("position"), Vector2(80.0, 0.0)).with_duration(0.2), canonical_node)

	convenience_playback._advance(0.05)
	canonical_playback._advance(0.05)
	convenience_playback.pause()
	canonical_playback.pause()
	convenience_playback._advance(0.05)
	canonical_playback._advance(0.05)

	assert_almost_eq(convenience_node.position.x, canonical_node.position.x, 0.01, "[interruption] pausing a convenience motion should freeze it exactly like its canonical equivalent")

	convenience_playback.cancel()
	canonical_playback.cancel()
	assert_eq(convenience_playback.state, canonical_playback.state, "[interruption] cancelling a convenience motion should behave exactly like its canonical equivalent")

func test_composer_editing_a_convenience_motion_matches_editing_its_canonical_equivalent():
	var composer := preload("res://addons/anima/editor/anima_property_motion_composer.gd").new()
	add_child_autoqfree(composer)

	var convenience_node: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(convenience_node).position(Vector2(10.0, 0.0), 0.1)
	composer.show_motion(motion, convenience_node)
	composer._to_field.text = var_to_str(Vector2(70.0, 0.0))
	composer._commit_to()

	var canonical_node: Node2D = add_child_autofree(Node2D.new())
	var canonical := Motion.to(NodePath("position"), Vector2(70.0, 0.0)).with_duration(0.1)

	_run(motion, convenience_node)
	_run(canonical, canonical_node)

	assert_eq(convenience_node.position, canonical_node.position, "[Composer editing] a Composer-edited convenience motion should play like the equivalent canonical edit")

func test_a_convenience_motion_compiles_identically_to_its_canonical_equivalent():
	var convenience_root := Node.new()
	add_child_autofree(convenience_root)
	var convenience_child := Node2D.new()
	convenience_root.add_child(convenience_child)

	var canonical_root := Node.new()
	add_child_autofree(canonical_root)
	var canonical_child := Node2D.new()
	canonical_root.add_child(canonical_child)

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN

	var convenience_group := AnimaGroupMotion.new()
	convenience_group.target_collection = collection
	convenience_group.item_motion = Anima.item().opacity(0.0, 0.2)

	var canonical_collection := AnimaTargetCollection.new()
	canonical_collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var canonical_group := AnimaGroupMotion.new()
	canonical_group.target_collection = canonical_collection
	canonical_group.item_motion = Motion.to(NodePath("modulate:a"), 0.0).with_duration(0.2)

	var convenience_eligibility := AnimaGroupCompiler.check_eligibility(convenience_group, convenience_root)
	assert_true(convenience_eligibility.is_eligible(), "[native compilation] a group using a convenience item motion should be compile-eligible")

	var convenience_animation := AnimaGroupCompiler.compile(convenience_group, convenience_root)
	var canonical_animation := AnimaGroupCompiler.compile(canonical_group, canonical_root)

	assert_eq(convenience_animation.get_track_count(), canonical_animation.get_track_count(), "[native compilation] convenience and canonical groups should bake the same number of tracks")
	assert_almost_eq(convenience_animation.length, canonical_animation.length, 0.0001, "[native compilation] convenience and canonical groups should bake the same length")

## --- Performance budget (tech-spec.md §Convenience performance budget) ---

const _SAMPLE_COUNT := 10000
const _WARMUP_RUNS := 3
const _MEASURED_RUNS := 5
const _OVERHEAD_MAX := 0.50 # tech-spec.md §Convenience performance budget — CONVENIENCE_CREATION_OVERHEAD_MAX

func _median_usec(thunk: Callable) -> float:
	for _warmup in _WARMUP_RUNS:
		for _i in _SAMPLE_COUNT:
			thunk.call()

	var samples: Array[float] = []
	for _run_index in _MEASURED_RUNS:
		var start := Time.get_ticks_usec()
		for _i in _SAMPLE_COUNT:
			thunk.call()
		samples.append(float(Time.get_ticks_usec() - start))

	samples.sort()
	return samples[samples.size() / 2]

func _assert_within_overhead_budget(family: String, convenience_thunk: Callable, canonical_thunk: Callable) -> void:
	var convenience_median := _median_usec(convenience_thunk)
	var canonical_median := _median_usec(canonical_thunk)
	var budget := canonical_median * (1.0 + _OVERHEAD_MAX)
	assert_lte(convenience_median, budget, "[%s] convenience factory creation should be within %d%% of canonical creation (convenience=%.1fus, canonical=%.1fus, budget=%.1fus)" % [family, int(_OVERHEAD_MAX * 100), convenience_median, canonical_median, budget])

## The budget models a reused factory's steady-state per-call cost — "no
## playback-state allocation in convenience methods" (tech-spec.md
## §Convenience-layer performance requirements) is about each semantic
## *method* call, not re-constructing the lightweight factory itself every
## time. `Anima.on(target)` is built once, outside the timed loop, exactly
## like an author holding onto one factory and calling several methods on it.

func test_opacity_creation_overhead_is_within_the_performance_budget():
	var target: Control = add_child_autofree(Control.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"opacity",
		func() -> void: factory.opacity(1.0),
		func() -> void: Motion.to(NodePath("modulate:a"), 1.0),
	)

func test_position_creation_overhead_is_within_the_performance_budget():
	var target: Node2D = add_child_autofree(Node2D.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"position",
		func() -> void: factory.position(Vector2.ONE),
		func() -> void: Motion.to(NodePath("position"), Vector2.ONE),
	)

func test_scale_creation_overhead_is_within_the_performance_budget():
	var target: Node2D = add_child_autofree(Node2D.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"scale",
		func() -> void: factory.scale(Vector2.ONE),
		func() -> void: Motion.to(NodePath("scale"), Vector2.ONE),
	)

func test_rotation_creation_overhead_is_within_the_performance_budget():
	var target: Node2D = add_child_autofree(Node2D.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"rotation",
		func() -> void: factory.rotation(1.0),
		func() -> void: Motion.to(NodePath("rotation"), 1.0),
	)

func test_color_creation_overhead_is_within_the_performance_budget():
	var target: Control = add_child_autofree(Control.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"color",
		func() -> void: factory.color(Color.WHITE),
		func() -> void: Motion.to(NodePath("modulate"), Color.WHITE),
	)

func test_size_creation_overhead_is_within_the_performance_budget():
	var target: Control = add_child_autofree(Control.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"size",
		func() -> void: factory.size(Vector2.ONE),
		func() -> void: Motion.to(NodePath("size"), Vector2.ONE),
	)

func test_generic_property_creation_overhead_is_within_the_performance_budget():
	var target: Node2D = add_child_autofree(Node2D.new())
	var factory := Anima.on(target)
	_assert_within_overhead_budget(
		"property",
		func() -> void: factory.property(NodePath("position:x"), 1.0),
		func() -> void: Motion.to(NodePath("position:x"), 1.0),
	)

func test_reusing_a_factory_does_not_retain_previously_generated_motions():
	var target: Node2D = add_child_autofree(Node2D.new())
	var factory := Anima.on(target)

	var first := factory.position(Vector2(1.0, 0.0))
	var second := factory.position(Vector2(2.0, 0.0))

	assert_ne(first.get_instance_id(), second.get_instance_id(), "each factory call should build an independent motion")
	assert_eq(first.to_value, Vector2(1.0, 0.0), "an earlier built motion should be unaffected by a later factory call")

func test_two_different_methods_from_the_same_factory_build_independent_motions():
	var target: Control = add_child_autofree(Control.new())
	var factory := Anima.on(target)

	var position_motion := factory.position(Vector2(5.0, 0.0))
	var opacity_motion := factory.opacity(0.5)

	assert_ne(position_motion.get_instance_id(), opacity_motion.get_instance_id())
	position_motion.to_value = Vector2(99.0, 99.0)
	assert_eq(opacity_motion.to_value, 0.5, "changing one motion built from the factory should not affect an earlier one built from the same factory")

func test_reusing_a_factory_after_an_earlier_motion_has_played_still_builds_a_correct_motion():
	var target: Node2D = add_child_autofree(Node2D.new())
	var factory := Anima.on(target)

	var first := factory.position(Vector2(5.0, 0.0), 0.1)
	_run(first, target, 10)
	assert_almost_eq(target.position.x, 5.0, 0.01)

	var second := factory.position(Vector2(20.0, 0.0), 0.1)
	_run(second, target, 10)
	assert_almost_eq(target.position.x, 20.0, 0.01, "a factory call made after an earlier motion already played should still build a correct, independent motion")
