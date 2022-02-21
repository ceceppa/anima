tool

extends Panel

signal pressed

const COLOR_CHANGE = 0.3

enum Style {
	DEFAULT,
	PRIMARY,
	SECONDARY
}

enum Status {
	NORMAL,
	HOVERED,
	CHECKED,
	PRESSED
}

const BgColors = {
	Style.DEFAULT: Color('#e0e0e0'),
	Style.PRIMARY: Color('#1976d2'),
	Style.SECONDARY: Color('#dc004e')
}

const PressedColors = {
	Style.DEFAULT: Color('#afafaf'),
	Style.PRIMARY: Color('#5986b4'),
	Style.SECONDARY: Color('#b84d73')
}

const FontColors = {
	Style.DEFAULT: Color(0, 0, 0, 0.87),
	Style.PRIMARY: Color(1, 1, 1),
	Style.SECONDARY: Color(1, 1, 1)
}

export (String) var _label = 'Label' setget _set_label
export (Style) var _style = Style.DEFAULT setget _set_style

var _bg_color = BgColors[Style.DEFAULT] setget _set_bg_color
var _font_color = FontColors[Style.DEFAULT] setget _set_font_color

var _is_hovering := false
var _is_pressed := false

onready var _anima: AnimaNode = Anima.begin(self)

func _init() -> void:
	_anima = Anima.begin(self)

func _ready():
	_set_bg_color(BgColors[_style])
	_set_font_color(FontColors[_style])

func _set_label(label: String) -> void:
	_label = label
	$Label.text = label

func _set_style(new_style: int) -> void:
	_style = new_style

	_animate_bg_color(BgColors[_style], FontColors[_style])

func _set_bg_color(color: Color) -> void:
	_bg_color = color

	var normal = get_stylebox('panel').duplicate()
	normal.bg_color = _bg_color

	add_stylebox_override('panel', normal)

func _set_font_color(color: Color) -> void:
	_font_color = color

	$Label.set("custom_colors/font_color", color)

func _animate_bg_color(bg_color: Color, font_color: Color) -> void:
	_anima.clear()
	_anima.then({ property = "_bg_color", to = bg_color, duration = COLOR_CHANGE })
	_anima.with({ property = "_font_color", to = font_color, duration = COLOR_CHANGE })
	_anima.play()

func _on_Button_mouse_entered():
	_animate_bg_color(BgColors[_style].darkened(0.4), FontColors[_style])
	_is_hovering = true

func _on_Button_mouse_exited():
	_animate_bg_color(BgColors[_style], FontColors[_style])
	_is_hovering = false

func _on_Button_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			_animate_bg_color(PressedColors[_style], FontColors[_style])
			_is_pressed = true

		if not event.pressed and _is_pressed:
			_on_Button_mouse_entered()

			_is_pressed = false
			
			emit_signal("pressed")
