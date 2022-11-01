tool
extends Node

enum PORT {
	INPUT,
	OUTPUT
}

enum PORT_TYPE {
	LABEL_ONLY,
	ANIMATION,
	EVENT,
	ACTION,
}

enum NODE_TYPE {
	START,
	ANIMATION,
	ACTION,
	MUSIC
}

const PORT_COLOR = {
	PORT_TYPE.LABEL_ONLY: Color.transparent,
#	PORT_TYPE.ANIMATION: Color('#008484'),
	PORT_TYPE.ANIMATION: Color('#7C238C'),
	PORT_TYPE.EVENT: Color('#eb8937'),
	PORT_TYPE.ACTION: Color('#417799'),
}

const NODE_TYPE_COLOR = {
	NODE_TYPE.START: Color('#008484'),
#	NODE_TYPE.ANIMATION: Color('#737f96'),
	NODE_TYPE.ANIMATION: Color('#7C238C'),
	NODE_TYPE.ACTION: Color('#2f384d'),
	NODE_TYPE.MUSIC: Color('#183f28'),
}

enum VISUAL_ANIMATION_TYPE {
	ANIMATION,
	PROPERTY
}

# Title
const TITLE_BORDER_BOTTOM = Color(0.0, 0.0, 0.0, 0.8)
const TITLE_BORDER_WIDTH = 1.0
const TITLE_MARGIN_LEFT = 8.0
const TITLE_MARGIN_TOP = 4.0
const TITLE_BORDER_RADIUS = 8.0
const TITLE_MARGIN_BOTTOM = TITLE_MARGIN_TOP + TITLE_BORDER_WIDTH

# Frame
const FRAME_BG_COLOR = Color(0.101, 0.125, 0.172, 1.0)
const FRAME_BG_SELECTED_COLOR = FRAME_BG_COLOR
const FRAME_SHADOW_COLOR = Color(0, 0, 0, 0.1)
const FRAME_SHADOW_SELECTED_COLOR = Color.white
const FRAME_BODER_WIDTH = 0.0
const FRAME_SHADOW_SIZE = 8.0
const FRAME_CONTENT_MARGIN = 0.0
const FRAME_CONTENT_RADIUS = 8.0

const PORT_OFFSET = 0.0

# Row
const ROW_CONTENT_MARGIN_LEFT = 18.0
const ROW_CONTENT_MARGIN_RIGHT = 18.0
const ROW_SEPARATION = 1.0
const DISCONNECTED_LABEL_COLOR = Color(1.0, 1.0, 1.0, 0.5)
const CONNECTED_LABEL_COLOR = Color.white

# Used to get Godot Icons
var _godot_base_control: Control
var _anima_visual_node: Node

var _custom_animations := {}
var _animations_list := []

const _is_debug_enabled := false

const MAPPED_ICONS := {
	TYPE_REAL: 'float',
	TYPE_INT: 'int',
	TYPE_VECTOR2: 'Vector2',
	TYPE_VECTOR3: 'Vector3',
	TYPE_COLOR: 'Color',
	TYPE_RECT2: 'Rect2'
}

func create_row_for_node(index: int, input_label_text: String, input_tooltip: String, output_label_text: String, output_tooltip: String, input_default_value = null) -> PanelContainer:
	var row_container = load("res://addons/anima/ui/AnimaNodeRowContainer.tscn")
	var row = row_container.instance()

	row.set_name("Row" + str(index))
	row.add_stylebox_override('panel', generate_row_style())

	var input_label: Label = row.find_node("Label1")
	input_label.set_name("Input" + str(index))
	input_label.set_text(input_label_text)
	input_label.hint_tooltip = input_tooltip

	var output_label: Label = row.find_node("Label2")
	output_label.set_name("Output" + str(index))
	output_label.set_text(output_label_text)
	output_label.hint_tooltip = output_tooltip

	if input_default_value == null:
		row.hide_default_input_container()

	return row

func customise_node_style(node: GraphNode, title_node: PanelContainer, node_type: int) -> void:
	var node_color = NODE_TYPE_COLOR[node_type] if NODE_TYPE_COLOR.has(node_type) else Color.black
	var title_color = node_color

	apply_style_to_graph_node(node, node_color)
	apply_style_to_custom_title(title_node, title_color)

