tool
extends Button

var PROPERTIES_TO_COPY = ["rect_min_size", "text", "icon", "align", "clip_text", "icon_align", "expand_icon", "__meta__", "modulate"]

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
	REMOVE
}

export (STYLE) var style = STYLE.PRIMARY setget set_button_style
#export (float, 0.0, 1.0) var default_opacity := 1.0 setget set_default_opacity
var default_opacity := 1.0 setget set_default_opacity

const COLORS := {
	STYLE.PRIMARY: "#05445E",
	STYLE.SECONDARY: "#374140",
	STYLE.REMOVE: "#450003",
}

const PADDING := 24
const BORDER_RADIUS := 4.0

var _button_bg: Color = COLORS[0] setget _set_button_bg
var _old_draw_mode
var _force_default_zoom := true
var _font: DynamicFont
var _font_color: Color = get_color("font_color")
var _text_position: Vector2
var _text_size := Vector2.ZERO
var _box_style := StyleBoxFlat.new()

func _ready():
	_box_style.corner_radius_bottom_left = BORDER_RADIUS
	_box_style.corner_radius_bottom_right = BORDER_RADIUS
	_box_style.corner_radius_top_left= BORDER_RADIUS
	_box_style.corner_radius_top_right = BORDER_RADIUS

	_font = get_font("font")
#	_box_style.border_width_bottom = 1
#	_box_style.border_width_left = 1
#	_box_style.border_width_right = 1
#	_box_style.border_width_top = 1

	_calculate_text_size()
	_refresh_button(get_draw_mode())

func _calculate_text_size() -> void:
	_text_size = Vector2.ZERO

	if _font == null:
		_font = get_font("font")

	for c in text:
		var size := _font.get_char_size(c.to_ascii()[0])

		_text_size.y = max(_text_size.y, size.y)
		_text_size.x += size.x

	_text_position = (rect_size - _text_size) / 2

	if align == ALIGN_LEFT:
		_text_position.x = PADDING
	elif align == ALIGN_RIGHT:
		_text_position.x = rect_size.x - PADDING - _text_size.x

	_text_position.y = (rect_size.y / 2) + (_text_size.y / 2)

func _draw():
	if _font == null:
		_font = get_font("font")

	_box_style.bg_color = _button_bg
	_box_style.border_color = _button_bg.lightened(0.3)

	draw_style_box(_box_style, Rect2(Vector2.ZERO, rect_size))
	draw_string(_font, _text_position, text, _font_color)

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
	if property == "text":
		_calculate_text_size()

func _on_Button_minimum_size_changed():
	_calculate_text_size()
	update()
