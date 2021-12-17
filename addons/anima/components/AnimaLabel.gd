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
export (ShaderMaterial) var label_shader setget set_label_shader
export (bool) var make_label_shader_unique = false setget set_make_label_shader_unique

var should_auto_resize := false setget set_should_auto_resize

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
	_update_label_shader()
	_on_resized()

	add_child(_label)

func _safe_set(property: String, value, should_update := false) -> void:
	if not _label:
		return

	_label.set(property, value)
	
	if should_update:
		_label.update()

	_auto_resize()

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

func set_should_auto_resize(should: bool) -> void:
	should_auto_resize = should

	_auto_resize()

func set_label_shader(value: ShaderMaterial) -> void:
	label_shader = value

	_update_label_shader()

func set_make_label_shader_unique(is_unique: bool) -> void:
	make_label_shader_unique = is_unique

	_update_label_shader()

func _update_label_shader() -> void:
	var shader = label_shader

	if shader == null:
		return

	if make_label_shader_unique:
		shader = shader.duplicate()

	_safe_set('label_shader', shader)

func _update_font() -> void:
	_safe_set('font', font)

func _on_resized():
	_safe_set('size', rect_size)
	
func _auto_resize() -> void:
	if not _label:
		return

	if should_auto_resize:
		var size = _label.get_size()

		rect_min_size.x = size.x
		rect_size.x = size.x
