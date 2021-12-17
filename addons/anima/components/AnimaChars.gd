tool
extends HBoxContainer
class_name AnimaChars

enum Splitting {
	LETTER,
	WORD,
	CUSTOM
}

export (String) var label = 'Anima' setget set_label
export (Splitting) var split = Splitting.LETTER setget set_split
export (String) var custom_splitting setget set_custom_splitting
export (Font) var font setget set_font
export (Color) var font_color setget set_font_color
export (float) var letter_spacing = 0 setget set_letter_spacing
export (ShaderMaterial) var letters_shader setget set_letters_shader

var _anima_label: AnimaLabel
var _old_label: String
var _old_split: int
var _old_splitted_label

func _ready():
	connect("item_rect_changed", self, '_update_label')
	_update_label()

func _draw():
	_update_label()

func set_label(new_label: String) -> void:
	label = new_label

	update()

func set_font(new_font: Font) -> void:
	font = new_font

	update()

func set_letter_spacing(spacing: float) -> void:
	letter_spacing = spacing

	update()

func set_font_color(color: Color) -> void:
	font_color = color

	update()

func set_custom_splitting(custom: String) -> void:
	custom_splitting = custom

	update()

func set_split(s: int) -> void:
	split = s

	update()

func set_letters_shader(value: ShaderMaterial) -> void:
	letters_shader = value

	for child in get_children():
		child.set_label_shader(value)

func _update_label() -> void:
	var anima_label = _get_anima_label()
	var parts = _split_label()
	var length = parts.size() if parts is Array else parts.length()

	for index in length:
		var letter = parts[index]
		var clone = null

		if get_child_count() > index:
			clone = get_child(index)
		else:
			clone = _anima_label.duplicate()
			clone.name = 'AnimaLabel' + str(index)

			add_child(clone)

		clone.mouse_filter = mouse_filter
		clone.set_label(letter)
		clone.set_should_auto_resize(true)
		clone.set_label_shader(letters_shader)
		clone.show()

	for child_index in range(get_child_count() - 1, length - 1, -1):
		var child = get_child(child_index)

		remove_child(child)

	add_constant_override("separation", letter_spacing)
	_update_font_and_size()

func _split_label() -> Array:
	if label == _old_label and split != Splitting.CUSTOM and split == _old_split:
		return _old_splitted_label

	if split == Splitting.LETTER:
		return label

	_old_split = split

	var splitting_symbol = ' ' if split == Splitting.WORD else custom_splitting
	var parts = label.split(splitting_symbol)
	var result := []

	for part in parts:
		result.push_back(part)
		result.push_back(splitting_symbol)

	return result.slice(0, -2)

func _update_font_and_size() -> void:
	if font == null:
		return

	for child in get_children():
		child.set_font(font)
		child.set_font_color(font_color)

		var width = 0

		for letter in child.label:
			var size = font.get_char_size(letter.to_ascii()[0])

			width += size.x + letter_spacing

		var child_size = Vector2(width, rect_min_size.y)

		child.set_size(child_size)

func _get_anima_label() -> AnimaLabel:
	if _anima_label:
		return _anima_label

	_anima_label = AnimaLabel.new()
	_anima_label.set_should_auto_resize(true)
	_anima_label.size_flags_horizontal = SIZE_FILL
	_anima_label.size_flags_vertical = SIZE_FILL

	return _anima_label

func _on_AnimaChars_item_rect_changed():
	update()
