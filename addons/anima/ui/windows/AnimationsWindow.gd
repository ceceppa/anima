tool
extends "./AnimaBaseWindow.gd"

signal animation_selected(label, name)

onready var _list_container = find_node('ListContainer')
onready var _confirm_button = find_node('ConfirmButton')
onready var _control_demo: Control = find_node('ControlTest')
onready var _sprite_demo: CanvasItem = find_node('SpriteTest')

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
	._ready()

	_setup_list()

	if _source_node:
		show_demo_by_type(_source_node)

func _setup_list() -> void:
	var animations = AnimaAnimationsUtils.get_available_animations()
	var base = Anima.get_animation_path()
	var old_category := ''
	var group = ButtonGroup.new()

	for item in animations:
		var category_and_file: PoolStringArray = item.replace(base, '').split('/')
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
		button.set_text_align(Button.ALIGN_LEFT)
		button.set_meta('script', file)
		button.toggle_mode = true
		button.group = group
		button.add_font_override("font", _confirm_button.get_font("font"))
		button.connect("pressed", self, '_on_animation_button_pressed', [button])

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

	container.add_stylebox_override('panel', style)

	return container

func _on_animation_button_pressed(button: Button) -> void:
	var script_name: String = button.get_meta('script')

	var duration = 0.5

	_play_animation(_control_demo, button)
	_play_animation(_sprite_demo, button)

	_animation_name = button.text
	_animation_script_name = script_name

func _play_animation(node: Node, button: Button):
	var script_name: String = button.get_meta('script')

	var duration = float(0.5)
	var parent = node.get_parent()
	var clone = node.duplicate()

	_remove_duplicate(parent, node)

	parent.add_child(clone)
	clone.show()
	node.hide()

	var anima = Anima.begin(clone, 'control_test')
	anima.then(
		Anima.Node(clone) \
			.anima_animation(script_name) \
			.anima_duration(duration)
	)
	anima.play()
	
	yield(anima, "animation_completed")

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