func apply_style_to_graph_node(node: GraphNode, node_color: Color) -> void:
	var frame_style = generate_frame_style(node_color)

	node.add_stylebox_override("frame", frame_style)

	# selected style
	var selected_style = generate_selected_frame_style(frame_style)
	node.add_stylebox_override("selectedframe", selected_style)

	# PORT offset
	override_port_offset(node)

	# Space between rows
	override_row_separation(node)

func apply_style_to_custom_title(title_node: PanelContainer , node_color: Color) -> void:
	var title_style = generate_title_style(node_color)
	var selected_style = generate_title_selected_style(node_color)

	title_node.set_style(title_style, selected_style)

func generate_frame_style(border_color: Color) -> StyleBoxFlat:
	var scale: float = get_dpi_scale()
	var style = StyleBoxFlat.new()

	style.border_color = border_color
	style.set_border_width_all(FRAME_BODER_WIDTH)

	style.set_bg_color(FRAME_BG_COLOR)
	style.content_margin_left = FRAME_CONTENT_MARGIN;
	style.content_margin_right = FRAME_CONTENT_MARGIN;

	style.set_corner_radius_all(FRAME_CONTENT_RADIUS * scale)

	style.shadow_size = FRAME_SHADOW_SIZE * scale
	style.shadow_color = FRAME_SHADOW_COLOR

	return style
	
func generate_selected_frame_style(base_style: StyleBoxFlat):
	var style = base_style.duplicate()

	style.border_color = FRAME_BG_SELECTED_COLOR
	style.shadow_color = FRAME_SHADOW_SELECTED_COLOR
	style.shadow_size = FRAME_SHADOW_SIZE / 2

	return style

func generate_row_style() -> StyleBoxEmpty:
	var scale: float = get_dpi_scale()
	var style: StyleBoxEmpty = StyleBoxEmpty.new()

	style.content_margin_left = ROW_CONTENT_MARGIN_LEFT * scale;
	style.content_margin_right = ROW_CONTENT_MARGIN_RIGHT * scale;

	return style

func override_port_offset(node: GraphNode):
	node.add_constant_override("port_offset", PORT_OFFSET)

func override_row_separation(node: GraphNode):
	node.add_constant_override("separation", ROW_SEPARATION)

func generate_title_style(color: Color):
	var scale: float = get_dpi_scale()
	var style = StyleBoxFlat.new()

	style.border_color = color
	style.set_bg_color(color)

	style.content_margin_left = TITLE_MARGIN_LEFT * scale;
	style.content_margin_right = TITLE_MARGIN_LEFT * scale;
	style.content_margin_top = TITLE_MARGIN_TOP * scale;
	style.content_margin_bottom = TITLE_MARGIN_BOTTOM * scale;

	style.set_corner_radius(CORNER_TOP_LEFT, TITLE_BORDER_RADIUS * scale)
	style.set_corner_radius(CORNER_TOP_RIGHT, TITLE_BORDER_RADIUS * scale)

	style.set_border_width(MARGIN_BOTTOM, TITLE_BORDER_WIDTH)
	style.border_color = TITLE_BORDER_BOTTOM

	return style

func generate_title_selected_style(color: Color):
	var style = generate_title_style(color)

	style.border_color = color
	style.set_bg_color(color)

	style.border_color = FRAME_BG_SELECTED_COLOR

	return style

func generate_row_slot_panel_style():
	var scale: float = get_dpi_scale()
	var style = StyleBoxFlat.new()

	var color = Color.transparent
	style.border_color = color
	style.set_bg_color(color)

	return style

func get_dpi_scale() -> float:
	return 1.0
#	return OS.get_screen_dpi() / 256.0

func set_godot_gui(base_control: Control) -> void:
	_godot_base_control = base_control

func get_godot_icon(name: String) -> Texture:
	if _godot_base_control:
		return _godot_base_control.get_icon(name, "EditorIcons")

	return null

func get_node_icon(node: Node) -> Texture:
	var node_icon: Texture = get_godot_icon(node.get_class())

	if node.has_method('get_editor_icon'):
		node_icon = node.get_editor_icon()

	return node_icon

func debug(caller, v1: String, v2 = "", v3 = "", v4 = "", v5 = "", v6 = "") -> void:
	if not _is_debug_enabled:
		return

	printt(caller, v1, v2, v3, v4, v5, v6)

func get_godot_icon_for_type(type: int) -> Texture:
	if MAPPED_ICONS.has(type):
		return get_godot_icon(MAPPED_ICONS[type])

	return get_godot_icon('KeyValue')
	
