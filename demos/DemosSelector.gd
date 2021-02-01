extends VBoxContainer

func _change_scene(path: String) -> void:
	get_tree().change_scene(path)

func _on_ButtonAnimations_pressed():
	_change_scene('res://demos/AnimationsPreview.tscn')


func _on_ButtonEasings_pressed():
	_change_scene("res://demos/Easings.tscn")

func _on_Button1_pressed():
	_change_scene("res://demos/AnimateGroup.tscn")

func _on_ButtonSequence_pressed():
	_change_scene("res://demos/SequenceAndParallel.tscn")

func _on_ButtonCallbacks_pressed():
	_change_scene("res://demos/SequenceCallback.tscn")

func _on_ButtonSequence2_pressed():
	_change_scene("res://demos/SequenceWithParallel.tscn")

func _on_Button3DRings_pressed():
	_change_scene("res://demos/Rings.tscn")
