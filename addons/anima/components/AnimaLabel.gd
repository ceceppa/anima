tool
class_name AnimaLabel
extends Control

const SpriteLabel = preload('./helpers/SpriteLabel.gd')

export (String) var label = 'AnimaLabel' setget set_label
export (Font) var font setget set_font
export (Anima.Align) var align = Anima.Align.CENTER setget set_align
export (Anima.VAlign) var valign = Anima.VAlign.CENTER setget set_valign
export (Color) var font_color = Color.white setget set_font_color
export (Vector2) var text_offset = Vector2.ZERO setget set_text_offset_px
export (Vector2) var text_scale = Vector2(1, 1) setget set_text_scale

onready var _label := SpriteLabel.new()

func _ready():
	connect("resized", self, '_on_resized')

	set_clip_contents(true)

	_safe_set('label', label)
	_safe_set('font', font)
	_safe_set('align', align)
	_safe_set('valign', valign)
	_safe_set('font_color', font_color)
	_safe_set('text_offset', text_offset)
	_safe_set('scale', text_scale)

	_on_resized()

	add_child(_label)

func _process(_delta):
	if Engine.editor_hint:
		update()

func _safe_set(property: String, value, should_update := false) -> void:
	if not _label:
		return

	_label.set(property, value)
	
	if should_update:
		_label.update()

func set_label(new_label: String) -> void:
	label = new_label

	_safe_set('label', label)

func set_font(new_font: Font) -> void:
	font = new_font

	_safe_set('font', font)

	if font and not font.is_connected("changed", self, '_update_font'):
		font.connect("changed", self, '_update_font')

func set_align(new_align: int) -> void:
	align = new_align

	_safe_set('align', align)

func set_valign(new_valign: int) -> void:
	valign = new_valign

	_safe_set('valign', valign)

func set_font_color(new_color: Color) -> void:
	font_color = new_color

	_safe_set('font_color', font_color)

func set_text_offset_px(new_offset: Vector2) -> void:
	text_offset = new_offset

	_safe_set('text_offset', new_offset)

func set_text_scale(new_scale: Vector2) -> void:
	text_scale = new_scale

	_safe_set('scale', text_scale, true)

func _update_font() -> void:
	update()

func _on_resized():
	_safe_set('size', rect_size)
