tool
extends "./_base_signals.gd"

signal node_updated

var _node_body_data := []
var _node_id: String
var _node_to_animate: Node
var _old_offset: Vector2
var _anima: AnimaNode

enum BodyDataType {
	SLOT,
	ROW
}

onready var DPI_SCALE = AnimaUI.get_dpi_scale()

func _init():
	_anima = Anima.begin(self)
	_anima.then({ property = "scale", from = Vector2.ZERO, duration = 0.3, easing = Anima.EASING.EASE_OUT_BACK, pivot = Anima.PIVOT.CENTER })
	_anima.also({ property = "opacity", from = 0, to = 1 })
	_anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

	_custom_title = load('res://addons/anima/ui/AnimaCustomNodeTitle.tscn').instance()
	add_child(_custom_title)

	set_show_close_button(false)

	_custom_title.connect("hide_content", self, "_on_hide_content")
	_custom_title.connect("show_content", self, "_on_show_content")
	_custom_title.connect('play_animation', self, '_on_play_animation')
	_custom_title.connect('remove_node', self, '_on_remove_node')

	connect("offset_changed", self, "_on_offset_changed")

	rect_min_size = (get_minimum_size() + Vector2(200, 150)) * AnimaUI.get_dpi_scale()

func _ready():
	setup()
	render()
	_after_render()

func _after_render() -> void:
	var position = get_position_in_parent() - 3

	_adjust_font_size(self)
	_anima.play()

#
# TODO: Is this the right way to handle different screen DPI?
#
func _adjust_font_size(start_node: Node) -> void:
	for child in start_node.get_children():
		if child.has_meta("_font_changed"):
			continue

		if child and child.has_method("get_font"):
			var font: DynamicFont = child.get_font("font")

			if font and not font.has_meta("_original_size"):
				font.set_meta("_original_size", font.size)
				font.size *= DPI_SCALE

				child.add_font_override("font", font)
				child.set_meta("_font_changed", true)


		if child.get_child_count() > 0:
			_adjust_font_size(child)

func register_node(node_data: Dictionary) -> void:
	var dpi_scale = OS.get_screen_dpi() / 60.0
	
	if node_data.has('category'):
		set_category(node_data.category)

	if node_data.has('title'):
		var name = node_data.title + "@" + str(get_instance_id())
		set_custom_title(node_data.title, name)

	if node_data.has('category') and node_data.has('name'):
		set_id(node_data.category + '/' + node_data.name)

	if not node_data.has('type'):
		printerr("Specify node type!")

		return

	if node_data.has('icon'):
		set_icon(node_data.icon)

	if node_data.has('playable') and not node_data.playable:
		_custom_title.hide_play_button()

	if node_data.has('deletable') and not node_data.deletable:
		_custom_title.hide_remove_button()

	if node_data.has('min_size'):
		rect_min_size = get_minimum_size() + node_data.min_size * dpi_scale

	_node_id = node_data.id

	set_type(node_data.type)

func set_category(category: String) -> void:
	node_category = category

func set_id(fullQualifiedName: String) -> void:
	if not '/' in fullQualifiedName:
		printerr('Invalid node identifier, please use: [Category]/[Node]')
		
		return

	node_id = fullQualifiedName

func set_type(type: int) -> void:
	_node_type = type

func set_icon(icon) -> void:
	_custom_title.set_icon(icon)

func set_custom_title(title: String, nodeName = null) -> void:
	if nodeName:
		name = nodeName
		set_title("")

	_custom_title.set_title(title)

func get_title() -> String:
	return _custom_title.get_title()

func get_id() -> String:
	return _node_id

func add_slot(data: Dictionary) -> void:
	_node_body_data.push_back({type = BodyDataType.SLOT, io_data = data})

func add_custom_input_slot(node: Node, name: String, type: int) -> void:
	var io_data := {
		node = node,
		input = {
			label = name,
			type = type,
		}
	}

	_node_body_data.push_back({type = BodyDataType.SLOT, io_data = io_data})

func add_custom_output_slot(node: Node, name: String, type: int) -> void:
	var io_data := {
		node = node,
		output = {
			label = name,
			type = type,
		}
	}

	_node_body_data.push_back({type = BodyDataType.SLOT, io_data = io_data})

func add_custom_row(node = Node) -> void:
	_node_body_data.push_back({type = BodyDataType.ROW, node = node})

