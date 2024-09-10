@tool
extends VBoxContainer

signal close_pressed
signal event_selected(data: Dictionary)

var _start_node: Node 
var _search_text: String
var _anima_event_name: String

enum EventType {
	EVENT,
	SIGNAL,
	PROPERTY
}

func populate(root_node: Node, event_name: String):
	_start_node = root_node
	_anima_event_name = event_name

	_retrieves_list_of_nodes()

	%SearchField.clear()
	%SearchField.grab_focus()
	%CallbackOptions.hide()

	var root: TreeItem = %NodesList.get_root()
	root.select(0)

func _retrieves_list_of_nodes() -> void:
	%NodesList.clear()

	var root_item: TreeItem = %NodesList.create_item()
	root_item.set_text(0, _start_node.name)
	root_item.set_meta("path", _start_node.get_path())
	root_item.set_meta("relative_path", ".")

	_add_children(_start_node, root_item, true)

func _add_children(start_node: Node, parent_item = null, is_root := false) -> void:
	for child in start_node.get_children():
		var item: TreeItem

		if child is AnimaNode:
			continue

		if _is_visible(%SearchField, child.name):
			item = %NodesList.create_item(parent_item)
			item.set_text(0, child.name)
			item.set_meta("relative_path", str(_start_node.get_path_to(child)))
			item.set_meta("path", str(child.get_path()))
			item.set_icon(0, ANIMA.get_theme_icon(child.get_class()))

		if child.get_child_count() > 0:
			_add_children(child, item)

func _is_visible(search_field: LineEdit, name: String) -> bool:
	var search: String = search_field.text
	var is_visible: bool = search.length() == 0 or name.to_lower().find(search) >= 0

	return is_visible

func _on_nodes_list_item_selected() -> void:
	var selected_item: TreeItem = %NodesList.get_selected()
	var path = selected_item.get_meta("path")
	var node: Node = get_node(path)

	%EventsList.clear()

	var root = %EventsList.create_item()
	
	_add_node_options(root, "Call method", EventType.EVENT, node.get_method_list())
	_add_node_options(root, "Trigger signal", EventType.EVENT, node.get_signal_list())

func _sort_by_name(a, b):
	return a.name < b.name

func _add_node_options(root: TreeItem, name: String, type: EventType, items: Array) -> void:
	items.sort_custom(_sort_by_name)
	var parent_item: TreeItem = %EventsList.create_item(root)

	parent_item.set_text(0, name)
	
	var icon: String
	match type:
		EventType.EVENT:
			icon = "MemberMethod"
		EventType.SIGNAL:
			icon = "Signals"
		EventType.PROPERTY:
			icon = "MemberProperty"

	parent_item.set_icon(0, ANIMA.get_theme_icon(icon))

	for item in items:
		if not _is_visible(%SearchEventsList, item.name):
			continue

		var tree_item = %EventsList.create_item(parent_item)
		var item_name = item.name
		
		var args := []
		if item.has("args"):
			for arg in item.args:
				args.push_back(arg.name)

			item_name = item_name + "(" + ", ".join(args) + ")"

		tree_item.set_text(0, item_name)
		tree_item.set_meta("event", {
			name = item.name,
			type = type,
			args = item.args
		})

func _on_search_field_text_changed(new_text):
	_retrieves_list_of_nodes()

func _on_search_events_list_text_changed(new_text):
	_on_nodes_list_item_selected()

func _on_cta_cancel_pressed():
	close_pressed.emit()

func _on_events_list_item_selected():
	var selected_item: TreeItem = %EventsList.get_selected()
	var event = selected_item.get_meta("event")

	%CallbackOptions.visible = event.args.size() > 0

	for arg in event.args:
		_add_callback_arg(arg)

func _add_callback_arg(arg) -> void:
	var label := Label.new()
	var value := LineEdit.new()

	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.set_text(arg.name)

	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	%CallbackArgs.add_child(label)
	%CallbackArgs.add_child(value)

func _on_cta_confirm_pressed():
	var selected_event_item: TreeItem = %EventsList.get_selected()
	var selected_node: TreeItem = %NodesList.get_selected()

	if not selected_event_item:
		return

	var data = selected_event_item.get_meta("event")
	data.path = selected_node.get_meta("relative_path")

	var args = data.args.duplicate()
	data.args = []

	for index in args.size():
		var arg = args[index]
		var line_edit: LineEdit = %CallbackArgs.get_child(2 * index + 1)
		var value = line_edit.text
	
		match arg.type:
			TYPE_INT:
				value = int(value)
			TYPE_FLOAT:
				value = float(value)
		
		data.args.push_back(value)

	event_selected.emit(_anima_event_name, data)
	close_pressed.emit()
