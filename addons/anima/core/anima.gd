extends Node

const BASE_PATH := 'res://addons/anima/animations/'

enum PIVOT {
	CENTER,
	CENTER_BOTTOM,
	TOP_CENTER,
	TOP_LEFT,
	LEFT_BOTTOM,
	RIGHT_BOTTOM
}

enum VISIBILITY {
	IGNORE,
	HIDDEN_ONLY,
	TRANSPARENT_ONLY,
	HIDDEN_AND_TRANSPARENT
}

enum GRID {
	TOGETHER,
	SEQUENCE_TOP_LEFT,
	SEQUENCE_BOTTOM_RIGHT,
	COLUMNS_ODD,
	COLUMNS_EVEN,
	ROWS_ODD,
	ROWS_EVEN,
	ODD,
	EVEN,
	FROM_CENTER,
	FROM_POINT
}

enum LOOP {
	USE_EXISTING_RELATIVE_DATA,
	RECALCULATE_RELATIVE_DATA,
}

enum TYPE {
	NODE,
	GROUP,
	GRID
}

const EASING = AnimaEasing.EASING

const DEFAULT_DURATION := 0.7
const DEFAULT_ITEMS_DELAY := 0.05

var _animations_list := []
var _custom_animations := []

func begin(node, name: String = 'anima') -> AnimaNode:
	var node_name = 'AnimaNode_' + name
	var anima_node: AnimaNode

	for child in node.get_children():
		if child.name.find(node_name) >= 0:
			anima_node = child
			anima_node.clear()
			anima_node.stop()

			return anima_node

	if anima_node == null:
		anima_node = AnimaNode.new()
		anima_node.name = node_name

		anima_node._init_node(node)

	return anima_node

func register_animation(script, animation_name: String) -> void:
	_deregiter_animation(animation_name)

	_custom_animations.push_back({ name = animation_name, script = script })

func _deregiter_animation(animation_name: String) -> void:
	for animation in _custom_animations:
		if animation.name == animation_name:
			_custom_animations.erase(animation)

func get_available_animations() -> Array:
	if _animations_list.size() == 0:
		var list = _get_animations_list()
		var filtered := []

		for file in list:
			if file.find('.gd.') < 0:
				filtered.push_back(file.replace('.gdc', '.gd'))

		_animations_list = filtered

	return _animations_list + _custom_animations

func get_animation_script(animation_name: String):
	for custom_animation in _custom_animations:
		if custom_animation.name == animation_name:
			return custom_animation.script

	var resource_file = get_animation_script_with_path(animation_name)
	if resource_file:
		return load(resource_file).new()

	printerr('No animation found with name: ', animation_name)

	return null

func is_built_in_animation(animation_name: String) -> bool:
	return _animations_list.find(animation_name) >= 0

func get_animation_script_with_path(animation_name: String) -> String:
	if not animation_name.ends_with('.gd'):
		animation_name += '.gd'

	animation_name = AnimaStrings.from_camel_to_snack_case(animation_name)

	for file_name in get_available_animations():
		if file_name is String and file_name.ends_with(animation_name):
			return file_name

	return ''

func _get_animations_list() -> Array:
	var files = _get_scripts_in_dir(BASE_PATH)
	var filtered := []

	files.sort()
	return files

func _get_scripts_in_dir(path: String, files: Array = []) -> Array:
	var dir = Directory.new()
	if dir.open(path) != OK:
		return files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name != "." and file_name != "..":
			if dir.current_is_dir():
				_get_scripts_in_dir(path + file_name + '/', files)
			else:
				files.push_back(path + file_name)

		file_name = dir.get_next()

	return files
