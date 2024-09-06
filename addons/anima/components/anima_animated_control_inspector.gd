@tool
extends EditorInspectorPlugin

var ANIMATION_PICKER_CONTENT = preload("res://addons/anima/ui/AnimationPicker/AnimationPicker.tscn").instantiate()
var EVENT_ITEM = preload("res://addons/anima/ui/EventItem.tscn").instantiate()
var EVENT_PICKER_CONTENT = preload("res://addons/anima/ui/NodeEventPicker/NodeEventPicker.tscn").instantiate()

var _animation_picker_window := Window.new()
var _event_picker_window := Window.new()

var _items_container: VBoxContainer
var _selected_object_animated_container
var _anima_editor_plugin: EditorPlugin
var _selected_event_index: int
var _event_items: Array[Node]

var _is_restoring_data := false

enum EventAction {
	ADD,
	REMOVE,
	UPDATE_NAME,
	UPDATE_DATA,
	UPDATE_ON_EVENT,
}

func _init(parent: EditorPlugin):
	_anima_editor_plugin = parent

	_animation_picker_window.add_child(ANIMATION_PICKER_CONTENT)
	_animation_picker_window.hide()
	_anima_editor_plugin.add_child(_animation_picker_window)

	ANIMATION_PICKER_CONTENT.connect("animation_selected", _on_animation_selected)

	ANIMATION_PICKER_CONTENT.close_pressed.connect(_close_window.bind(_animation_picker_window))
	_animation_picker_window.close_requested.connect(_close_window.bind(_animation_picker_window))

	_event_picker_window.add_child(EVENT_PICKER_CONTENT)
	_event_picker_window.hide()
	_anima_editor_plugin.add_child(_event_picker_window)

	EVENT_PICKER_CONTENT.close_pressed.connect(_close_window.bind(_event_picker_window))
	EVENT_PICKER_CONTENT.event_selected.connect(_on_node_event_selected)
	_event_picker_window.close_requested.connect(_close_window.bind(_event_picker_window))

func _is_anima_animatable(object):
	return '_animatable' in object and object._animatable is AnimaAnimatable

func _can_handle(object):
	return _is_anima_animatable(object)

func _parse_begin(object):
	if not _is_anima_animatable(object):
		return

	if not _items_container:
		_items_container = VBoxContainer.new()

	var animatable = _selected_object_animated_container._animatable if _selected_object_animated_container else null
	if animatable and animatable.is_connected("animation_event_completed", _on_animation_event_completed):
		animatable.disconnect("animation_event_completed", _on_animation_event_completed)

	_selected_object_animated_container = object
	animatable = _selected_object_animated_container._animatable

	if not animatable.is_connected("animation_event_completed", _on_animation_event_completed):
		animatable.animation_event_completed.connect(_on_animation_event_completed)

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

func refresh_event_items(should_show_options_for := -1):
	_is_restoring_data = true

	var animatable = _selected_object_animated_container._animatable
	var events: Array[Dictionary] = animatable.get_animated_events()

	for child in _items_container.get_children():
		child.queue_free()

	_event_items.clear()

	for index in events.size():
		var event := events[index]
		var item := EVENT_ITEM.duplicate()

		item.event_deleted.connect(_on_delete_event.bind(index))
		item.select_animation.connect(_on_select_animation.bind(index))
		item.event_selected.connect(_on_event_selected.bind(index))
		item.preview_animation.connect(_on_preview_animation.bind(index))
		item.select_node_event.connect(_on_select_node_event.bind(index))
		item.clear_anima_event_for.connect(_on_clear_anima_event_for)

		item.option_updated.connect(_on_option_updated.bind(index, item))

		if event.has("event_name"):
			item.set_event_name(event.event_name)

		if event.has("event_data"):
			item.set_data(event.event_data)

		if event.has("events"):
			item.set_events_data(event.events)

		_items_container.add_child(item)

		if should_show_options_for == index:
			item._on_more_button_toggled(true)

		_event_items.push_back(item)

	_is_restoring_data = false

func _perform_event(action: EventAction, param1 = null, param2 = null, should_refresh := true) -> void:
	if _is_restoring_data:
		return

	var animatable = _selected_object_animated_container._animatable
	var previous: Array[Dictionary] = animatable.get_animated_events().duplicate()
	var events: Array[Dictionary]
	
	match action:
		EventAction.ADD:
			events = animatable.add_new_event()
		EventAction.REMOVE:
			events = animatable.remove_event_at(param1)
		EventAction.UPDATE_NAME:
			events = animatable.set_animated_event_name_at(param1, param2)
		EventAction.UPDATE_DATA:
			events = animatable.set_animated_event_data_at(param1, param2)
		EventAction.UPDATE_ON_EVENT:
			events = animatable.set_on_event_data(_selected_event_index, param1, param2)

	if should_refresh:
		var expand_options_for = -1
		
		if action == EventAction.UPDATE_ON_EVENT:
			expand_options_for = _selected_event_index

		refresh_event_items(expand_options_for)

	_anima_editor_plugin._update_animated_events(_selected_object_animated_container, previous, events)

func _on_select_animation(index: int) -> void:
	_selected_event_index = index

	_animation_picker_window.popup_centered(Vector2(1024, 768))

func _on_add_event_pressed() -> void:
	_perform_event(EventAction.ADD)

func _on_delete_event(index: int) -> void:
	_perform_event(EventAction.REMOVE, index)

func _on_event_selected(name: String, index: int) -> void:
	_perform_event(EventAction.UPDATE_NAME, index, name)

func _close_window(window: Window):
	window.hide()

func _on_animation_selected(name: String) -> void:
	_perform_event(EventAction.UPDATE_DATA, _selected_event_index, { animation = name, delay = 0, duration = ANIMA.DEFAULT_DURATION, play_mode = 0 })

	_animation_picker_window.hide()

func _on_preview_animation(index: int) -> void:
	_selected_object_animated_container._animatable.preview_animated_event_at(index)

func _on_option_updated(index: int, event_item) -> void:
	_perform_event(EventAction.UPDATE_DATA, index, event_item.get_data(), false)

func set_godot_theme(theme: Theme) -> void:
	ANIMA.set_godot_theme(theme)

func _on_select_node_event(event_name: String, index: int) -> void:
	_selected_event_index = index
	_event_picker_window.popup_centered(Vector2(1024, 768))
	EVENT_PICKER_CONTENT.populate(_selected_object_animated_container, event_name)

func _on_node_event_selected(event_name: String, data: Dictionary) -> void:
	_perform_event(EventAction.UPDATE_ON_EVENT, event_name, data)

func _on_clear_anima_event_for(event_name: String) -> void:
	_perform_event(EventAction.UPDATE_ON_EVENT, event_name, null)

func _on_animation_event_completed(name: String):
	for event in _event_items:
		event.stop_preview()