func add_divider() -> void:
	var separator := HSeparator.new()
	
	separator.size_flags_horizontal = SIZE_EXPAND_FILL
	_node_body_data.push_back({type = BodyDataType.ROW, node = separator})

func add_spacer() -> void:
	var separator := Label.new()
	
	separator.size_flags_horizontal = SIZE_EXPAND_FILL
	_node_body_data.push_back({type = BodyDataType.ROW, node = separator})

func add_label(v: String, tooltip: String) -> void:
	var label := Label.new()
	
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.align = VALIGN_CENTER
	label.modulate.a = 0.4
	label.set_text(v)
	label.hint_tooltip = tooltip

	_node_body_data.push_back({type = BodyDataType.ROW, node = label})

# Godot automatically adds the slot next to the element added.
# So to have a right and left label, we need to wrap them inside
# a HBoxContainer
func _add_slot_labels(index: int, input_slot: Dictionary, output_slot: Dictionary, add := true) -> PanelContainer:
	var input_label_text: String = input_slot.label if input_slot.has('label') else ''
	var input_tooltip: String = input_slot.tooltip if input_slot.has('tooltip') else ''
	var input_default_value = input_slot.default if input_slot.has('default') else null

	var output_label_text: String = output_slot.label if output_slot.has('label') else ''
	var output_tooltip: String = output_slot.tooltip if output_slot.has('tooltip') else ''

	var slots_row: PanelContainer = AnimaUI.create_row_for_node(
		index,
		input_label_text,
		input_tooltip,
		output_label_text,
		output_tooltip,
		input_default_value
	)

	if add:
		add_child(slots_row)

	return slots_row

func render() -> void:
	AnimaUI.customise_node_style(self, _custom_title, _node_type)

	for index in _node_body_data.size():
		var data: Dictionary = _node_body_data[index]

		if data.type == BodyDataType.ROW:
			add_child(data.node)

			continue

		var io_data = data.io_data if data.has('io_data') else {}
		var input_slot: Dictionary = {}
		var output_slot: Dictionary = {}

		if io_data.has('input'):
			input_slot = io_data.input

		if io_data.has('output'):
			output_slot = io_data.output

		if io_data.has('node'):
			add_child(io_data.node)

			continue

		_add_slot_labels(index, input_slot, output_slot)

	_setup_slots()

func _setup_slots() -> void:
	clear_all_slots()

	for index in _node_body_data.size():
		var data: Dictionary = _node_body_data[index]
		var slot_index: int = index + 1

		if data.type == BodyDataType.ROW:
			.set_slot(slot_index, false, TYPE_NIL, Color.transparent, false, TYPE_NIL, Color.transparent)

			continue

		var input_slot: Dictionary = {}
		var output_slot: Dictionary = {}
		var io_data = data.io_data if data.has('io_data') else {}

		if io_data.has('input'):
			input_slot = io_data.input

		if io_data.has('output'):
			output_slot = io_data.output

		var input_default_value = input_slot.default if input_slot.has('default') else null
		var input_slot_type: int = input_slot.type if input_slot.has('type') else 0
		var input_slot_enabled: bool = input_slot.has('type')

		var output_slot_type: int = output_slot.type if output_slot.has('type') else 0
		var output_slot_enabled: bool = output_slot.has('type')

		if input_slot_type == AnimaUI.PORT_TYPE.LABEL_ONLY:
			input_slot_enabled = false

		if output_slot_type == AnimaUI.PORT_TYPE.LABEL_ONLY:
			output_slot_enabled = false

		var input_color: Color = AnimaUI.PORT_COLOR[input_slot_type]
		var output_color: Color = AnimaUI.PORT_COLOR[output_slot_type]

		.set_slot(slot_index, input_slot_enabled, input_slot_type, input_color, output_slot_enabled, output_slot_type, output_color, null, null)

func _add_row_slot_control(row_slot_control: Control) -> void:
	var container = PanelContainer.new()
	container.set_name('RowSlot')
	container.add_stylebox_override("panel", AnimaUI.generate_row_slot_panel_style())

	container.add_child(row_slot_control)
	add_child(container)

func restore_data(_data: Dictionary) -> void:
	pass

func get_data() -> Dictionary:
	return {}

func _on_play_animation():
	pass

func _on_offset_changed() -> void:
	if offset != _old_offset:
		emit_signal("node_updated")

	_old_offset = offset

func _on_remove_node() -> void:
	remove()

func _on_show_content() -> void:
	pass

func _on_hide_content() -> void:
	pass
