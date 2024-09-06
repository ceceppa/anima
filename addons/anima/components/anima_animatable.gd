@tool
class_name AnimaAnimatable

signal animation_completed
signal animation_event_completed(name: String)

var _can_exit := true
var _has_delete_been_called := false
var _exit_event_data: Dictionary

var _should_handle_visibility_change := false
var _on_visible_event_data
var _on_hidden_event_data

var _ignore_animations := false
var _ignore_visibility_event := false

var _old_visibility := false
var _parent: Node
var _events: Array[Dictionary] = []

func _init(parent: Node, events: Array[Dictionary] = []):
	_parent = parent
	_events = events
	
	_old_visibility = _parent.visible
	
func _on_ready():
	if _parent.get_parent() is Window:
		_parent.get_tree().set_auto_accept_quit(_can_exit)

func _enter_tree():
	_handle_events()

func _handle_events():
	for event in _events:
		if not event.has("event_data") or \
			(event.event_data.has("skip") and event.event_data.skip):
			continue

		match event.event_name:
			"tree_exiting":
				_can_exit = false
				_exit_event_data = event
			"on_visible":
				_should_handle_visibility_change = true
				_on_visible_event_data = event
			"on_hidden":
				_should_handle_visibility_change = true
				_on_hidden_event_data = event
			_:
				_parent.connect(event.event_name, _animate_event.bind(event))

func _update_events():
	for s in get_signal_list():
		if is_connected(s.name, _animate_event):
			disconnect(s.name, _animate_event)

	_can_exit = true
	_should_handle_visibility_change = false
	_on_visible_event_data = null
	_on_hidden_event_data = null

	_handle_events()

func _animate_event(event: Dictionary):
	var data = event.event_data

	var anima = (
		Anima.Node(_parent)
		.anima_animation(data.animation, data.duration)
		.anima_delay(data.delay)
	)
	
	var on_started = _get_animation_event("on_started", event)
	var on_completed = _get_animation_event("on_completed", event)
	
	if on_started:
		anima.anima_on_started(on_started)

	if on_completed:
		anima.anima_on_completed(on_completed)

	return
	if data.play_mode == 0:
		anima.play()
	elif data.play_mode == 1:
		anima.play_backwards()
	else:
		prints(data.loop_mode, data.loop_times)
		if data.loop_mode == 0:
			anima.loop(data.loop_times)
		elif data.loop_mode == 1:
			anima.loop_backwards(data.loop_times)
		else:
			anima.loop_in_circle(data.loop_times)

	await anima.animation_completed
	
	animation_completed.emit()
	animation_event_completed.emit(event.event_name)

func _get_animation_event(event_name: String, data: Dictionary):
	if not data.has("events") or not data.events.has(event_name):
		return null

	var event = data.events[event_name]
	var node: Node = _parent.get_node(event.path)
	
	if not node:
		return null

	return func():
		if event.type == 0:
			if event.args.size() == 0:
				node.call(event.name)
			else:
				node.callv(event.name, event.args)

func set_animated_events(events: Array[Dictionary]) -> void:
	_events = events

	_update_events()

func get_animated_events() -> Array[Dictionary]:
	return _events

func get_animated_event_at(index: int) -> Dictionary:
	return _events[index] if index <= _events.size() else {}

func set_animated_event_name_at(index: int, event_name: String) -> Array[Dictionary]:
	_events[index].event_name = event_name

	_update_events()

	return _events

func set_animated_event_data_at(index: int, data: Dictionary) -> Array[Dictionary]:
	_events[index].event_data = data

	_update_events()

	return _events

func set_animated_event(index: int, event_name: String, data: Dictionary):
	_events[index] = { event_name = event_name, event_data = data }

	_update_events()

func add_new_event() -> Array[Dictionary]:
	_events.push_back({})

	return _events

func remove_event_at(index: int) -> Array[Dictionary]:
	_events.remove_at(index)

	return _events

func on_notification(what):
	var visible = _parent.visible

	match what:
		_parent.NOTIFICATION_VISIBILITY_CHANGED:
			if not _should_handle_visibility_change or _old_visibility == visible:
				return

			if _ignore_visibility_event:
				_ignore_visibility_event = false

				return

			_old_visibility = visible

			if visible and _on_visible_event_data:
				_trigger_animate_event(_on_visible_event_data)
			elif not visible and _on_hidden_event_data:
				_ignore_visibility_event = true

				await _parent.get_tree().process_frame

				_parent.show()

				await _trigger_animate_event(_on_hidden_event_data)

				_parent.hide()

		_parent.NOTIFICATION_WM_CLOSE_REQUEST:
			if !_can_exit:
				_ignore_animations = true

				await _trigger_animate_event(_exit_event_data)
		NOTIFICATION_PREDELETE:
			if not _can_exit and not _has_delete_been_called:
				printerr("Due Godot limitations, please call delete instead of `*_free()` to play the exiting animation")

func set_on_event_data(index: int, anima_event_name: String, data) -> Array[Dictionary]:
	if not _events[index].has("events"):
		_events[index].events = {}

	if data == null:
		_events[index].events.erase(anima_event_name)
	else:
		_events[index].events[anima_event_name] = data

	return _events

func _trigger_animate_event(event_data):
	_animate_event(event_data)

	#await anima.animation_completed

func preview_animated_event_at(index: int) -> void:
	_animate_event(_events[index])
#
	#await anima.animation_completed
#
	#anima.reset_and_clear()

func delete():
	if _can_exit:
		_parent.queue_free()

		return

	_has_delete_been_called = true

	await _trigger_animate_event(_exit_event_data)

	_parent.queue_free()
