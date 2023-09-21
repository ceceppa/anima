@tool
extends Window

@onready var List: VBoxContainer = find_child("ListContainer")

func _ready():
	print("here")
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

func _create_new_header(animation: String) -> Button:
	var button := Button.new()

	button.toggle_mode = true
	button.set_text(animation.replace('_', ' ').capitalize())
	button.pressed.connect(func():
#		var group: VBoxContainer = List.find_child("__" + animation)
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
	button.connect("pressed",Callable(self,'_on_animation_button_pressed').bind(button))

	return button

func _on_close_requested():
	hide()
