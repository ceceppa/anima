@tool
extends VBoxContainer

signal pivot_height_changed(new_size)
signal pivot_point_selected

@onready var _pivot_points = find_child("PivotPoints")
@onready var _grid_container = find_child('GridContainer')
@onready var _point_button = find_child("PointButton")

var _selected_pivot_point := 0

func _ready():
	for child in _grid_container.get_children():
		var button: Button = child

		button.connect("pressed",Callable(self,"_on_pivot_button_pressed"))

	_toggle_pivot_points()

func _toggle_pivot_points() -> void:
	_pivot_points.visible = _point_button.pressed

	emit_signal("pivot_point_selected")

func _on_IgnoreButton_pressed():
	_selected_pivot_point = -1

	_toggle_pivot_points()

func _on_PointButton_pressed():
	_selected_pivot_point = _grid_container.get_child(0).group.get_pressed_button().get_index()

	_toggle_pivot_points()

func _on_pivot_button_pressed() -> void:
	for child in _grid_container.get_children():
		var button: Button = child

		if button.pressed:
			var anima: AnimaNode = Anima.begin(button)
			anima.set_single_shot(true)

			anima.then(
				Anima.Node(button) \
					super.anima_animation("pulse", 0.5)
			)
			anima.play()

			_selected_pivot_point = button.get_index()

	emit_signal("pivot_point_selected")

func set_value(value: int) -> void:
	_selected_pivot_point= value

	if _selected_pivot_point > 0:
		_grid_container.get_child(_selected_pivot_point).button_pressed = true
		_point_button.button_pressed = true

	_toggle_pivot_points()

func get_value() -> int:
	return _selected_pivot_point
