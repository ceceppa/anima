extends "res://addons/gut/test.gd"

const _MIRROR_PAIRS := [
	[AnimaEase.Kind.EASE_IN, AnimaEase.Kind.EASE_OUT],
	[AnimaEase.Kind.EASE_IN_SINE, AnimaEase.Kind.EASE_OUT_SINE],
	[AnimaEase.Kind.EASE_IN_QUAD, AnimaEase.Kind.EASE_OUT_QUAD],
	[AnimaEase.Kind.EASE_IN_CUBIC, AnimaEase.Kind.EASE_OUT_CUBIC],
	[AnimaEase.Kind.EASE_IN_QUART, AnimaEase.Kind.EASE_OUT_QUART],
	[AnimaEase.Kind.EASE_IN_QUINT, AnimaEase.Kind.EASE_OUT_QUINT],
	[AnimaEase.Kind.EASE_IN_EXPO, AnimaEase.Kind.EASE_OUT_EXPO],
	[AnimaEase.Kind.EASE_IN_CIRC, AnimaEase.Kind.EASE_OUT_CIRC],
	[AnimaEase.Kind.EASE_IN_BACK, AnimaEase.Kind.EASE_OUT_BACK],
	[AnimaEase.Kind.EASE_IN_ELASTIC, AnimaEase.Kind.EASE_OUT_ELASTIC],
	[AnimaEase.Kind.EASE_IN_BOUNCE, AnimaEase.Kind.EASE_OUT_BOUNCE],
]

func test_every_named_in_out_pair_mirrors_to_its_opposite():
	for pair in _MIRROR_PAIRS:
		var ease_in := AnimaEase.new()
		ease_in.kind = pair[0]
		assert_eq(ease_in.mirrored().kind, pair[1], "%s should mirror to %s" % [pair[0], pair[1]])

		var ease_out := AnimaEase.new()
		ease_out.kind = pair[1]
		assert_eq(ease_out.mirrored().kind, pair[0], "%s should mirror to %s" % [pair[1], pair[0]])

func test_kinds_with_no_mirror_are_unaffected():
	for kind in [AnimaEase.Kind.LINEAR, AnimaEase.Kind.EASE_IN_OUT, AnimaEase.Kind.EASE_IN_OUT_SINE, AnimaEase.Kind.SPRING, AnimaEase.Kind.CUBIC_BEZIER]:
		var ease := AnimaEase.new()
		ease.kind = kind
		assert_eq(ease.mirrored().kind, kind)

func test_mirrored_preserves_every_other_field():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_IN_ELASTIC
	ease.elastic_amplitude = 2.5
	ease.elastic_period = 0.42

	var mirrored := ease.mirrored()
	assert_almost_eq(mirrored.elastic_amplitude, 2.5, 0.0001)
	assert_almost_eq(mirrored.elastic_period, 0.42, 0.0001)

func test_mirrored_does_not_mutate_the_original():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_IN

	ease.mirrored()
	assert_eq(ease.kind, AnimaEase.Kind.EASE_IN)
