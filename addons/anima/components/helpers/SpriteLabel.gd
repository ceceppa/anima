tool
extends Sprite

var label := 'AnimaLabel' setget set_label
var font: Font setget set_font
var align: int = Anima.Align.CENTER setget set_align
var valign: int = Anima.VAlign.CENTER setget set_valign
var font_color := Color.white setget set_font_color
var text_offset := Vector2.ZERO setget set_text_offset_px
var text_scale := Vector2(1, 1) setget set_text_scale
var container_scale := Vector2(1, 1) setget set_container_scale
var size: Vector2 setget set_size

var _old_label: String
var _old_text_size: Vector2

func _ready():
	connect("item_rect_changed", self, '_on_item_rect_changed')
	set_centered(false)

func _draw():
	if not font:
		return

	var char_size: Vector2 = font.get_char_size(97)
	var text_size = get_size()
	var my_size: Vector2 = size / scale

	var position := Vector2(0, char_size.y / 2)
	
	if align == Anima.Align.CENTER:
		position.x = (my_size.x - text_size.x) / 2
	elif align == Anima.Align.RIGHT:
		position.x = my_size.x - text_size.x

	if valign == Anima.Align.CENTER:
		position.y = (my_size.y / 2) + (text_size.y / 4)
	elif valign == Anima.VAlign.BOTTOM:
		position.y = my_size.y

	draw_string(font, position + text_offset, label, font_color)

func get_size() -> Vector2:
	if label == _old_label:
		return _old_text_size

	var width := 0.0
	var height := 0.0
	for letter in label:
		var char_size: Vector2 = font.get_char_size(letter.to_ascii()[0])

		width += char_size.x
		height = max(height, char_size.y)

	_old_text_size = Vector2(width, height)

	return _old_text_size

func set_label(new_label: String) -> void:
	label = new_label

	update()

func set_font(new_font: Font) -> void:
	font = new_font

	if font and not font.is_connected("changed", self, '_update_font'):
		font.connect("changed", self, '_update_font')

func set_align(new_align: int) -> void:
	align = new_align

	update()

func set_valign(new_valign: int) -> void:
	valign = new_valign

	update()

func set_font_color(new_color: Color) -> void:
	font_color = new_color

	update()

func set_text_offset_px(new_offset: Vector2) -> void:
	text_offset = new_offset

	update()

func set_text_scale(new_scale: Vector2) -> void:
	text_scale = new_scale

	update()

func set_container_scale(new_scale: Vector2) -> void:
	container_scale = new_scale

	update()

func set_size(new_size: Vector2) -> void:
	size = new_size

	update()

func _on_item_rect_changed() -> void:
	update()
