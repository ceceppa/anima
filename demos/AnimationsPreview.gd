extends Control

onready var _control_or_spirte: HBoxContainer = find_node('ControlOrSprite')
onready var _mesh_container: Spatial = find_node("MeshContainer")
onready var _2d_container: VBoxContainer = find_node("2DContainer")
onready var _duration: LineEdit = find_node("DurationEdit")
onready var _control_test := find_node("ControlTest")
onready var _sprite_test := find_node("SpriteTest")
onready var _list_container := find_node("ListContainer")
onready var _mesh_cube := find_node("MeshInstance")

var _anima_panel: AnimaNode

func _ready():
	_anima_panel = Anima.begin(find_node("Panel"))
	var p: Panel = $HBoxContainer/Panel
	var style: StyleBoxFlat = p.get_stylebox("panel")

	_anima_panel.then({ property = style, key = "bg_color", from = Color("25252a"), to = Color.transparent, duration = 0.3 })
	_anima_panel.also({ node = _2d_container, animation = "fadeOutRight" })
	_setup_list()

func _setup_list() -> void:
	var animations = Anima.get_available_animations()
	var base = Anima.BASE_PATH
	var old_category := ''

	for item in animations:
		var category_and_file = item.replace(base, '').split('/')
		var category = category_and_file[0]
		var file_and_extension = category_and_file[1].split('.')
		var file = file_and_extension[0]

		if category != old_category:
			var header = create_new_header(category)
			_list_container.add_child(header)

		var button := Button.new()
		button.set_text(file.replace('_', ' ').capitalize())
		button.set_text_align(Button.ALIGN_LEFT)
		button.set_meta('script', file)
		button.connect("pressed", self, '_on_animation_button_pressed', [button])

		_list_container.add_child(button)
		old_category = category

func create_new_header(text: String) -> PanelContainer:
	var container := PanelContainer.new()
	var label := Label.new()

	label.set_text(text.replace('_', ' ').capitalize())
	container.add_child(label)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color('#404553')
	style.content_margin_top = 12
	style.content_margin_left = 8
	style.content_margin_bottom = 12
	style.content_margin_right = 8

	container.add_stylebox_override('panel', style)

	return container

func _on_animation_button_pressed(button: Button) -> void:
	var script_name: String = button.get_meta('script')
	var is_2d = find_node("2D").pressed

	var duration = float(_duration.text)

	if is_2d:
		_play_animation(_control_test, button)
		_play_animation(_sprite_test, button)
	else:
		_play_animation(_mesh_cube, button)

func _play_animation(node: Node, button: Button):
	var script_name: String = button.get_meta('script')

	var duration = float(_duration.text)
	var parent = node.get_parent()
	var clone = node.duplicate()

	_remove_duplicate(parent, node)

	parent.add_child(clone)
	clone.show()
	node.hide()

	var anima = Anima.begin(clone, 'control_test')
	anima.then({ node = clone, animation = script_name, duration = duration })
	anima.play()
	
	yield(anima, "animation_completed")

	if $Timer.is_stopped():
		$Timer.start()

func _remove_duplicate(parent: Node, node_to_ignore: Node) -> void:
	for child in parent.get_children():
		if child != node_to_ignore:
			child.queue_free()

func _on_control_animation_completed(animation_player: AnimationPlayer) -> void:
	print(animation_player)

func _on_ControlCheckbox_pressed():
	var control_label := find_node("ControlLabel")
	var control_container := find_node("ControlContainer")
	var is_visible = find_node("ControlCheckbox").pressed

	control_label.visible = is_visible
	control_container.visible = is_visible

func _on_SpriteCheckbox_pressed():
	var sprite_label := find_node("SpriteLabel")
	var sprite_container := find_node("SpriteContainer")
	var is_visible = find_node("SpriteCheckbox").pressed

	sprite_label.visible = is_visible
	sprite_container.visible = is_visible

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	anima_tween.add_animation_data(data)
	return


func _on_Timer_timeout():
	_remove_duplicate(_control_test.get_parent(), _control_test)
	_remove_duplicate(_sprite_test.get_parent(), _sprite_test)
	
	_control_test.show()
	_sprite_test.show()

func _on_3D_pressed():
	if _mesh_container.visible:
		return

	_mesh_container.show()
	_anima_panel.play()

func _on_2D_pressed():
	if not _mesh_container.visible:
		return

	_anima_panel.play_backwards()

	yield(_anima_panel, "animation_completed")
	_mesh_container.hide()
