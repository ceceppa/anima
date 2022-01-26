tool
extends VBoxContainer

signal pivot_height_changed(new_size)
signal pivot_point_selected

onready var _grid_container = find_node('GridContainer')
onready var _carousel = find_node('Carousel')

var _pivot_point: int

func _ready():
	for child in _grid_container.get_children():
		var button: Button = child

		button.connect("pressed", self, "_on_pivot_button_pressed")

func _on_Carousel_carousel_size_changed(new_size: Vector2):
	var new_height: float = 32 + new_size.y

	rect_min_size.y = new_height
	rect_size.y = new_height
	
func _switch_carousel() -> void:
	var index := 0

	if $HBoxContainer/PointButton.pressed:
		index = 1

	$Carousel.set_index(index)

func _on_IgnoreButton_pressed():
	_switch_carousel()

func _on_PointButton_pressed():
	_switch_carousel()

func _on_Carousel_carousel_height_changed(final_height: float):
	emit_signal('pivot_height_changed', final_height)

func _on_pivot_button_pressed() -> void:
	for child in _grid_container.get_children():
		var button: Button = child

		if button.pressed:
			var anima: AnimaNode = Anima.begin(button)
			anima.set_single_shot(true)

			anima.then(
				Anima.Node(self) \
					.anima_animation("pulse") \
					.anima_duration(0.5)
			)
			anima.play()

			_pivot_point = button.get_index()

	emit_signal("pivot_point_selected")

func set_value(values: Array) -> void:
	var index: int = values[0]
	_pivot_point = values[1]

	_carousel.set_index(index)
	$HBoxContainer.get_child(index).pressed = true

	if _pivot_point > 0:
		_grid_container.get_child(_pivot_point).pressed = true

func get_value() -> Array:
	return [_carousel.get_active_index(), _pivot_point]

func _on_Carousel_index_changed(new_index: int):
	if new_index == 0:
		_pivot_point = -1

	emit_signal("pivot_point_selected")
