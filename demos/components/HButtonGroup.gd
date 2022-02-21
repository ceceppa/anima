extends HBoxContainer

func _ready():
	for index in get_children().size():
		var child = get_child(index)

		child.connect('pressed', self, '_on_child_pressed', [index])

func _on_child_pressed(index: int) -> void:
	for child in get_children():
		child.set_checked(false)

	get_child(index).set_checked(true)
