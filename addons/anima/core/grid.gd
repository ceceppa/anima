class_name AnimaGrid

signal animation_completed

var _children := []
var _initil_delay: float = 0.0
var _children_delay := 0.1
var _animation: AnimaNode
var _animation_name: String
var _animation_type: int
var _visibility_strategy: int
var _duration: float

func init(grid_node: Node, grid_size: Vector2) -> void:
	var rows = grid_size.x
	var columns = grid_size.y

	var row_items := []
	var index = 0

	for child in grid_node.get_children():
		row_items.push_back(child)

		index += 1
		if index >= columns:
			_children.push_back(row_items)
			row_items = []
			index = 0

	if row_items.size() > 0:
		_children.push_back(row_items)

	_animation = Anima.begin(grid_node, 'grid_sequence_top_left')
	_animation.connect("animation_completed", self, '_on_anima_animation_completed')

func play() -> void:
	_animation.play()

func set_animation(animation_name: String) -> void:
	_animation_name = animation_name

func set_start_delay(initial_delay: float) -> void:
	_initil_delay = initial_delay

func set_items_delay(item_delay: float) -> void:
	_children_delay = item_delay

func set_animation_type(animation_type: int) -> void:
	_animation_type = animation_type

func set_visibility_strategy(strategy: int) -> void:
	_visibility_strategy = strategy

func set_item_duration(duration: float) -> void:
	_duration = duration

func end() -> void:
	if _animation_type == Anima.Grid.SEQUENCE_TOP_LEFT:
		_generate_animation_sequence_top_left()

	_animation.set_visibility_strategy(_visibility_strategy)

func _generate_animation_sequence_top_left() -> void:
	var center_row = _children.size() / 2
	var center_cell = _children[center_row].size() / 2

	var delay = _initil_delay

	var animation_data = {}
	
	if _animation_name:
		animation_data.animation = _animation_name

	var index = 1
	for row in _children:
		for child in row:
			animation_data.node = child
			animation_data.duration = _duration
			animation_data.delay = _initil_delay + (_children_delay * index)

			_animation.with(animation_data)
			index += 1

func _on_anima_animation_completed() -> void:
	emit_signal("animation_completed")
