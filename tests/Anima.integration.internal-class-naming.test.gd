extends "res://addons/gut/test.gd"

func test_composite_resource_classes_are_registered_under_their_underscore_prefixed_names():
	var names: Array[String] = []
	for entry in ProjectSettings.get_global_class_list():
		names.append(entry.get("class", ""))

	for expected in ["_AnimaSequence", "_AnimaParallel", "_AnimaRepeat", "_AnimaRace", "_AnimaConditional", "_AnimaStagger"]:
		assert_has(names, expected, "%s should be the registered global class name" % expected)

	for previous in ["AnimaSequence", "AnimaParallel", "AnimaRepeat", "AnimaRace", "AnimaConditional", "AnimaStagger"]:
		assert_does_not_have(names, previous, "%s should no longer be a registered global class name" % previous)

func test_then_and_with_still_compose_and_play_correctly_after_the_rename():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())
	b.modulate.a = 1.0

	var chain := Anima.on(a).position(Vector2(30.0, 0.0), 0.05) \
		.then(Anima.on(b).opacity(0.0, 0.05))

	var playback: AnimaPlayback = chain.play()
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(a.position.x, 30.0, 0.01)
	assert_almost_eq(b.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_a_then_composition_still_reverses_correctly_after_the_rename():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position.x = 0.0

	var chain := Anima.on(node).position(Vector2(10.0, 0.0), 0.05) \
		.then(Anima.on(node).position(Vector2(20.0, 0.0), 0.05))
	var playback := Anima.play(chain, node)
	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 20.0, 0.01)

	playback.reverse()
	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.position.x, 0.0, 0.01)

func test_chaining_an_unresolvable_argument_still_reports_an_error_and_returns_self_unchanged():
	var a := AnimaPropertyMotion.new()

	var then_result := a.then("not a motion")
	assert_eq(then_result.children, [a])
	assert_push_error("needs an AnimaMotion or a factory exposing .motion")

	var b := AnimaPropertyMotion.new()
	var with_result := b.with("not a motion")
	assert_same(with_result, b)
	assert_push_error("needs an AnimaMotion or a factory exposing .motion")
