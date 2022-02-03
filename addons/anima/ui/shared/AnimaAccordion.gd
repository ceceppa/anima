tool
extends VBoxContainer

const COLLAPSED_VALUE := "./Title:size:y" 
const EXPANDED_VALUE := "./Title:size:y + ./ContentWrapper/MarginContainer:size:y"

export var label := "Accordion" setget set_label
export var expanded := true setget set_expanded
export (Anima.EASING) var expand_easing = Anima.EASING.LINEAR
export var speed := 0.15
export var title_background_color := Color("314569") setget set_title_background_color
export var title_hovered_background_color := Color("628ad1") setget set_title_hovered_background_color
export var title_pressed_background_color := Color("425d8d") setget set_title_pressed_background_color
export var title_font_color := Color("425d8d") setget set_title_font_color
export var title_hovered_font_color := Color("425d8d") setget set_title_hovered_font_color
export var title_pressed_font_color := Color("425d8d") setget set_title_pressed_font_color
export var content_background_color := Color("1b212e") setget set_content_background_color

onready var _label: Label = find_node("Label")
onready var _expand_collapse: Button = find_node("ExpandCollapse")

func _ready():
	set_expanded(expanded)
	set_label(label)
	set_content_background_color(content_background_color)

func set_expanded(is_expanded: bool, animate := true) -> void:
	expanded = is_expanded

	if get_child_count() == 0:
		return

	if _expand_collapse == null:
		_expand_collapse = find_node("ExpandCollapse")

	if animate:
		_animate_height_change()

		return

	var value: String = EXPANDED_VALUE if is_expanded else COLLAPSED_VALUE
	var y: float = AnimaTweenUtils.maybe_calculate_value(value, { node = self, property = "min_size:y" })

	rect_size.y = y

func set_content_background_color(color: Color) -> void:
	content_background_color = color

	var stylebox: StyleBoxFlat = $ContentWrapper.get_stylebox("panel")

	stylebox.bg_color = content_background_color
	$ContentWrapper.add_stylebox_override("panel", stylebox)

func set_title_background_color(color: Color) -> void:
	title_background_color = color

func set_title_hovered_background_color(color: Color) -> void:
	title_hovered_background_color = color

func set_title_pressed_background_color(color: Color) -> void:
	title_pressed_background_color = color

func set_title_font_color(color: Color) -> void:
	title_font_color = color

func set_title_hovered_font_color(color: Color) -> void:
	title_hovered_font_color = color

func set_title_pressed_font_color(color: Color) -> void:
	title_pressed_font_color = color

func _animate_height_change() -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(speed)

	anima.then(
		Anima.Node() \
			.anima_property("min_size:y") \
			.anima_from(COLLAPSED_VALUE) \
			.anima_to(EXPANDED_VALUE + "")
	)
	anima.with(
		Anima.Node() \
			.anima_property("size:y") \
			.anima_from(COLLAPSED_VALUE) \
			.anima_to(EXPANDED_VALUE)
	)
	
	var initial_values := {}
	
	if expanded:
		initial_values = { opacity = 0 }

	anima.with(
		Anima.Node($ContentWrapper/MarginContainer/Content) \
			.anima_animation({
				0: {
					scale = Vector2(0.8, 0.8),
					opacity = 0,
				},
				100: {
					scale = Vector2.ONE,
					opacity = 1,
					easing = Anima.EASING.EASE_IN_OUT_BACK
				},
				initial_values = initial_values
			}) \
			.anima_pivot(Anima.PIVOT.CENTER)
	)
	anima.also(
		Anima.Node($Title/Icon) \
			.anima_property("rotate") \
			.anima_from(-90) \
			.anima_to(0) \
			.anima_pivot(Anima.PIVOT.CENTER)
	)

	if expanded:
		anima.play()
	else:
		anima.play_backwards_with_speed(1.5)

func set_label(new_label: String) -> void:
	label = new_label

	if get_child_count() == 0:
		return

	if _label == null:
		_label = $Title.find_node("Label")

	_label.text = new_label

func _on_AnimaAccordion_tree_entered():
	set_expanded(expanded, false)

func _on_AnimaRectangle_pressed():
	set_expanded(!expanded)

func _on_Content_item_rect_changed():
	$ContentWrapper.rect_size = $ContentWrapper/MarginContainer/Content.rect_size
