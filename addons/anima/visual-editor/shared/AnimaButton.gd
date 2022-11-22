tool
extends Button

const PADDING := 24.0
const BORDER_RADIUS := 4.0
const ICON_LEFT := 8

enum STATE {
	NORMAL,
	PRESSED
	HOVERED,
	DISABLED,
	DRAW_HOVER_PRESSED,
}

enum STYLE {
	PRIMARY,
	SECONDARY,
	REMOVE,
	ICON_ONLY,
	ROUND,
	TRANSPARENT
}

export (STYLE) var style = STYLE.PRIMARY setget set_button_style

var COLORS := {
	STYLE.PRIMARY: "#05445E",
	STYLE.SECONDARY: "#374140",
	STYLE.REMOVE: "#450003",
	STYLE.ICON_ONLY: "#374140",
	STYLE.ROUND: "#457B9D",
	STYLE.TRANSPARENT: Color(0.02, 0.266, 0.3686, 0.0),
}

onready var _label = find_node("Label")

var _button_bg: Color = COLORS[0] setget _set_button_bg
var _old_draw_mode: int = DRAW_NORMAL
var _force_default_zoom := true
var _font: DynamicFont
var _font_color: Color = get_color("font_color")
var _text_position: Vector2
var _text_size := Vector2.ZERO
var _box_style := StyleBoxFlat.new()
var _left_padding = 24.0 setget set_left_padding
var _icon_color := Color.white

func _ready():
	_box_style.corner_radius_bottom_left = BORDER_RADIUS
	_box_style.corner_radius_bottom_right = BORDER_RADIUS
	_box_style.corner_radius_top_left= BORDER_RADIUS
	_box_style.corner_radius_top_right = BORDER_RADIUS

	_set("text", text)
	_set("align", align)

	_update_padding()
	_refresh_button(get_draw_mode())

func _draw():
	_box_style.bg_color = _button_bg

#	_box_style.border_color = _button_bg.lightened(0.3)

	if style == STYLE.ROUND:
		_box_style.corner_radius_bottom_left = 50
		_box_style.corner_radius_bottom_right = 50
		_box_style.corner_radius_top_left = 50
		_box_style.corner_radius_top_right = 50

	draw_style_box(_box_style, Rect2(Vector2.ZERO, rect_size))

	if icon:
		var icon_size := icon.get_size()
		var position: Vector2 = Vector2(ICON_LEFT, (rect_size.y - icon_size.y) / 2)

		if icon_align == ALIGN_RIGHT:
			position.x = rect_size.x - ICON_LEFT - icon_size.x
		elif icon_align == ALIGN_CENTER or style == STYLE.ICON_ONLY:
			position.x = (rect_size.x - icon_size.x) / 2

		draw_texture(icon, position, _icon_color)

func _input(_event):
	var draw_mode = get_draw_mode()

	if draw_mode != _old_draw_mode:
		_refresh_button(draw_mode)

	_old_draw_mode = draw_mode

func _get_bg_color(draw_mode: int) -> Color:
	var color: Color = COLORS[style]

	if style == STYLE.TRANSPARENT and draw_mode != DRAW_NORMAL:
		color = COLORS[STYLE.PRIMARY]

	var final_color = color
	
	_icon_color = Color.white

	if draw_mode == STATE.HOVERED:
		final_color = color.lightened(0.1)
	elif draw_mode == STATE.PRESSED and not toggle_mode:
		final_color = color.darkened(0.2)
	elif draw_mode == STATE.DISABLED:
		_icon_color = Color("#666")
		final_color = color
		final_color.a = 0

	return final_color

func _refresh_button(draw_mode: int) -> void:
	if draw_mode != _old_draw_mode:
		var final_color: Color = _get_bg_color(draw_mode)

		Anima.begin_single_shot(self) \
			.with(
				Anima.Node(self).anima_property("_button_bg", final_color, 0.15)
			) \
			.play()

func set_button_style(new_style: int) -> void:
	style = new_style
	
	_set_button_bg(COLORS[new_style])

	update()

func _set_button_bg(new_bg: Color) -> void:
	_button_bg = new_bg

	update()

func _on_Button_button_down():
	_refresh_button(get_draw_mode())

func _on_Button_button_up():
	_refresh_button(get_draw_mode())

func _set(property, value):
	if _label == null:
		_label = find_node("_label")
	
	if property == "disabled":
		var mode = DRAW_DISABLED if value else DRAW_NORMAL

#		_refresh_button(mode)

	if not _label:
		return

	if property == "text":
		_label.text = value
	elif property == "align":
		_label.align = value
		
func set_text(text: String) -> void:
	if not _label:
		_label = find_node("Label")

	if _label:
		_label.text = text

func set_left_padding(padding: float) -> void:
	_left_padding = padding

	_update_padding()

func _update_padding() -> void:
	var normal_style_box = get_stylebox("normal").duplicate()

	if _label == null:
		_label = find_node("_label")

	if normal_style_box and _left_padding != 24:
		normal_style_box.content_margin_left = _left_padding
		normal_style_box.content_margin_right = PADDING

		add_stylebox_override("normal", normal_style_box)

	if style == STYLE.ROUND:
		normal_style_box.corner_radius_bottom_left = 50
		normal_style_box.corner_radius_bottom_right = 50
		normal_style_box.corner_radius_top_left = 50
		normal_style_box.corner_radius_top_right = 50

		add_stylebox_override("normal", normal_style_box)

	if _label and _left_padding != 24:
		var label_style_box = _label.get_stylebox("normal").duplicate()

		label_style_box.content_margin_left = _left_padding
		label_style_box.content_margin_right = PADDING

		_label.add_stylebox_override("normal", label_style_box)
