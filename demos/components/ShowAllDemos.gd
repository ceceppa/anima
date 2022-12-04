extends Button

func _on_ShowAllDemos_pressed():
	get_tree().change_scene_to_file('res://demos/DemosSelector.tscn')
