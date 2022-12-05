@tool
extends "./AnimaBaseWindow.gd"

signal property_selected(node_path, property, property_type)

@onready var _property_search: LineEdit = find_child('PropertySearch')
@onready var _nodes_list: VBoxContainer = find_child('AnimaNodesList')

@export var nodes_list_visible := false

var _animatable_properties := [{name = 'opacity', type = TYPE_FLOAT}]
var _source_node: Node

func _ready():
	super._ready()

	_nodes_list.visible = nodes_list_visible

func _on_popup_visible() -> void:
	var list: VBoxContainer = find_child('AnimaNodesList')

#	list.select_node(_source_node)

	if _property_search == null:
		_property_search = find_child("PropertySearch")

	_property_search.clear()
	_property_search.grab_focus()

func show_nodes_list(show: bool) -> void:
	var list: VBoxContainer = find_child('AnimaNodesList')

	list.visible = show

func populate(source_node: Node) -> void:
	_nodes_list.populate(source_node)
	_populate_animatable_properties_list(source_node)

func _populate_animatable_properties_list(source_node: Node) -> void:
	_source_node = source_node
	_animatable_properties.clear()

	_animatable_properties.push_back({name = 'opacity', type = TYPE_FLOAT})

	var properties = source_node.get_property_list()
	var properties_to_ignore := [
		'process_mode',
		'process_priority',
		'light_mask',
		'grow_horizontal',
		'grow_vertical',
		'focus_mode',
		'size_flags_horizontal',
		'size_flags_vertical'
	]
	for property in properties:
		if property.name.begins_with('_') or \
			property.hint == PROPERTY_HINT_ENUM or \
			properties_to_ignore.find(property.name) >= 0:
			continue

		if property.hint == PROPERTY_HINT_RANGE or \
			property.hint == PROPERTY_HINT_COLOR_NO_ALPHA or \
			property.type == TYPE_VECTOR2 or \
			property.type == TYPE_VECTOR3 or \
			property.type == TYPE_INT or \
			property.type == TYPE_FLOAT or \
			property.type == TYPE_COLOR or \
			property.type == TYPE_RECT2:
			_animatable_properties.push_back({name = property.name.replace('rect_', ''), type = property.type})

	_animatable_properties.sort_custom(Callable(PropertiesSorter,"sort_by_name"))

	populate_tree()

func populate_tree(filter: String = '') -> void:
	var tree: Tree = find_child('PropertiesTree')
	tree.clear()
	tree.set_hide_root(true)

	var root_item = tree.create_item()
	root_item.set_text(0, "Available properties")
	root_item.set_selectable(0, false)

	for animatable_property in _animatable_properties:
		var name = animatable_property.name
		var is_visible = filter.strip_edges().length() == 0 or name.to_lower().find(filter.to_lower().strip_edges()) >= 0

		if not is_visible:
			continue

		var item := tree.create_item(root_item)

		item.set_text(0, animatable_property.name)
		item.set_metadata(0, { type = animatable_property.type })
#		item.set_icon(0, AnimaUI.get_godot_icon_for_type(animatable_property.type))

		var sub_properties := []
		if animatable_property.type == TYPE_VECTOR2:
			sub_properties = ['x', 'y']
		elif animatable_property.type == TYPE_VECTOR3:
			sub_properties = ['x', 'y', 'z']
		elif animatable_property.type == TYPE_COLOR:
			sub_properties = ['r', 'g', 'b', 'a']
		elif animatable_property.type == TYPE_RECT2:
			sub_properties = ['x', 'y', 'w', 'h']

		for sub_property in sub_properties:
			var sub = tree.create_item(item)

			sub.set_text(0, sub_property)
#			sub.set_icon(0, AnimaUI.get_godot_icon_for_type(TYPE_FLOAT))
			sub.set_metadata(0, { type = TYPE_FLOAT })

class PropertiesSorter:
	static func sort_by_name(a: Dictionary, b: Dictionary) -> bool:
		return a.name < b.name

func _on_LineEdit_text_changed(new_text: String):
	populate_tree(new_text)

func _on_PropertiesTree_item_double_clicked():
	var tree: Tree = find_child('PropertiesTree')
	var selected_item: TreeItem = tree.get_selected()
	var parent = selected_item.get_parent()
	var is_child: bool = parent.get_parent() != null
	var selected_node: String = _nodes_list.get_selected()

	var property_to_animate: String = selected_item.get_text(0)

	if is_child:
		property_to_animate = parent.get_text(0) + ":" + property_to_animate

	emit_signal("property_selected", _nodes_list.get_selected(), property_to_animate, selected_item.get_metadata(0).type)

	hide()

func _on_PropertiesTree_item_activated():
	_on_PropertiesTree_item_double_clicked()

func _on_AnimaNodesList_node_selected(node: Node, _path) -> void:
	_populate_animatable_properties_list(node)
	_on_LineEdit_text_changed(find_child("PropertySearch").text)

func select_node(node: Node) -> void:
	_nodes_list.select_node(node, true)
	_nodes_list.hide()

func _on_Close_pressed():
	hide()

func _on_ConfirmProperty_pressed():
	_on_PropertiesTree_item_activated()
