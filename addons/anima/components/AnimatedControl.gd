@tool
extends Control
class_name AnimaAnimatedControl

@export var _events: Array[Dictionary] = []

var anima := Anima.begin(self)
var _can_exit := true
var _exit_data: Dictionary
var _ignore_animations := false

func _ready():
	if get_parent() is Window:
		get_tree().set_auto_accept_quit(_can_exit)

func _enter_tree():
	for event in _events:
		var data = event.event_data if event.has("event_data") else null

		if data:
			if event.event_name == "tree_exiting":
				_can_exit = false
				_exit_data = data
			else:
				connect(event.event_name, _on_simple_event(data))

func _on_simple_event(data: Dictionary, can_ignore_animations := true):
	return func ():
		if can_ignore_animations and _ignore_animations:
			return

		if anima.get_animation_data().size():
			anima.stop_and_reset()
			anima.clear()

		anima.then({
			animation = data.animation,
			delay = data.delay,
			duration = data.duration
		})

		if data.play_mode == 0:
			anima.play()
		else:
			anima.play_backwards()

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

				var fn = _on_simple_event(_exit_data, false)

				fn.call()

				await anima.animation_completed

				get_tree().quit()
