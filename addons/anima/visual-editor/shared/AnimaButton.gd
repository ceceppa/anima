@tool
extends Button

const PADDING := 24.0
const BORDER_RADIUS := 4.0
const ICON_LEFT := 8

enum STATE {
	NORMAL,
	PRESSED,
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
}

@export var style: STYLE = STYLE.PRIMARY :
	get:
		return style
	set(mod_value):
		style = mod_value

		queue_redraw()

@export var transparent := false :
	get:
		return transparent
	set(mod_value):
		transparent = mod_value
	
		_old_draw_mode = -1
		
		queue_redraw() #_refresh_button(get_draw_mode())

var COLORS := {
	STYLE.PRIMARY: "#05445E",
	STYLE.SECONDARY: "#374140",
	STYLE.REMOVE: "#450003",
	STYLE.ICON_ONLY: "#374140",
	STYLE.ROUND: "#457B9D",
}

@onready var _label = find_child("Label")

var _button_bg: Color = COLORS[0] :
	get:
		return _button_bg # TODOConverter40 Non existent get function 
	set(mod_value):
		_button_bg = mod_value

		queue_redraw()

var _old_draw_mode: int = DRAW_NORMAL
var _force_default_zoom := true
var _font: FontFile
var _font_color: Color = Color.WHITE # = get_color("font_color")
var _text_position: Vector2
var _text_size := Vector2.ZERO
var _box_style := StyleBoxFlat.new()
var _left_padding = 24.0 :
	get:
		return _left_padding
	set(mod_value):
		_left_padding = mod_value

		_update_padding()

var _icon_color := Color.WHITE
var _ignore_toggle_mode := false
var _disabled_icon_color = Color("#a0a0a0")
var _override_draw_mode

func _ready():
	_box_style.corner_radius_bottom_left = BORDER_RADIUS
	_box_style.corner_radius_bottom_right = BORDER_RADIUS
	_box_style.corner_radius_top_left= BORDER_RADIUS
	_box_style.corner_radius_top_right = BORDER_RADIUS

	_set("text", text)
	_set("alignment", alignment)

	_update_padding()
	_refresh_button(get_draw_mode())

func _draw():
	_box_style.bg_color = _button_bg

	if style == STYLE.ROUND:
		_box_style.corner_radius_bottom_left = 50
		_box_style.corner_radius_bottom_right = 50
		_box_style.corner_radius_top_left = 50
		_box_style.corner_radius_top_right = 50

	draw_style_box(_box_style, Rect2(Vector2.ZERO, size))

	if icon:
		var icon_size := icon.get_size()
		var position: Vector2 = Vector2(ICON_LEFT, (size.y - icon_size.y) / 2)

		if icon_alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			position.x = size.x - ICON_LEFT - icon_size.x
		elif icon_alignment == HORIZONTAL_ALIGNMENT_CENTER or style == STYLE.ICON_ONLY:
			position.x = (size.x - icon_size.x) / 2

		draw_texture(icon, position, _icon_color)

func _input(_event):
	var draw_mode = get_draw_mode()

	if draw_mode != _old_draw_mode:
		_refresh_button(draw_mode)

	_old_draw_mode = draw_mode

func _get_bg_color(draw_mode: int) -> Color:
	var color: Color = COLORS[style]

	var final_color = color
	var final_opacity = 0 if transparent else 1

	_icon_color = Color.WHITE

	if draw_mode == STATE.HOVERED:
		final_color = color.lightened(0.1)
		final_opacity = 1
	elif draw_mode == STATE.PRESSED and not _ignore_toggle_mode:
		final_color = color.darkened(0.3)
		final_opacity = 1
	elif draw_mode == STATE.DISABLED:
		_icon_color = _disabled_icon_color
		final_color = color
		final_opacity = 0

	final_color.a = final_opacity

	if not _ignore_toggle_mode and draw_mode == STATE.HOVERED and button_pressed:
		final_color.darkened(0.2)

	return final_color

func _refresh_button(draw_mode: int, force := false) -> void:
	var mode = draw_mode if _override_draw_mode == null else _override_draw_mode

	if mode != _old_draw_mode or force:
		var final_color: Color = _get_bg_color(draw_mode)

		Anima.begin_single_shot(self) \
			.with(
				Anima.Node(self).anima_property("_button_bg", final_color, 0.15)
			) \
			.play()

func set_button_style(new_style: int) -> void:
	style = new_style
	
	_set_button_bg(COLORS[new_style])

	queue_redraw()

func _set_button_bg(new_bg: Color) -> void:
	_button_bg = new_bg

	queue_redraw()

func _on_Button_button_down():
	_refresh_button(get_draw_mode())

func _on_Button_button_up():
	_refresh_button(get_draw_mode())

func _set(property, value):
	if _label == null:
		_label = find_child("_label")
	
	if property == "disabled":
		var mode = DRAW_DISABLED if value else DRAW_NORMAL

#		_refresh_button(mode)

	if not _label:
		return

	if property == "text":
		_label.text = value
	elif property == "alignment":
		_label.horizontal_alignment = value

func set_text(text: String) -> void:
	if not _label:
		_label = find_child("Label")

	if _label:
		_label.text = text

func _update_padding() -> void:
	var normal_style_box = get_theme_stylebox("normal").duplicate()

	if _label == null:
		_label = find_child("_label")

	if normal_style_box and _left_padding != 24:
		normal_style_box.content_margin_left = _left_padding
		normal_style_box.content_margin_right = PADDING

		add_theme_stylebox_override("normal", normal_style_box)

	if style == STYLE.ROUND:
		normal_style_box.corner_radius_bottom_left = 50
		normal_style_box.corner_radius_bottom_right = 50
		normal_style_box.corner_radius_top_left = 50
		normal_style_box.corner_radius_top_right = 50

		add_theme_stylebox_override("normal", normal_style_box)

	if _label and _left_padding != 24:
		var label_style_box = _label.get_stylebox("normal").duplicate()

		label_style_box.content_margin_left = _left_padding
		label_style_box.content_margin_right = PADDING

		_label.add_theme_stylebox_override("normal", label_style_box)

func _on_Button_toggled(button_pressed):
	_refresh_button(get_draw_mode())

func _maybe_show_group_data():
	pass # Replace with function body.

func set_transparent(t: bool) -> void:
	transparent = t
	
	_old_draw_mode = -1
	
	_refresh_button(get_draw_mode())
