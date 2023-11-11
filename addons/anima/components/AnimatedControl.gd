@tool
extends Control
class_name AnimaAnimatedControl

@export var _events: Array[Dictionary] = []

signal animation_completed
signal animation_event_completed(name: String)

var anima := Anima.begin(self)
var _can_exit := true
var _exit_event: Dictionary
var _ignore_animations := false

func _ready():
	if get_parent() is Window:
		get_tree().set_auto_accept_quit(_can_exit)

func _enter_tree():
	for event in _events:
		if event.has("event_data"):
			if event.event_name == "tree_exiting":
				_can_exit = false
				_exit_event = event
			else:
				connect(event.event_name, _on_simple_event(event))

func _on_simple_event(event: Dictionary, can_ignore_animations := true):
	return func ():
		if can_ignore_animations and _ignore_animations:
			return

		if anima.get_animation_data().size():
			anima.stop_and_reset()
			anima.clear()

		var data = event.event_data

		anima.then({
			animation = data.animation,
			delay = data.delay,
			duration = data.duration,
			on_started = _get_animation_event("on_started", event),
			on_completed = _get_animation_event("on_competed", event)
		})

		if data.play_mode == 0:
			anima.play()
		else:
			anima.play_backwards()

		await anima.animation_completed
		
		animation_completed.emit()
		animation_event_completed.emit(event.event_name)

func _get_animation_event(event_name: String, data: Dictionary):
	if not data.has("events") or not data.events.has(event_name):
		return null

	var event = data.events[event_name]
	var node: Node = get_node(event.path)
	
	if not node:
		return null

	return func():
		print(event)
		if event.type == 0:
			if event.args.size() == 0:
				node.call(event.name)
			else:
				node.callv(event.name, event.args)

func set_animated_events(events: Array[Dictionary]) -> void:
	_events = events

func get_animated_events() -> Array[Dictionary]:
	return _events

func get_animated_event_at(index: int) -> Dictionary:
	return _events[index] if index <= _events.size() else {}

func set_animated_event_name_at(index: int, event_name: String) -> Array[Dictionary]:
	_events[index].event_name = event_name

	return _events

func set_animated_event_data_at(index: int, data: Dictionary) -> Array[Dictionary]:
	_events[index].event_data = data

	return _events

func set_animated_event(index: int, event_name: String, data: Dictionary):
	_events[index] = { event_name = event_name, event_data = data }

func add_new_event() -> Array[Dictionary]:
	_events.push_back({})

	return _events

func remove_event_at(index: int) -> Array[Dictionary]:
	_events.remove_at(index)

	return _events

func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			if !_can_exit:
				_ignore_animations = true

				var fn = _on_simple_event(_exit_event, false)

				fn.call()

				await anima.animation_completed

				get_tree().quit()

func set_on_event_data(index: int, anima_event_name: String, data) -> Array[Dictionary]:
	if not _events[index].has("events"):
		_events[index].events = {}

	if data == null:
		_events[index].events.erase(anima_event_name)
	else:
		_events[index].events[anima_event_name] = data

	return _events
