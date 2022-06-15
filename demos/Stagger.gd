extends Control

const Y_INCREMENT := 90

onready var _start_position = $ball.position
var _anima: AnimaNode

func _ready():
	$ball.hide()

	_init_balls()

	_anima = Anima.begin(self)

func _init_balls() -> void:
	var ball: Sprite = $ball

	for child in $Node.get_children():
		$Node.remove_child(child)

	for i in 5:
		var clone: Sprite = ball.duplicate()

		clone.position = _start_position
		clone.position.y += Y_INCREMENT * i
		clone.show()

		$Node.add_child(clone)

func _apply_animation(animation_type: int) -> void:
	_init_balls()

	_anima.clear()

	_anima.then({ group = $Node, animation_type = animation_type, duration = 0.5, property = "x", to = 800, easing = ANIMA.EASING.EASE_OUT_BACK })
	_anima.play_with_delay(0.1)
	
func _on_First_pressed() -> void:
	_apply_animation(Anima.GRID.SEQUENCE_TOP_LEFT)

func _on_Last_pressed():
	_apply_animation(Anima.GRID.SEQUENCE_BOTTOM_RIGHT)

func _on_Center_pressed():
	_apply_animation(Anima.GRID.FROM_CENTER)
