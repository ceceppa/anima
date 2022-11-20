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
	ROUND
}

export (STYLE) var style = STYLE.PRIMARY setget set_button_style

var default_opacity := 1.0 setget set_default_opacity

const COLORS := {
	STYLE.PRIMARY: "#05445E",
	STYLE.SECONDARY: "#374140",
	STYLE.REMOVE: "#450003",
	STYLE.ICON_ONLY: "#374140",
	STYLE.ROUND: "#457B9D",
}

onready var _label = find_node("Label")

var _button_bg: Color = COLORS[0] setget _set_button_bg
var _old_draw_mode
var _force_default_zoom := true
var _font: DynamicFont
var _font_color: Color = get_color("font_color")
var _text_position: Vector2
var _text_size := Vector2.ZERO
var _box_style := StyleBoxFlat.new()
var _left_padding = 24.0 setget set_left_padding

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
	_box_style.border_color = _button_bg.lightened(0.3)

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

		draw_texture(icon, position)

func _input(_event):
	var draw_mode = get_draw_mode()

	_refresh_button(draw_mode)

	_old_draw_mode = draw_mode

func _refresh_button(draw_mode: int) -> void:
	if draw_mode != _old_draw_mode:

		var color: Color = COLORS[style]
		var final_color = color
		var final_opacity := default_opacity

		if draw_mode == STATE.HOVERED:
			final_color = color.lightened(0.1)
			final_opacity = 1.0
		elif draw_mode == STATE.PRESSED:
			final_color = color.darkened(0.2)
			final_opacity = 1.0

		Anima.begin_single_shot(self) \
			.with(
				Anima.Node(self).anima_animation_frames({
					to = {
						_button_bg = final_color,
						opacity = final_opacity,
						easing = ANIMA.EASING.EASE_IN_EXPO
					}
				}, 0.15)
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

func set_default_opacity(new_opacity: float) -> void:
	default_opacity = new_opacity

	modulate.a = default_opacity

func _set(property, value):
	if _label == null:
		_label = find_node("_label")

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
