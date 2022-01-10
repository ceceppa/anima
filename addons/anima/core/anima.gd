tool
extends Node

const BASE_PATH := 'res://addons/anima/animations/'

enum PIVOT {
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT
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
	FROM_POINT,
	RANDOM
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

enum VALUES_IN {
	PIXELS,
	PERCENTAGE
}

const Align = {
	LEFT = HALIGN_LEFT,
	CENTER = HALIGN_CENTER,
	RIGHT = HALIGN_RIGHT,
}

const VAlign = {
	TOP = VALIGN_TOP,
	CENTER = VALIGN_CENTER,
	BOTTOM = VALIGN_BOTTOM,
}

const EASING = AnimaEasing.EASING

const DEFAULT_DURATION := 0.7
const DEFAULT_ITEMS_DELAY := 0.05
const MINIMUM_DURATION := 0.000001

var _animations_list := []
var _custom_animations := []

func begin(node: Node, name: String = 'anima', single_shot := false):
	var node_name = 'AnimaNode_' + name
	var anima_node: Node

	for child in node.get_children():
		if child.name.find(node_name) >= 0:
			anima_node = child
			anima_node.clear()
			anima_node.stop()

			return anima_node

	if anima_node == null:
		anima_node = load('res://addons/anima/core/node.gd').new()
		anima_node.name = node_name

		anima_node._init_node(node)

	anima_node.set_single_shot(single_shot)

	return anima_node

func begin_single_shot(node: Node, name: String = "anima"):
	return begin(node, name, true)

func player(node: Node):
	var player = load('./player.gd').new()

	node.add_child(player)

	return player

func get_animation_path() -> String:
	return BASE_PATH

func register_animation(script, animation_name: String) -> void:
	_deregister_animation(animation_name)

	_custom_animations.push_back({ name = animation_name, script = script })

func _deregister_animation(animation_name: String) -> void:
	for animation in _custom_animations:
		if animation.name == animation_name:
			_custom_animations.erase(animation)

func get_available_animations() -> Array:
	if _animations_list.size() == 0:
		var list = _get_animations_list()
		var filtered := []

		for file in list:
			if file.find('.gd.') < 0 and file.find(".gd") > 0:
				filtered.push_back(file.replace('.gdc', '.gd'))

		_animations_list = filtered

	return _animations_list + _custom_animations

func get_available_animation_by_category() -> Dictionary:
	var animations = get_available_animations()
	var base = Anima.get_animation_path()
	var old_category := ''
	var result := {}

	for item in animations:
		var category_and_file = item.replace(base, '').split('/')
		var category = category_and_file[0]
		var file_and_extension = category_and_file[1].split('.')
		var file = file_and_extension[0]

		if not result.has(category):
			result[category] = []

		result[category].push_back(file)

	return result

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

class AnimaDeclarationBase:
	var _data := {}

	func get_data() -> Dictionary:
		return _data

	func anima_from(from):
		if from == null:
			return

		_data.from = from

		return self

	func anima_to(to):
		if to == null:
			return

		_data.to = to

		return self

	func anima_duration(duration: float):
		_data.duration = max(Anima.MINIMUM_DURATION, duration)

		return self

	func anima_delay(delay: float):
		_data.delay = delay

		return self

	func anima_animation(animation_name: String):
		if _data.has("property"):
			printerr("The property parameter have already been specified, so the animation one will be ignored.")

			return

		_data.animation = animation_name

		return self

	func anima_property(property_name):
		if _data.has("animation"):
			printerr("The animation parameter have already been specified, so the property one will be ignored.")

			return

		_data.property = property_name

		return self

	func anima_relative(relative: bool):
		_data.relative = relative

		return self

	func anima_easing(easing):
		_data.easing = easing

		return self

	func anima_pivot(pivot: int):
		_data.pivot = pivot

		return self

	func anima_visibility_strategy(strategy: int):
		_data.visibility_strategy = strategy

		return self

	func anima_on_started(on_started: FuncRef):
		_data.on_started = on_started

		return self

	func anima_on_completed(on_completed: FuncRef):
		_data.on_completed = on_completed

		return self

class AnimaDeclarationNode extends AnimaDeclarationBase:
	func node(node) -> AnimaDeclarationNode:
		_data.node = node

		return self

class AnimaDeclarationBaseGridGroup extends AnimaDeclarationBase:
	func anima_animation_type(type: int):
		_data.animation_type = type

		return self

	func anima_point(point: Vector2):
		_data.point = point

		return self

	func anima_items_delay(delay: float):
		_data.items_delay = delay

		return self

class AnimaDeclarationGroup extends AnimaDeclarationBaseGridGroup:
	func group(group: Node) -> AnimaDeclarationGroup:
		_data.group = group

		return self

class AnimaDeclarationGrid extends AnimaDeclarationBaseGridGroup:
	func grid(grid: Node) -> AnimaDeclarationGrid:
		_data.grid = grid

		return self

	func anima_grid_size(size: Vector2) -> AnimaDeclarationGrid:
		_data.grid_size = size

		return self

static func Node(node: Node) -> AnimaDeclarationNode:
	var c := AnimaDeclarationNode.new()

	return c.node(node)

static func Group(group: Node) -> AnimaDeclarationGroup:
	var c := AnimaDeclarationGroup.new()

	return c.group(group)

static func Grid(grid: Node) -> AnimaDeclarationGrid:
	var c := AnimaDeclarationGrid.new()

	return c.group(grid)

