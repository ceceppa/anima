extends "res://addons/gut/test.gd"

const TARGET_COUNT := 256
const TICK_SECONDS := 0.01
const MAX_TICKS := 1024

func _make_group(root: Node, mode: AnimaGroupMotion.PlaybackMode) -> AnimaGroupMotion:
	for _index in TARGET_COUNT:
		root.add_child(Node2D.new())
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var item := Motion.to(NodePath("position:x"), 10.0).with_duration(0.001)
	item.from_value = 0.0
	var group := Motion.group(collection, item)
	group.playback_mode = mode
	group.distribution.stagger_interval = 0.002
	return group

func _run_benchmark(label: String, mode: AnimaGroupMotion.PlaybackMode) -> int:
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, mode)
	var started_at := Time.get_ticks_usec()
	var playback := Anima.play(group, root)
	var ticks := 0
	while playback.state == AnimaPlayback.State.PLAYING and ticks < MAX_TICKS:
		playback._advance(TICK_SECONDS)
		ticks += 1
	var elapsed_usec := Time.get_ticks_usec() - started_at
	print("Group benchmark — %s: %d µs across %d targets (%d ticks)" % [label, elapsed_usec, TARGET_COUNT, ticks])
	assert_lt(ticks, MAX_TICKS, "%s benchmark should finish its playback" % label)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	return elapsed_usec

func test_group_resolution_scheduling_and_playback_benchmark():
	var sequential_usec := _run_benchmark("sequential", AnimaGroupMotion.PlaybackMode.SEQUENTIAL)
	var parallel_usec := _run_benchmark("parallel", AnimaGroupMotion.PlaybackMode.PARALLEL)
	var staggered_usec := _run_benchmark("staggered", AnimaGroupMotion.PlaybackMode.STAGGERED)

	assert_gte(sequential_usec, 0)
	assert_gte(parallel_usec, 0)
	assert_gte(staggered_usec, 0)
