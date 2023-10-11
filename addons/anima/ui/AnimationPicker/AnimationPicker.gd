@tool
extends VBoxContainer

const HEADER_BUTTON = preload("res://addons/anima/ui/AnimationPicker/HeaderButton.tscn")
const ANIMATION_BUTTON = preload("res://addons/anima/ui/AnimationPicker/AnimationButton.tscn")

@onready var List: VBoxContainer = find_child("ListContainer")
@onready var DemoControl: Control = find_child("DemoControl")
@onready var AnimationSpeed: LineEdit = find_child("AnimationSpeed")

signal animation_selected(name: String)
signal close_pressed

var _anima: AnimaNode
var _animation_name: String

func _ready():
	var animations = AnimaAnimationsUtils.get_available_animation_by_category()
	var is_first_header := true

	AnimationSpeed.set_text(str(ANIMA.DEFAULT_DURATION))

	for group in animations:
		var header: Button = _create_new_header(group)
		List.add_child(header)
		
		var container := VBoxContainer.new()

		container.add_theme_constant_override("separation", 0)
		container.name = "__" + group
		container.hide()

		for animation in animations[group]:
			container.add_child(_create_animation_button(animation))

		List.add_child(container)
		List.add_spacer(false)

		if is_first_header:
			header.set_pressed(true)
			container.show()

		is_first_header = false

	_anima = Anima.begin(DemoControl)

func _create_new_header(animation: String) -> Button:
	var button: Button = HEADER_BUTTON.instantiate()

	button.set_text(animation.replace('_', ' ').capitalize())
	button.pressed.connect(func():
		var group: VBoxContainer

		for child in List.get_children():
			if child.name == "__" + animation:
				group = child

				break

		group.visible = button.is_pressed()
	)

	return button

func _create_animation_button(label: String) -> Button:
	var button: Button = ANIMATION_BUTTON.instantiate()

	button.text = label.replace('_', ' ').capitalize()
	button.set_meta('_animation', label)
	button.pressed.connect(_on_animation_button_pressed.bind(label))

	return button

func _on_close_requested():
	hide()

func _on_animation_button_pressed(animation_name: String):
	_animation_name = animation_name

	_anima.reset_and_clear()

	var anima := _anima.then( 
		Anima.Node(DemoControl).anima_animation(animation_name, AnimationSpeed.get_text().to_float())
	).play()

	await anima.animation_completed

func _on_use_animation_pressed():
	animation_selected.emit(_animation_name)

func _on_close_button_pressed():
	close_pressed.emit()
