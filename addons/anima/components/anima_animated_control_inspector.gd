@tool
extends EditorInspectorPlugin

var _animation_picker_content: VBoxContainer = preload("res://addons/anima/ui/AnimationPicker/AnimationPicker.tscn").instantiate()
var _event_item: VBoxContainer = preload("res://addons/anima/ui/EventItem.tscn").instantiate()

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
	
	container.add_child(_items_container)

	var button_container := CenterContainer.new()
	var button = load("res://addons/anima/ui/AnimationPicker/CTAPrimaryButton.tscn").instantiate()
	button.text = "  Add event  "
	button.icon = load("res://addons/anima/icons/Add.svg")

	button.pressed.connect(_on_add_event_pressed)

	button_container.add_child(button)
	container.add_child(button_container)

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
		item.preview_animation.connect(_on_preview_animation.bind(index))

		item.option_updated.connect(_on_option_updated.bind(index, item))

		if event.has("event_name"):
			item.set_event_name(event.event_name)

		if event.has("event_data"):
			item.set_data(event.event_data)

		_items_container.add_child(item)

func _perform_event(action: EventAction, param1 = null, param2 = null, should_refresh := true) -> void:
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

	if should_refresh:
		refresh_event_items()

	_anima_editor_plugin._update_animated_events(_selected_object, previous, events)

func _on_select_animation(index: int) -> void:
	_selected_event_index = index

	_animation_picker.popup_centered(Vector2(1024, 768))

func _on_add_event_pressed() -> void:
	_perform_event(EventAction.ADD)

func _on_delete_event(index: int) -> void:
	_perform_event(EventAction.REMOVE, index)

func _on_event_selected(name: String, index: int) -> void:
	_perform_event(EventAction.UPDATE_NAME, index, name)

func _close_animation_picker():
	_animation_picker.hide()

func _on_animation_selected(name: String) -> void:
	_perform_event(EventAction.UPDATE_DATA, _selected_event_index, { animation = name, delay = 0, duration = ANIMA.DEFAULT_DURATION, play_mode = 0 })

	_animation_picker.hide()

func _on_preview_animation(index: int) -> void:
	var event: Dictionary = _selected_object.get_animated_event_at(index)

	if event.has("event_data"):
		var anima_node := Anima.Node(_selected_object)
		var event_data = event.event_data
		var anima: AnimaNode

		if event_data is String:
			anima = anima_node.anima_animation(event_data).play()
		else:
			var animation := anima_node.anima_animation(event_data.animation, event_data.duration)

			if event_data.play_mode == 0:
				anima = animation.play_with_delay(event_data.delay)
			else:
				anima = animation.play_backwards_with_delay(event_data.delay)

		await anima.animation_completed

		anima.reset_and_clear()

func _on_option_updated(index: int, event_item) -> void:
	_perform_event(EventAction.UPDATE_DATA, index, event_item.get_data(), false)

