tool
extends VBoxContainer
class_name AnimaCarousel

signal carousel_size_changed(new_size)
signal carousel_height_changed(final_height)
signal index_changed(new_index)

onready var _container: HBoxContainer = find_node('Container')
onready var _controls: HBoxContainer = find_node('Controls')

export (int) var index setget set_index
export (float) var duration = 0.3
export (float) var padding := 0.0
export (Anima.EASING) var scroll_easing = Anima.EASING.LINEAR
export (Anima.EASING) var height_easing = Anima.EASING.LINEAR

var _heights: Array

func _ready():
	for index in _controls.get_child_count():
		var child: Node = _controls.get_child(index)

		if child is Button:
			child.connect("pressed", self, "_on_control_pressed", [index])

	$Wrapper.anchor_right = 0

	_update_size()
	set_index(index)

func _update_size() -> void:
	var size: float = rect_size.x  * _container.get_child_count()

	_container.rect_min_size.x = size
	_container.rect_size.x = size

	for child in _container.get_children():
		var node: Control = child

		node.size_flags_horizontal = SIZE_EXPAND_FILL
		node.size_flags_vertical = 0

		_heights.push_back(node.rect_size.y)


func _maybe_get_container() -> void:
	_container = find_node('Container')

func get_active_index() -> int:
	return index

func set_index(new_index: int) -> void:
	_update_size()

	if not is_inside_tree():
		return

	var count: int = max(0, _container.get_child_count() - 1)
	index = clamp(new_index, 0, count)

	if _heights.size() == 0:
		return

	var x = rect_size.x * index
	var wrapper_height = get_expected_wrapper_height()
	var height = get_expected_height()

	var anima: AnimaNode = Anima.begin(self)
	anima.set_single_shot(true)

	anima.then(
		Anima.Node(self) \
			.anima_property("min_size:y") \
			.anima_to(height) \
			.anima_easing(height_easing) \
			.anima_duration(duration)
	)

	anima.also(
		Anima.Node(_container) \
			.anima_property("position:x") \
			.anima_to(-x) \
			.anima_easing(scroll_easing)
	)
	anima.also(
		Anima.Node($Wrapper) \
			.anima_property("size:y") \
			.anima_to(wrapper_height) \
			.anima_easing(height_easing)
	)
	anima.play()

	emit_signal("carousel_height_changed", height)
	emit_signal("index_changed", new_index)

func get_expected_wrapper_height() -> float:
	return _heights[index]

func get_expected_height() -> float:
	var height = _controls.rect_size.y + get_expected_wrapper_height()

	return height

func _on_Container_item_rect_changed() -> void:
	emit_signal("carousel_size_changed", rect_size)

func _on_control_pressed(index: int) -> void:
	set_index(index)
