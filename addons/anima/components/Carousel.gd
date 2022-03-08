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

	update_size()
	set_index(index)

func update_size() -> void:
	if _container == null:
		return

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
	update_size()

	if not is_inside_tree() or get_child_count() == 0:
		return

	if _container == null:
		_container = find_node('Container')

	var count: int = max(0, _container.get_child_count() - 1)
	index = clamp(new_index, 0, count)

	if _heights.size() == 0:
		return

	#
	# Need to set the mouse filter to ignore for the children that are
	# not "visible", otherwise they stop interaction of the mouse in the
	# AnimaEditor
	#
	for child_index in get_child_count():
		var filter = MOUSE_FILTER_PASS if child_index == index else MOUSE_FILTER_IGNORE
		var node: Node = get_child(child_index)

		if node is Control:
			node.mouse_filter = filter

	var x = rect_size.x * index
	var wrapper_height = get_expected_wrapper_height()
	var height = get_expected_height()

	var anima: AnimaNode = Anima.begin(self)
	anima.set_single_shot(true)
	anima.set_default_duration(duration)

	anima.then(
		Anima.Node(self) \
			.anima_property("min_size:y", height) \
			.anima_easing(height_easing)
	)

	anima.with(
		Anima.Node(_container) \
			.anima_position_x(-x) \
			.anima_easing(scroll_easing)
	)
	anima.with(
		Anima.Node($Wrapper) \
			.anima_size_y(wrapper_height) \
			.anima_easing(height_easing)
	)
	anima.play()

func get_expected_wrapper_height() -> float:
	return _heights[index]

func get_expected_height() -> float:
	var height = _controls.rect_size.y + get_expected_wrapper_height()

	return height

func _on_Container_item_rect_changed() -> void:
	emit_signal("carousel_size_changed", rect_size)

func _on_control_pressed(index: int) -> void:
	print("settami")
	set_index(index)

func _on_Carousel_item_rect_changed():
#	set_index(index)
	pass
