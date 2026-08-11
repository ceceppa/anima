extends "res://addons/gut/test.gd"

func test_group_animates_exactly_the_explicit_array_of_targets():
	var picked_a: Node2D = add_child_autofree(Node2D.new())
	var picked_b: Node2D = add_child_autofree(Node2D.new())
	var not_picked: Node2D = add_child_autofree(Node2D.new())
	picked_a.modulate.a = 1.0
	picked_b.modulate.a = 1.0
	not_picked.modulate.a = 1.0

	var playback: AnimaPlayback = Anima.group([picked_a, picked_b]) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.play()

	assert_not_null(playback)
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(picked_a.modulate.a, 0.0, 0.01)
	assert_almost_eq(picked_b.modulate.a, 0.0, 0.01)
	assert_almost_eq(not_picked.modulate.a, 1.0, 0.01, "a node outside the explicit array must not be touched")

func test_group_with_null_or_an_invalid_type_reports_an_error_and_returns_null():
	assert_null(Anima.group(null))
	assert_push_error("requires a Node or an Array")

	assert_null(Anima.group("not valid"))
	assert_push_error("requires a Node or an Array")

func test_group_animates_every_child_of_a_container():
	var container := Node.new()
	add_child_autofree(container)
	var children: Array[Node2D] = []
	for i in 4:
		var child := Node2D.new()
		child.modulate.a = 1.0
		container.add_child(child)
		children.append(child)

	var factory := Anima.group(container).with_item_motion(Anima.item().opacity(0.0, 0.05))
	factory.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	var playback: AnimaPlayback = factory.play()

	assert_not_null(playback)
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for child in children:
		assert_almost_eq(child.modulate.a, 0.0, 0.01)

func test_group_keyframes_with_duration_and_ease_plays_a_fully_configured_item_motion():
	var container := Node.new()
	add_child_autofree(container)
	var child: Node2D = Node2D.new()
	child.modulate.a = 1.0
	container.add_child(child)

	var playback: AnimaPlayback = Anima.group(container) \
		.keyframes({"to": {"opacity": 0.0}}, 0.3) \
		.with_ease(AnimaEase.Kind.EASE_IN_OUT) \
		.play()

	assert_not_null(playback)
	for i in range(20):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(child.modulate.a, 0.0, 0.01)

func test_group_with_delay_does_not_start_until_the_delay_elapses():
	var container := Node.new()
	add_child_autofree(container)
	var child: Node2D = Node2D.new()
	child.modulate.a = 1.0
	container.add_child(child)

	var playback: AnimaPlayback = Anima.group(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.with_delay(1.0) \
		.play()

	playback._advance(0.5)
	assert_almost_eq(child.modulate.a, 1.0, 0.01, "the group should not have started animating before its delay elapsed")

	for i in range(40):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(child.modulate.a, 0.0, 0.01)

func test_group_on_started_and_on_completed_fire_when_playback_starts_and_finishes():
	var container := Node.new()
	add_child_autofree(container)
	var child := Node2D.new()
	container.add_child(child)
	var started_count := [0]
	var completed_count := [0]

	var playback: AnimaPlayback = Anima.group(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.on_started(func(): started_count[0] += 1) \
		.on_completed(func(): completed_count[0] += 1) \
		.play()

	assert_eq(started_count[0], 1)
	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_eq(completed_count[0], 1)

func test_group_then_on_plays_the_group_then_a_different_node():
	var container := Node.new()
	add_child_autofree(container)
	var child: Node2D = Node2D.new()
	container.add_child(child)
	var other: Node2D = add_child_autofree(Node2D.new())
	other.modulate.a = 1.0

	var factory := Anima.group(container).with_item_motion(Anima.item().opacity(0.0, 0.05))
	factory.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	var playback: AnimaPlayback = factory.then(Anima.on(other).fade_out(0.05)).play()

	assert_not_null(playback)
	for i in range(2):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(other.modulate.a, 1.0, 0.01, "the fade should not have started until the group step finished")

	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(other.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_group_with_a_grid_factory_directly_plays_both():
	var container := Node.new()
	add_child_autofree(container)
	var child: Node2D = Node2D.new()
	container.add_child(child)
	var grid_root := Node.new()
	add_child_autofree(grid_root)
	for i in 4:
		grid_root.add_child(Node2D.new())

	var playback: AnimaPlayback = Anima.group(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.with(Anima.grid(grid_root, Vector2i(2, 2)).with_item_motion(Anima.item().opacity(0.0, 0.05))) \
		.play()

	assert_not_null(playback)
	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_group_play_with_no_item_motion_reports_an_error_and_returns_null():
	var container := Node.new()
	add_child_autofree(container)

	assert_null(Anima.group(container).play())
	assert_push_error("requires with_item_motion")
