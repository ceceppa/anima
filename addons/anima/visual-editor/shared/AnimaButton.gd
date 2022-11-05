tool
extends Button

var PROPERTIES_TO_COPY = ["rect_size", "rect_min_size", "text", "icon", "align", "clip_text", "icon_align", "expand_icon", "__meta__"]

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

const COLORS := {
	STYLE.PRIMARY: "#05445E",
	STYLE.SECONDARY: "#374140",
	STYLE.REMOVE: "#450003",
}

var _button_bg: Color = COLORS[0] setget _set_button_bg
var _old_draw_mode

func _ready():
	$Inner.rect_min_size = rect_min_size
	$Inner.rect_size = rect_size

	_old_draw_mode = get_draw_mode()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, rect_size), _button_bg, true)

	if not flat:
		draw_rect(Rect2(Vector2.ZERO, rect_size), _button_bg.lightened(0.3), false, 1.0)

func _input(_event):
	var draw_mode = get_draw_mode()

	_refresh_button(draw_mode)

	_old_draw_mode = draw_mode

func _refresh_button(draw_mode: int) -> void:
	if draw_mode != _old_draw_mode:
		var color: Color = COLORS[style]
		var final_color = color

		if draw_mode == STATE.HOVERED:
			final_color = color.lightened(0.1)
		elif draw_mode == STATE.PRESSED:
			final_color = color.darkened(0.2)

		Anima.begin_single_shot(self) \
			.with(
				Anima.Node(self).anima_property("_button_bg", final_color, 0.15)
			) \
			.play()

func _set(property, value):
	if PROPERTIES_TO_COPY.find(property) >= 0:
		$Inner.set(property, value)

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
