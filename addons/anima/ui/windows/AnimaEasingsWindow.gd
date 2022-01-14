tool
extends "./AnimaBaseWindow.gd"

signal easing_selected(easing)

onready var _anima_logo: Sprite = find_node('Anima')
onready var _base_button: Button = find_node('BaseButton')
onready var _grid_in: GridContainer = find_node('GridIn')
onready var _grid_out: GridContainer = find_node('GridOut')
onready var _grid_in_out: GridContainer = find_node('GridInOut')

var _logo_origin: Vector2
var _easing: int = Anima.EASING.LINEAR

func _ready():
	for easing_name in Anima.EASING.keys():
		var easing_value = Anima.EASING[easing_name]
		var button := _base_button.duplicate()

		var text = easing_name

		button.show()
		button.connect("pressed", self, '_on_easing_button_pressed', [button, easing_value])

		if easing_name.find('_IN_OUT_') > 0 or easing_name == 'EASE_IN_OUT':
			text = text.replace('EASE_IN_OUT_', '')
			_grid_in_out.add_child(button)
		elif easing_name.find('_OUT') > 0 or easing_name == 'EASE_OUT':
			text = text.replace('EASE_OUT_', '')
			_grid_out.add_child(button)
		else:
			text = text.replace('EASE_IN_', '')
			_grid_in.add_child(button)

		button.text = text.replace('_', ' ').capitalize()

func _on_easing_button_pressed(button: Button, easing_value: int) -> void:
	var size = self.rect_size
	var logo_size = AnimaNodesProperties.get_size(_anima_logo)

	if _logo_origin == Vector2.ZERO:
		_logo_origin = _anima_logo.global_transform.origin

	var anima1 = Anima.begin(self, 'button')
	anima1.set_single_shot(true)
	anima1.then(
		Anima.Node(button) \
			.anima_animation("pulse") \
			.anima_duration(0.5)
	)
	anima1.play()

	var anima2 = Anima.begin(self, 'easings')
	var to: Vector2 = Vector2(rect_position.x + size.x - logo_size.x - 50, _logo_origin.y)

	anima2.set_single_shot(true)
	anima2.then(
		Anima.Node(_anima_logo) \
		.anima_property("position") \
		.anima_from(_logo_origin) \
		.anima_to(to) \
		.anima_easing(easing_value) \
		.anima_duration(1)
	)
	anima2.play()

	_easing = easing_value

func _on_ConfirmButton_pressed():
	emit_signal("easing_selected", _easing)

	hide()

func _on_CancelButton_pressed():
	hide()
