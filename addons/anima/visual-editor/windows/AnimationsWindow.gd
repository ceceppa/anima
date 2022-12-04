@tool
extends "./AnimaBaseWindow.gd"

signal animation_selected(label, name)

@onready var _list_container = find_child('ListContainer')
@onready var _confirm_button = find_child('ConfirmButton')
@onready var _control_demo: Control = find_child('ControlTest')
@onready var _sprite_demo: CanvasItem = find_child('SpriteTest')

var _animation_name: String
var _animation_script_name: String
var _source_node: Node

func show_demo_by_type(node: Node) -> void:
	var is_control_demo_visible = node is Control

	if _control_demo:
		_control_demo.get_parent().visible = is_control_demo_visible
		_sprite_demo.get_parent().get_parent().visible = not is_control_demo_visible
	else:
		_source_node = node

func _ready():
	super._ready()

	_setup_list()

	if _source_node:
		show_demo_by_type(_source_node)
		
func _setup_list() -> void:
	var animations = AnimaAnimationsUtils.get_available_animations()
	var base = AnimaAnimationsUtils.get_animation_path()
	var old_category := ''
	var group = ButtonGroup.new()

	for item in animations:
		var category_and_file: PackedStringArray = item.replace(base, '').split('/')
		if category_and_file.size() < 2:
			continue

		var category = category_and_file[0]
		var file_and_extension = category_and_file[1].split('.')
		var file = file_and_extension[0]

		if category != old_category:
			var header = _create_new_header(category)
			_list_container.add_child(header)

		var button := Button.new()
		button.set_text(file.replace('_', ' ').capitalize())
		button.set_text_alignment(Button.ALIGN_LEFT)
		button.set_meta('script', file)
		button.toggle_mode = true
		button.group = group
		button.connect("pressed",Callable(self,'_on_animation_button_pressed').bind(button))

		_list_container.add_child(button)
		old_category = category

func _create_new_header(text: String) -> PanelContainer:
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

	container.add_theme_stylebox_override('panel', style)

	return container

func _on_animation_button_pressed(button: Button) -> void:
	var script_name: String = button.get_meta('script')

	$AnimaNode.clear()

	var duration = 0.5

	var node1 := _clone_elements(_control_demo, button)
	var node2 := _clone_elements(_sprite_demo, button)

	_animation_name = button.text
	_animation_script_name = script_name
	
	_play_animation(node1, node2, _animation_script_name)

func _clone_elements(node: Node, button: Button) -> Node:
	var script_name: String = button.get_meta('script')

	var parent = node.get_parent()
	var clone = node.duplicate()

	_remove_duplicate(parent, node)

	parent.add_child(clone)
	clone.show()
	node.hide()

	return clone

func _play_animation(node1: Node, node2: Node, animation_name: String) -> void:
	$AnimaNode.then(
		Anima.Node(node1).anima_animation(animation_name, 0.5)
	)\
	super.with(
		Anima.Node(node2).anima_animation(animation_name, 0.5)
	)\
	super.play()

	await $AnimaNode.animation_completed

	if $Timer.is_stopped():
		$Timer.start()

func _remove_duplicate(parent: Node, node_to_ignore: Node) -> void:
	for child in parent.get_children():
		if child != node_to_ignore:
			child.queue_free()

func _on_control_animation_completed(animation_player: AnimationPlayer) -> void:
	pass

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	anima_tween.add_animation_data(data)
	return

func _on_Timer_timeout():
	var control := _control_demo
	var sprite := _sprite_demo
	
	_remove_duplicate(control.get_parent(), control)
	_remove_duplicate(sprite.get_parent(), sprite)
	
	sprite.show()
	control.show()

func _on_CancelButton_pressed():
	hide()

func _on_ConfirmButton_pressed():
	emit_signal("animation_selected", _animation_name, _animation_script_name)

	hide()
