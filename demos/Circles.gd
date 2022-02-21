extends Control

onready var _center = rect_size / 2

var _count := 0
var _main_radius := 200
var _offset := 8
var _angles := []

func _ready():
	Anima.register_animation(self, 'circle')

	_init_circles()

func _init_circles() -> void:
	var offset := 0
	var index := 0
	for i in range(0, 24):
		var degrees = index * _offset
		var angle = deg2rad(degrees)
		var circle := AnimaCircle.new()
		var w: float = float(i) / 36.0

		circle.radius = 14

		if w <= 0.5:
			circle.color = Color.red.linear_interpolate(Color.blue, w)
		else:
			circle.color = Color.blue.linear_interpolate(Color.red, w)

		circle.rect_position = _center + Vector2(sin(angle) * _main_radius, cos(angle) * _main_radius)

		$Circles.add_child(circle)

		_angles.push_back(angle)

		index += 1

		if i > 0 and i % 12 == 0:
			offset += 12
			index += 12

	_animate_circle()

func _animate_circle() -> void:
	var anima := Anima.begin(self)

	_count += 1

	anima.then({ group = $Circles, duration = 0.3, items_delay = 0.01, animation = 'circle', easing = Anima.EASING.EASE_IN_CUBIC })

	anima.play_with_delay(0.5)

func circle(anima_tween: AnimaTween, data: Dictionary) -> void:
	var index = data._node_index
	var angle = _angles[index]

	angle -= deg2rad(45)
	
	var final_position: Vector2 = _center + Vector2(sin(angle) * _main_radius, cos(angle) * _main_radius)

	anima_tween.add_frames(data, 'position', [ { to = final_position } ])

	_angles[index] = angle
