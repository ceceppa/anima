extends "res://addons/gut/test.gd"

func _tracks_signature(motion: AnimaKeyframeMotion) -> Array:
	var signature := []
	for track in motion.tracks:
		var stops := []
		for stop in track.stops:
			stops.append([stop.offset, stop.value])
		signature.append([track.property_path, stops])
	return signature

func test_dictionary_and_fluent_forms_produce_equivalent_tracks():
	var dictionary_form := Motion.keyframes({
		"from": {"opacity": 0.0},
		50: {"opacity": 1.0, "scale": Vector2(1.2, 1.2)},
		"to": {"opacity": 1.0, "scale": Vector2.ONE},
	})
	var fluent_form := Motion.keyframes() \
		.at("from", {"opacity": 0.0}) \
		.at(50, {"opacity": 1.0, "scale": Vector2(1.2, 1.2)}) \
		.at("to", {"opacity": 1.0, "scale": Vector2.ONE})

	assert_eq(_tracks_signature(dictionary_form), _tracks_signature(fluent_form))

func test_anima_on_keyframes_matches_motion_keyframes_dictionary_form():
	var node := Node2D.new()
	autofree(node)

	var via_on := Anima.on(node).keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}, 0.6)
	var via_motion := Motion.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}})

	assert_eq(_tracks_signature(via_on), _tracks_signature(via_motion))
	assert_almost_eq(via_on.duration, 0.6, 0.0001)

func test_at_merges_a_new_offset_into_an_existing_track():
	var motion := Motion.keyframes({"from": {"opacity": 0.0}})
	motion.at("to", {"opacity": 1.0})

	assert_eq(motion.tracks.size(), 1)
	assert_eq(motion.tracks[0].stops.size(), 2)
	assert_almost_eq(motion.tracks[0].stops[1].offset, 1.0, 0.0001)

func test_with_duration_sets_duration_directly():
	var motion := Motion.keyframes().with_duration(0.8)

	assert_almost_eq(motion.duration, 0.8, 0.0001)
