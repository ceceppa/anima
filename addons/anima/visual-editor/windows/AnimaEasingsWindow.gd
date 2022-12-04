@tool
extends "./AnimaBaseWindow.gd"

signal easing_selected(easing_name, easing_value)

@onready var _anima_logo: Sprite2D = find_child('Anima')
@onready var _base_button: Button = find_child('BaseButton')
@onready var _grid_in: GridContainer = find_child('GridIn')
@onready var _grid_out: GridContainer = find_child('GridOut')
@onready var _grid_in_out: GridContainer = find_child('GridInOut')

var _logo_origin: Vector2
var _easing: int = ANIMA.EASING.LINEAR
var _easing_name: String

func _ready():
	for easing_name in ANIMA.EASING.keys():
		var easing_value = ANIMA.EASING[easing_name]
		var button := _base_button.duplicate()

		var text = easing_name

		button.show()
		button.connect("pressed",Callable(self,'_on_easing_button_pressed').bind(button, easing_value))

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
	var size = self.size
	var logo_size = AnimaNodesProperties.get_size(_anima_logo)

	if _logo_origin == Vector2.ZERO:
		_logo_origin = _anima_logo.global_transform.origin

	var anima1 = Anima.begin(self, 'button')
	anima1.set_single_shot(true)
	anima1.then(
		Anima.Node(button) \
			super.anima_animation("pulse", 0.5)
	)
	anima1.play()

	var anima2 = Anima.begin(self, 'easings')
	var to: Vector2 = Vector2(position.x + size.x - logo_size.x - 50, _logo_origin.y)

	anima2.set_single_shot(true)
	anima2.then(
		Anima.Node(_anima_logo) \
		super.anima_property("position", 1) \
		super.anima_from(_logo_origin) \
		super.anima_to(to) \
		super.anima_easing(easing_value)
	)
	anima2.play()

	_easing = easing_value
	_easing_name = "Ease" + button.get_parent().get_parent().name + button.text

func _on_ConfirmButton_pressed():
	emit_signal("easing_selected", _easing_name, _easing)

	hide()

func _on_CancelButton_pressed():
	hide()
