extends "res://addons/gut/test.gd"

func test_from_to_produces_two_stops_at_zero_and_one():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}})

	assert_eq(motion.tracks.size(), 1)
	var track := motion.tracks[0]
	assert_eq(track.property_path, NodePath("modulate:a"))
	assert_eq(track.stops.size(), 2)
	assert_almost_eq(track.stops[0].offset, 0.0, 0.0001)
	assert_eq(track.stops[0].value, 0.0)
	assert_almost_eq(track.stops[1].offset, 1.0, 0.0001)
	assert_eq(track.stops[1].value, 1.0)

func test_percentage_offset_resolves_to_normalised_value():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({50: {"opacity": 0.5}})

	assert_almost_eq(motion.tracks[0].stops[0].offset, 0.5, 0.0001)

func test_grouped_offset_applies_the_same_values_to_every_resolved_offset():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({["from", 10]: {"opacity": 0.2}})

	var track := motion.tracks[0]
	assert_eq(track.stops.size(), 2)
	assert_almost_eq(track.stops[0].offset, 0.0, 0.0001)
	assert_eq(track.stops[0].value, 0.2)
	assert_almost_eq(track.stops[1].offset, 0.1, 0.0001)
	assert_eq(track.stops[1].value, 0.2)

func test_stops_end_up_sorted_regardless_of_declaration_order():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0}, 50: {"opacity": 0.5}, "from": {"opacity": 0.0}})

	var offsets: Array[float] = []
	for stop in motion.tracks[0].stops:
		offsets.append(stop.offset)
	assert_eq(offsets, [0.0, 0.5, 1.0])

func test_multi_property_stop_produces_one_track_per_property():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({50: {"opacity": 0.5, "position": Vector2(10.0, 0.0)}})

	assert_eq(motion.tracks.size(), 2)
	var property_paths: Array[NodePath] = []
	for track in motion.tracks:
		property_paths.append(track.property_path)
	assert_true(property_paths.has(NodePath("modulate:a")))
	assert_true(property_paths.has(NodePath("position")))

func test_semantic_names_resolve_to_canonical_paths():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {
		"opacity": 1.0, "position": Vector2.ZERO, "scale": Vector2.ONE,
		"rotation": 0.0, "color": Color.WHITE, "size": Vector2(10.0, 10.0),
	}})

	var resolved: Array[NodePath] = []
	for track in motion.tracks:
		resolved.append(track.property_path)
	assert_true(resolved.has(NodePath("modulate:a")))
	assert_true(resolved.has(NodePath("position")))
	assert_true(resolved.has(NodePath("scale")))
	assert_true(resolved.has(NodePath("rotation")))
	assert_true(resolved.has(NodePath("modulate")))
	assert_true(resolved.has(NodePath("size")))

func test_arbitrary_property_path_used_directly():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"modulate:r": 0.5}})

	assert_eq(motion.tracks[0].property_path, NodePath("modulate:r"))

func test_reserved_ease_key_sets_stop_easing():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_IN

	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0, "_ease": ease}})

	assert_eq(motion.tracks[0].stops[0].ease, ease)

func test_unrecognised_reserved_keys_are_ignored_not_treated_as_properties():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0, "_hold": true, "_marker": "hit", "_callback": Callable()}})

	assert_eq(motion.tracks.size(), 1, "only opacity should have become a track")
	assert_eq(motion.tracks[0].property_path, NodePath("modulate:a"))

func test_duplicate_offset_on_same_property_fails_validation():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0}})
	motion.at("to", {"opacity": 0.8})

	var errors := motion.validate()
	assert_true(errors.size() > 0, "duplicate stops at the same offset should be a validation error")

func test_motion_with_no_tracks_fails_validation():
	var motion := AnimaKeyframeMotion.new()
	assert_true(motion.validate().size() > 0)

func test_track_with_no_stops_fails_validation():
	var motion := AnimaKeyframeMotion.new()
	var track := AnimaKeyframeTrack.new()
	track.property_path = NodePath("modulate:a")
	motion.tracks.append(track)

	assert_true(motion.validate().size() > 0)

func test_valid_motion_has_no_validation_errors():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}})

	assert_eq(motion.validate(), [])

