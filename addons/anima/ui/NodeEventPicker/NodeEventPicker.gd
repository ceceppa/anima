@tool
extends GridContainer

var _start_node: Node 
var _search_text: String

enum EventType {
	EVENT,
	SIGNAL,
	PROPERTY
}

func populate(root_node: Node):
	_start_node = root_node

	_retrieves_list_of_nodes()

	%SearchField.clear()
	%SearchField.grab_focus()

	var root: TreeItem = %NodesList.get_root()
	root.select(0)

func _retrieves_list_of_nodes() -> void:
	%NodesList.clear()

	var root_item: TreeItem = %NodesList.create_item()
	root_item.set_text(0, _start_node.name)
	root_item.set_meta("path", str(_start_node.get_path()))

	_add_children(_start_node, root_item, true)

func _add_children(start_node: Node, parent_item = null, is_root := false) -> void:
	for child in start_node.get_children():
		var item: TreeItem

		if child is AnimaNode:
			continue

		if _is_visible(child.name):
			item = %NodesList.create_item(parent_item)
			item.set_text(0, child.name)
			item.set_meta("path", str(child.get_path()))
			item.set_icon(0, ANIMA.get_theme_icon(child.get_class()))

		if child.get_child_count() > 0:
			_add_children(child, item)

func _is_visible(name: String) -> bool:
	var search: String = _search_text.strip_edges()
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
	_add_node_options(root, "Set property", EventType.PROPERTY, node.get_property_list())

func _add_node_options(root: TreeItem, name: String, type: EventType, items: Array) -> void:
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
		var tree_item = %EventsList.create_item(parent_item)

		tree_item.set_text(0, item.name)
		tree_item.set_meta("event", {
			name = item,
			type = type,
		})
