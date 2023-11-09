@tool
extends GridContainer

var _start_node: Node 
var _search_text: String

func _ready():
	populate(self)

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
			item.set_icon(0, ANIMA.get_node_icon("Save"))

		if child.get_child_count() > 0:
			_add_children(child, item)

func _is_visible(name: String) -> bool:
	var search: String = _search_text.strip_edges()
	var is_visible: bool = search.length() == 0 or name.to_lower().find(search) >= 0

	return is_visible

func _on_nodes_list_item_selected(index):
	var path = %NodesList.get_item_metadata(index)
	var node: Node = get_node(path)
	var events = node.get_method_list()
	var signals = node.get_signal_list()
	var properties = node.get_property_list()