func test_estimate_duration_reports_fixed_duration():
	var motion := AnimaKeyframeMotion.new()
	motion.duration = 0.6

	assert_eq(motion.estimate_duration().kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(motion.estimate_duration().seconds, 0.6, 0.0001)

func test_create_runtime_returns_a_keyframe_motion_instance():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0}})

	assert_true(motion.create_runtime() is AnimaKeyframeMotionInstance)

func test_with_ease_sets_default_ease_and_returns_self():
	var motion := AnimaKeyframeMotion.new()
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_IN_OUT

	var returned := motion.with_ease(ease)

	assert_eq(returned, motion)
	assert_eq(motion.default_ease, ease)

func test_with_ease_accepts_a_bare_kind():
	var motion := AnimaKeyframeMotion.new()

	motion.with_ease(AnimaEase.Kind.EASE_IN_OUT)

	assert_eq(motion.default_ease.kind, AnimaEase.Kind.EASE_IN_OUT)

func test_with_pivot_sets_default_pivot_and_returns_self():
	var motion := AnimaKeyframeMotion.new()

	var returned := motion.with_pivot(AnimaPivot.Kind.CENTER)

	assert_eq(returned, motion)
	assert_eq(motion.default_pivot, AnimaPivot.Kind.CENTER)

func test_with_delay_sets_delay_and_returns_self():
	var motion := AnimaKeyframeMotion.new()

	var returned := motion.with_delay(0.4)

	assert_eq(returned, motion)
	assert_eq(motion.delay, 0.4)

func test_default_pivot_starts_at_none():
	var motion := AnimaKeyframeMotion.new()

	assert_eq(motion.default_pivot, AnimaPivot.Kind.NONE)

func test_pivot_reserved_key_parses_into_the_matching_stops():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({
		"from": {"scale": Vector2.ONE, "_pivot": AnimaPivot.Kind.CENTER},
		"to": {"scale": Vector2(1.1, 1.1)},
	})

	var track: AnimaKeyframeTrack = motion.tracks[0]
	assert_eq(track.stops[0].pivot, AnimaPivot.Kind.CENTER)
	assert_null(track.stops[1].pivot)

func test_create_runtime_synthesizes_a_missing_initial_stop():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0}})

	motion.create_runtime()

	var track: AnimaKeyframeTrack = motion.tracks[0]
	assert_eq(track.stops.size(), 2, "a track with only a 'to' stop should gain a synthesized starting stop")
	assert_almost_eq(track.stops[0].offset, 0.0, 0.0001)
	assert_true(track.stops[0].value is AnimaValue, "the synthesized stop's value should be a dynamic value, not a literal")
	assert_eq((track.stops[0].value as AnimaValue).kind, AnimaValue.Kind.TARGET)
	assert_null(track.stops[0].ease, "nothing arrives at the synthesized first stop, so its own ease is never consulted")

func test_create_runtime_does_not_overwrite_an_explicit_initial_stop():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"from": {"opacity": 0.25}, "to": {"opacity": 1.0}})

	motion.create_runtime()

	var track: AnimaKeyframeTrack = motion.tracks[0]
	assert_eq(track.stops.size(), 2, "an explicitly authored starting stop should never be duplicated or replaced")
	assert_eq(track.stops[0].value, 0.25)

func test_create_runtime_is_idempotent_across_replays():
	var motion := AnimaKeyframeMotion.new()
	motion.parse_dictionary({"to": {"opacity": 1.0}})

	motion.create_runtime()
	motion.create_runtime()

	assert_eq(motion.tracks[0].stops.size(), 2, "replaying the same resource should not synthesize a second starting stop")

func test_explicit_from_added_via_at_after_to_is_not_overwritten_by_synthesis():
	var motion := Motion.keyframes({"to": {"opacity": 1.0}}).at("from", {"opacity": 0.4})

	motion.create_runtime()

	var track: AnimaKeyframeTrack = motion.tracks[0]
	assert_eq(track.stops.size(), 2, "an explicit from stop added after to, before create_runtime(), should still win over synthesis")
	assert_eq(track.stops[0].value, 0.4)
