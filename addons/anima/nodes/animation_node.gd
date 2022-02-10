tool
extends "./_base_node.gd"

const ANIMATION_CONTROL = preload("res://addons/anima/nodes/AnimaAnimationControl.tscn")

var _animation_control
var _animation_control_data: Dictionary = {}

func _init():
	register_node({
		category = 'Anima',
		id = 'Animation',
		title = 'Animation',
#		icon = 'res://addons/anima/icons/node.svg',
		type = AnimaUI.NODE_TYPE.ANIMATION,
		min_size = Vector2(320, 0)
	})


func setup():
	add_slot({
		input = {
			label = "animate",
			type = AnimaUI.PORT_TYPE.ANIMATION,
		},
		output = {
			label = "then",
			type = AnimaUI.PORT_TYPE.ANIMATION,
			tooltip = tr("Animates the next node when this one has been completed")
		}
	})

	add_slot({
		output = {
			label = "with",
			type = AnimaUI.PORT_TYPE.ANIMATION,
			tooltip = tr("Animates the next node at the same time of this one")
		}
	})

#	TODO: Implement also
#	add_slot({
#		output = {
#			label = "also",
#			type = AnimaUI.PORT_TYPE.ANIMATION,
#			tooltip = tr("This is used to animate a different property for this node")
#		}
#	})

	add_slot({
		output = {
			label = "on_started",
			type = AnimaUI.PORT_TYPE.ACTION,
			tooltip = tr("Execute an action when the animation starts")
		}
	})
	add_slot({
		output = {
			label = "on_completed",
			type = AnimaUI.PORT_TYPE.ACTION,
			tooltip = tr("Execute an action when the animation completes")
		}
	})

	_animation_control = ANIMATION_CONTROL.instance()
	_animation_control.set_source_node(_node_to_animate)
	_animation_control.connect("animation_updated", self, "_on_animation_selected")

	_animation_control.connect("content_size_changed", self, "_on_animation_control_content_size_changed")

	add_custom_row(_animation_control)

func _after_render() -> void:
	_animation_control.restore_data(_animation_control_data)
	
	._after_render()
	
	AnimaUI.debug(self, '_after_render')

func set_node_to_animate(node: Node, node_path: String) -> void:
	AnimaUI.debug(self, 'set node to animate', node)

	_node_to_animate = node

	set_custom_title(node_path)
	_custom_title.set_tooltip(node_path)

	set_icon(AnimaUI.get_node_icon(node))

func get_node_to_animate_path() -> NodePath:
	var root = AnimaUI.get_selected_anima_visual_node().get_source_node()
	
	return root.get_path_to(_node_to_animate)

func restore_data(data: Dictionary) -> void:
	_animation_control_data = data

func get_data() -> Dictionary:
	return _animation_control.get_animation_data()

func connect_input(slot: int, from: Node, from_slot: int) -> void:
	.connect_input(slot, from, from_slot)

	# also?
	if from_slot == 2:
		var time_data: VBoxContainer = find_node('TimeData', true, false)
		var duration = time_data.find_node('Duration')
		var delay = time_data.find_node('Delay')
		var data: Dictionary = from.get_data()

		duration.clear_value()
		duration.set_can_edit_value(false)

		delay.clear_value()
		delay.set_can_clear_custom_value(true)

func _on_animation_selected() -> void:
	emit_signal("node_updated")

func _on_animation_control_content_size_changed(new_size: float) -> void:
	var min_height := 15.0 * AnimaUI.get_dpi_scale()

	for child in get_children():
		if child is Control:
			min_height += child.rect_size.y

	var to := min_height + new_size

	_animate_height(to)

func _animate_height(to: float) -> void:
	var anima: AnimaNode = Anima.begin(self, 'resizeMe')
	anima.set_single_shot(true)

	anima.then(
		Anima.Node(self) \
			.anima_property("size:y", to, 0.3) \
			.anima_easing(Anima.EASING.EASE_OUT_BACK)
	)

	anima.play()

func _on_show_content() -> void:
	_animation_control.show()

	_animate_height(_animation_control.rect_size.y)

func _on_hide_content() -> void:
	_animation_control.hide()
	
	_animate_height(0)

func _on_play_animation() -> void:
	var visual_node: AnimaVisualNode = AnimaUI.get_selected_anima_visual_node()
	var visual_data: Dictionary = get_data()

	visual_node.preview_animation(_node_to_animate, visual_data.duration, visual_data.delay, visual_data.animation_data)
