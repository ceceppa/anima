extends "res://addons/gut/test.gd"

func test_layout_transition_animates_a_container_child_to_godots_final_rect():
	var container := add_child_autofree(HBoxContainer.new())
	container.size = Vector2(400.0, 100.0)
	var first := Control.new()
	first.custom_minimum_size = Vector2(100.0, 60.0)
	var second := Control.new()
	second.custom_minimum_size = Vector2(100.0, 60.0)
	container.add_child(first)
	container.add_child(second)
	await get_tree().process_frame

	var transition := Anima.layout_transition(container, 0.1)
	first.custom_minimum_size = Vector2(200.0, 60.0)
	await get_tree().process_frame
	var godot_final_position := second.position
	var godot_final_size := second.size
	var playbacks := transition.play()

	assert_false(playbacks.is_empty())
	assert_true(transition._is_animating)
	assert_ne(second.position, godot_final_position, "the prior visual rectangle should remain visible when the transition begins")
	simulate(AnimaRuntime.get_singleton(), 3, 1.0 / 60.0)
	assert_true(transition._is_animating)
	assert_ne(second.position, godot_final_position, "the control should move through the transition instead of snapping to Godot's final rectangle")
	simulate(AnimaRuntime.get_singleton(), 12, 1.0 / 60.0)
	assert_false(transition._is_animating)
	assert_true(second.item_rect_changed.is_connected(transition._animate_changes.bind(second)))
	assert_almost_eq(second.position.x, godot_final_position.x, 0.01)
	assert_almost_eq(second.size.x, godot_final_size.x, 0.01)

func test_layout_transition_ignores_non_container_boundaries():
	var root := add_child_autofree(Control.new())
	var loose_child := Control.new()
	root.add_child(loose_child)
	var transition := Anima.layout_transition(HBoxContainer.new())
	assert_true(transition.play().is_empty())

func test_layout_transition_reconnects_when_a_layout_change_does_not_start_animation():
	var container := add_child_autofree(HBoxContainer.new())
	container.size = Vector2(400.0, 100.0)
	var child := Control.new()
	child.custom_minimum_size = Vector2(100.0, 60.0)
	container.add_child(child)
	await get_tree().process_frame

	var transition := Anima.layout_transition(container)
	transition._animate_changes()

	assert_true(transition.play().is_empty())
	assert_true(child.item_rect_changed.is_connected(transition._animate_changes.bind(child)))

func test_layout_transition_animates_each_control_when_godot_notifies_them_separately():
	var container := add_child_autofree(HBoxContainer.new())
	var middle := Control.new()
	var last := Control.new()
	container.add_child(middle)
	container.add_child(last)
	var transition := Anima.layout_transition(container, 0.1)
	transition._before_rects = {
		middle.get_instance_id(): {"control": middle, "position": Vector2(0.0, 0.0), "size": Vector2(100.0, 60.0)},
		last.get_instance_id(): {"control": last, "position": Vector2(100.0, 0.0), "size": Vector2(100.0, 60.0)},
	}

	middle.size = Vector2(200.0, 60.0)
	transition._animate_changes(middle)
	last.position = Vector2(200.0, 0.0)
	transition._animate_changes(last)

	assert_eq(transition.play().size(), 2, "a later control's layout notification must start its own playback")
	assert_true(transition._animating_control_ids.has(last.get_instance_id()))

func test_interruption_policies_have_distinct_runtime_outcomes():
	var target: Node2D = add_child_autofree(Node2D.new())
	var first := Motion.to(NodePath("position:x"), 100.0)
	first.duration = 1.0
	var active := Anima.play(first, target)
	simulate(AnimaRuntime.get_singleton(), 10, 1.0 / 60.0)

	var replacement := Motion.to(NodePath("position:x"), 20.0)
	replacement.duration = 0.1
	replacement.interruption_policy = AnimaMotion.InterruptionPolicy.REPLACE
	var replaced := Anima.play(replacement, target)
	assert_eq(active.state, AnimaPlayback.State.CANCELLED)
	assert_ne(replaced, active)
	simulate(AnimaRuntime.get_singleton(), 10, 1.0 / 60.0)
	assert_almost_eq(target.position.x, 20.0, 0.01)

	var queued_first := Motion.to(NodePath("position:x"), 100.0)
	queued_first.duration = 0.1
	var queue_owner := Anima.play(queued_first, target)
	var queued_second := Motion.to(NodePath("position:x"), 40.0)
	queued_second.duration = 0.1
	queued_second.interruption_policy = AnimaMotion.InterruptionPolicy.QUEUE
	var queued := Anima.play(queued_second, target)
	assert_eq(queued.state, AnimaPlayback.State.QUEUED)
	simulate(AnimaRuntime.get_singleton(), 20, 1.0 / 60.0)
	assert_eq(queue_owner.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(target.position.x, 40.0, 0.01)

	var retarget_first := Motion.to(NodePath("position:x"), 100.0)
	retarget_first.duration = 1.0
	retarget_first.ease.kind = AnimaEase.Kind.SPRING
	var retarget_owner := Anima.play(retarget_first, target)
	simulate(AnimaRuntime.get_singleton(), 10, 1.0 / 60.0)
	var retarget_request := Motion.to(NodePath("position:x"), 70.0)
	retarget_request.interruption_policy = AnimaMotion.InterruptionPolicy.RETARGET
	retarget_request.ease.kind = AnimaEase.Kind.SPRING
	assert_eq(Anima.play(retarget_request, target), retarget_owner)
	assert_eq(retarget_first.to_value, 70.0, "retarget changes the active spring destination without replacing its playback")

	var reverse_first := Motion.to(NodePath("position:x"), 100.0)
	reverse_first.duration = 1.0
	var reverse_owner := Anima.play(reverse_first, target)
	simulate(AnimaRuntime.get_singleton(), 10, 1.0 / 60.0)
	var reverse_request := Motion.to(NodePath("position:x"), 0.0)
	reverse_request.interruption_policy = AnimaMotion.InterruptionPolicy.REVERSE
	assert_eq(Anima.play(reverse_request, target), reverse_owner)
	simulate(AnimaRuntime.get_singleton(), 70, 1.0 / 60.0)
	assert_almost_eq(target.position.x, 40.0, 0.01, "reverse returns to the captured start instead of applying the incoming destination")
