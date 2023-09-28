@tool
extends VBoxContainer

@onready var List: VBoxContainer = find_child("ListContainer")
@onready var DemoLabel: Label = find_child("DemoLabel")

signal animation_selected(name: String)
signal close_pressed

var _anima: AnimaNode
var _animation_name: String

func _ready():
	var animations = AnimaAnimationsUtils.get_available_animation_by_category()
	
	for group in animations:
		List.add_child(_create_new_header(group))
		
		var container := VBoxContainer.new()

		container.name = "__" + group
		container.hide()

		for animation in animations[group]:
			container.add_child(_create_animation_button(animation))


		List.add_child(container)
		List.add_spacer(false)

	_anima = Anima.begin(DemoLabel)

func _create_new_header(animation: String) -> Button:
	var button := Button.new()

	button.toggle_mode = true
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
	var button := Button.new()

	button.text = label.replace('_', ' ').capitalize()
	button.set_text_alignment(HORIZONTAL_ALIGNMENT_LEFT)
	button.set_meta('_animation', label)
	button.pressed.connect(_on_animation_button_pressed.bind(label))
	return button

func _on_close_requested():
	hide()

func _on_animation_button_pressed(animation_name: String):
	_animation_name = animation_name

	_anima.reset_and_clear()

	var anima := _anima.then( Anima.Node(DemoLabel).anima_animation(animation_name) ).play()

	await anima.animation_completed

	anima.reset_and_clear()

func _on_use_animation_pressed():
	animation_selected.emit(_animation_name)

func _on_close_button_pressed():
	close_pressed.emit()
