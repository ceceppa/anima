@tool
extends EditorInspectorPlugin

var _animation_picker_content: VBoxContainer = preload("res://addons/anima/ui/AnimationPicker.tscn").instantiate()
var _event_item: HBoxContainer = preload("res://addons/anima/ui/EventItem.tscn").instantiate()

var _animation_picker := Window.new()
var _items_container: VBoxContainer
var _selected_object
var _anima_editor_plugin: EditorPlugin
var _selected_event_index: int

enum EventAction {
	ADD,
	REMOVE,
	UPDATE_NAME,
	UPDATE_DATA
}

func _init(parent: EditorPlugin):
	_animation_picker.add_child(_animation_picker_content)
	_animation_picker.hide()
	
	_anima_editor_plugin = parent
	_anima_editor_plugin.add_child(_animation_picker)

	_animation_picker_content.connect("close_pressed", _close_animation_picker)
	_animation_picker_content.connect("animation_selected", _on_animation_selected)
	_animation_picker.close_requested.connect(_close_animation_picker)

func _can_handle(object):
	return object.has_method("get_animated_events")

func _parse_begin(object):
	if not object.has_method("get_animated_events"):
		return

	if not _items_container:
		_items_container = VBoxContainer.new()

	_selected_object = object

	var container := VBoxContainer.new()
	var button := Button.new()
	button.text = "Add event"
	button.pressed.connect(_on_add_event_pressed)

	container.add_child(_items_container)

	container.add_child(button)
	
	refresh_event_items()
	add_custom_control(container)

func refresh_event_items():
	var events: Array[Dictionary] = _selected_object.get_animated_events()

	for child in _items_container.get_children():
		child.queue_free()

	for index in events.size():
		var event := events[index]
		var item := _event_item.duplicate()

		item.event_deleted.connect(_on_delete_event.bind(index))
		item.select_animation.connect(_on_select_animation.bind(index))
		item.event_selected.connect(_on_event_selected.bind(index))

		if event.has("event_name"):
			item.set_event_name(event.event_name)

		if event.has("event_data"):
			item.set_data(event.event_data)

		_items_container.add_child(item)

func _do_event(action: EventAction, param1 = null, param2 = null) -> void:
	var previous: Array[Dictionary] = _selected_object.get_animated_events().duplicate()
	var events: Array[Dictionary]
	
	match action:
		EventAction.ADD:
			events = _selected_object.add_new_event()
		EventAction.REMOVE:
			events = _selected_object.remove_event_at(param1)
		EventAction.UPDATE_NAME:
			events = _selected_object.set_animated_event_name_at(param1, param2)
		EventAction.UPDATE_DATA:
			events = _selected_object.set_animated_event_data_at(param1, param2)

	refresh_event_items()

	_anima_editor_plugin._update_animated_events(_selected_object, previous, events)

func _on_select_animation(index: int) -> void:
	_selected_event_index = index

	_animation_picker.popup_centered(Vector2(1024, 768))

func _on_add_event_pressed() -> void:
	_do_event(EventAction.ADD)

func _on_delete_event(index: int) -> void:
	_do_event(EventAction.REMOVE, index)

func _on_event_selected(name: String, index: int) -> void:
	_do_event(EventAction.UPDATE_NAME, index, name)

func _close_animation_picker():
	_animation_picker.hide()

func _on_animation_selected(name: String) -> void:
	_do_event(EventAction.UPDATE_DATA, _selected_event_index, name)#

	_animation_picker.hide()

