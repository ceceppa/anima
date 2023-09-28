@tool
extends Control

@export var _events: Array[Dictionary] = []

func _enter_tree():
	for event in _events:
		var animation = event.event_data if event.has("event_data") else null

		if animation:
			connect(event.event_name, _on_simple_event(animation))

func _draw():
	draw_rect(Rect2(Vector2(50, 50), Vector2(100, 100)), Color.REBECCA_PURPLE)

func _on_simple_event(animation: String):
	return func ():
		Anima.Node(self).anima_animation(animation).play()

func set_animated_events(events: Array[Dictionary]) -> void:
	_events = events

func get_animated_events() -> Array[Dictionary]:
	return _events

func get_animated_event_at(index: int) -> Dictionary:
	return _events[index] if _events.size() <= index else {}

func set_animated_event_name_at(index: int, event_name: String) -> Array[Dictionary]:
	_events[index].event_name = event_name

	return _events

func set_animated_event_data_at(index: int, data) -> Array[Dictionary]:
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
