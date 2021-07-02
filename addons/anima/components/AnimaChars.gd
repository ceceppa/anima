tool
extends HBoxContainer

const ANIMA_LABEL = preload('res://addons/anima/components/AnimaLabel.tscn')

export (String) var _label = 'Anima' setget set_label
export (Font) var _font setget set_font
export (Color) var _font_color setget set_font_color
export (float) var _letter_spacing = 0 setget set_letter_spacing
export (bool) var _group_by_words setget set_group_by_words

var _anima_label: AnimaLabel

func _ready():
	_update_label()

func _draw():
	_update_label()

func set_label(label: String) -> void:
	if label == _label:
		return

	_label = label

	update()

func set_font(font: Font) -> void:
	_font = font

	if _font == null:
		return

	update()

func set_letter_spacing(spacing: float) -> void:
	_letter_spacing = spacing

	update()

func set_font_color(color: Color) -> void:
	_font_color = color

	update()

func set_group_by_words(group: bool) -> void:
	_group_by_words = group

	update()

func _update_label() -> void:
	var anima_label = _get_anima_label()
	var parts = _label
	var length = parts.length()
	
	if _group_by_words:
		parts = _label.split(' ')
		length = parts.size()


	for index in length:
		var letter = parts[index]
		var clone = null

		if get_child_count() > index:
			clone = get_child(index)
		else:
			clone = _anima_label.duplicate()
			clone.name = 'AnimaLabel' + str(index)
			add_child(clone)

		clone.set_label(letter)
		clone.show()

	for child_index in range(length, get_child_count()):
		var child = get_child(child_index)

		remove_child(child)

	_update_font_and_size()

func _update_font_and_size() -> void:
	if _font == null:
		return

	for child in get_children():
		child.set_font(_font)
		child.set_font_color(_font_color)

		var width = 0

		for letter in child._label:
			var size = _font.get_char_size(letter.to_ascii()[0])

			width += size.x + _letter_spacing

		var child_size = Vector2(width, rect_min_size.y)

		child.set_size(child_size)

func _get_anima_label() -> AnimaLabel:
	if _anima_label:
		return _anima_label

	_anima_label = ANIMA_LABEL.instance()
	_anima_label.size_flags_horizontal = SIZE_FILL
	_anima_label.size_flags_vertical = SIZE_FILL

	return _anima_label

func _on_AnimaChars_item_rect_changed():
	update()
