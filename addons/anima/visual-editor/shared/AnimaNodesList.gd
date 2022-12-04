@tool
extends VBoxContainer

signal node_selected(node, path)
signal close

@export (bool) var trigger_selected := false

@onready var _search_filed: LineEdit = find_child("SearchField")
@onready var _nodes_list: Tree = find_child("NodesList")

var _start_node: Node
var _search_text: String

func _ready():
	if trigger_selected:
		$ButtonsContainer.hide()

func populate(root_node: Node):
	_start_node = root_node

	if _search_filed == null:
		_search_filed = find_child("SearchField")

	_retrieves_list_of_nodes()

	_search_filed.clear()
	_search_filed.grab_focus()

	var root: TreeItem = _nodes_list.get_root()
	root.select(0)
	
func get_selected() -> String:
	var selected := _nodes_list.get_selected()

	if selected == null:
		return ""

	if selected.get_parent() == null:
		return "."

	var path := []

	while selected:
		var name: String = selected.get_text(0)

		if selected.get_parent() == null:
			name = "."

		path.push_front(name)
		selected = selected.get_parent()

	return "/".join(PackedStringArray(path))

func select_node(node: Node, emit_signal := false) -> void:
	var root: TreeItem = _nodes_list.get_root()
	
	if node == null:
		return

	var element = _select_node(root.get_children(), node.get_path())

	if element:
		element.select(0)
		
		if emit_signal:
			_on_NodesList_item_activated()

func _select_node(tree_item: TreeItem, node_path: String, c = ""):
	while tree_item != null:
		var child_path: String = tree_item.get_meta("path")

		if child_path == node_path:
			return tree_item

		var subchild = tree_item.get_children()
		
		if subchild:
			var found = _select_node(subchild, node_path)

			if found:
				return found

		tree_item = tree_item.get_next()

	return null

func _retrieves_list_of_nodes() -> void:
	if _nodes_list == null:
		_nodes_list = find_child('NodesList')

	_nodes_list.clear()

	var root_item := _nodes_list.create_item()
	root_item.set_text(0, _start_node.name)
	root_item.set_meta("path", str(_start_node.get_path()))
#	root_item.set_icon(0, ANIMA.get_node_icon(_start_node))

	_add_children(_start_node, root_item, true)

func _add_children(start_node: Node, parent_item = null, is_root := false) -> void:
	if is_root:
		_nodes_list.set_hide_root(start_node is AnimaVisualNode or not _is_visible(start_node.name))
		
	for child in start_node.get_children():
		var item

		if child is AnimaVisualNode or child is AnimaNode:
			continue

		if _is_visible(child.name):
			item = _nodes_list.create_item(parent_item)
			item.set_text(0, child.name)
			item.set_meta("path", str(child.get_path()))

#			item.set_icon(0, ANIMA.get_node_icon(child))

		if child.get_child_count() > 0:
			_add_children(child, item)

func _is_visible(name: String) -> bool:
	var search: String = _search_text.strip_edges()
	var is_visible: bool = search.length() == 0 or name.to_lower().find(search) >= 0

	return is_visible

func _on_SearchField_text_changed(new_text: String):
	_search_text = new_text.to_lower()

	_retrieves_list_of_nodes()

func _on_NodesList_item_activated():
	var path: String = get_selected()
	var node: Node = _start_node.get_node(path)

	if node == null:
		node = _start_node

	emit_signal("node_selected", node, path)

func _on_SearchField_gui_input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		hide()

func _on_NodesList_item_selected():
	if trigger_selected:
		_on_NodesList_item_activated()

func _on_GodotUIButton_pressed():
	_on_NodesList_item_activated()

func _on_Close_pressed():
	emit_signal("close")

func _on_Add_pressed():
	pass # Replace with function body.
