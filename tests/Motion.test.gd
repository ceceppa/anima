extends "res://addons/gut/test.gd"

func _make_leaf(property: String, to_value: float, duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property)
	motion.to_value = to_value
	motion.duration = duration
	return motion

func _run_side_by_side(direct: AnimaMotion, built: AnimaMotion, frames: int, delta: float) -> Array:
	var node_direct := Node2D.new()
	autofree(node_direct)
	var node_built := Node2D.new()
	autofree(node_built)

	var playback_direct := AnimaPlayback.new(direct, node_direct)
	var playback_built := AnimaPlayback.new(built, node_built)

	for i in range(frames):
		playback_direct._advance(delta)
		playback_built._advance(delta)

	return [node_direct, node_built, playback_direct, playback_built]

func test_sequence_factory_plays_identically_to_direct_construction():
	var direct := AnimaSequence.new()
	direct.children = [_make_leaf("position:x", 10.0, 0.3), _make_leaf("position:y", 20.0, 0.3)]
	var built := Motion.sequence([_make_leaf("position:x", 10.0, 0.3), _make_leaf("position:y", 20.0, 0.3)])

	var result := _run_side_by_side(direct, built, 10, 0.1)
	assert_eq(result[2].state, result[3].state)
	assert_almost_eq(result[0].position.x, result[1].position.x, 0.0001)
	assert_almost_eq(result[0].position.y, result[1].position.y, 0.0001)
	assert_eq(result[3].state, AnimaPlayback.State.FINISHED)

func test_parallel_factory_plays_identically_to_direct_construction():
	var direct := AnimaParallel.new()
	direct.children = [_make_leaf("position:x", 10.0, 0.3), _make_leaf("position:y", 20.0, 0.3)]
	var built := Motion.parallel([_make_leaf("position:x", 10.0, 0.3), _make_leaf("position:y", 20.0, 0.3)])

	var result := _run_side_by_side(direct, built, 5, 0.1)
	assert_almost_eq(result[0].position.x, result[1].position.x, 0.0001)
	assert_almost_eq(result[0].position.y, result[1].position.y, 0.0001)

func test_stagger_factory_plays_identically_to_direct_construction():
	var direct := AnimaStagger.new()
	direct.template = _make_leaf("position:x", 10.0, 0.2)
	direct.targets = [Node2D.new(), Node2D.new()]
	direct.interval = 0.05
	for t in direct.targets:
		autofree(t)

	var template := _make_leaf("position:x", 10.0, 0.2)
	var targets: Array[Node] = [Node2D.new(), Node2D.new()]
	for t in targets:
		autofree(t)
	var built := Motion.stagger(targets, template, 0.05)

	assert_eq(built.interval, direct.interval)
	assert_eq(built.targets.size(), direct.targets.size())

	var playback_direct := AnimaPlayback.new(direct, null)
	var playback_built := AnimaPlayback.new(built, null)
	for i in range(20):
		playback_direct._advance(0.02)
		playback_built._advance(0.02)

	assert_eq(playback_direct.state, playback_built.state)
	assert_eq(playback_built.state, AnimaPlayback.State.FINISHED)
	for i in range(direct.targets.size()):
		assert_almost_eq(direct.targets[i].position.x, built.targets[i].position.x, 0.0001)

func test_repeat_factory_plays_identically_to_direct_construction():
	var direct := AnimaRepeat.new()
	direct.child = _make_leaf("position:x", 10.0, 0.2)
	direct.count = 2

	var built := Motion.repeat(_make_leaf("position:x", 10.0, 0.2), 2)

	var result := _run_side_by_side(direct, built, 25, 0.02)
	assert_eq(result[2].state, result[3].state)
	assert_eq(result[3].state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(result[0].position.x, result[1].position.x, 0.0001)

func test_race_factory_plays_identically_to_direct_construction():
	var direct := AnimaRace.new()
	direct.children = [_make_leaf("position:x", 10.0, 0.2), _make_leaf("position:y", 20.0, 1.0)]
	var built := Motion.race([_make_leaf("position:x", 10.0, 0.2), _make_leaf("position:y", 20.0, 1.0)])

	var result := _run_side_by_side(direct, built, 10, 0.02)
	assert_eq(result[2].state, result[3].state)
	assert_eq(result[3].state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(result[0].position.x, result[1].position.x, 0.0001)

func test_conditional_factory_plays_identically_to_direct_construction():
	var condition_fn := func(): return true

	var direct := AnimaConditional.new()
	direct.condition = condition_fn
	direct.when_true = _make_leaf("position:x", 10.0, 0.3)
	direct.when_false = _make_leaf("position:y", 20.0, 0.3)

	var built := Motion.conditional(condition_fn, _make_leaf("position:x", 10.0, 0.3), _make_leaf("position:y", 20.0, 0.3))

	var result := _run_side_by_side(direct, built, 5, 0.1)
	assert_eq(result[2].state, result[3].state)
	assert_almost_eq(result[0].position.x, result[1].position.x, 0.0001)

func test_to_with_chained_duration_and_ease_matches_direct_construction():
	var custom_ease := AnimaEase.new()
	custom_ease.kind = AnimaEase.Kind.SINE

	var direct := AnimaPropertyMotion.new()
	direct.target_property = NodePath("position:x")
	direct.to_value = 10.0
	direct.duration = 0.4
	direct.ease = custom_ease

	var built := Motion.to(NodePath("position:x"), 10.0).with_duration(0.4).with_ease(custom_ease)

	assert_eq(built.target_property, direct.target_property)
	assert_eq(built.to_value, direct.to_value)
	assert_eq(built.duration, direct.duration)
	assert_eq(built.ease, direct.ease)
