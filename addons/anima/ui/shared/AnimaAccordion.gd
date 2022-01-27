tool
extends VBoxContainer

const COLLAPSED_VALUE := "./TitleContainer:size:y" 
const EXPANDED_VALUE := "./TitleContainer:size:y + ./ContentWrapper/Content:size:y"

export var label := "Accordion" setget set_label
export var expanded := true setget set_expanded
export (Anima.EASING) var expand_easing = Anima.EASING.LINEAR

onready var _label: Label = find_node("Label")
onready var _expand_collapse: Button = find_node("ExpandCollapse")

func set_expanded(is_expanded: bool, animate := true) -> void:
	expanded = is_expanded

	if _expand_collapse == null:
		_expand_collapse = find_node("ExpandCollapse")

	if animate:
		_animate_height_change()

		return

	var value: String = EXPANDED_VALUE if is_expanded else COLLAPSED_VALUE
	var y: float = AnimaTweenUtils.maybe_calculate_value(value, { node = self, property = "min_size:y" })

	rect_size.y = y

func _animate_height_change() -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.then(
		Anima.Node(self) \
			.anima_property("min_size:y") \
			.anima_from(COLLAPSED_VALUE) \
			.anima_to(EXPANDED_VALUE)
	)
	anima.with(
		Anima.Node(self) \
			.anima_property("size:y") \
			.anima_from(COLLAPSED_VALUE) \
			.anima_to(EXPANDED_VALUE)
	)
	
	var initial_values := {}
	
	if expanded:
		initial_values = { opacity = 0 }

	anima.with(
		Anima.Node($ContentWrapper/Content) \
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
		Anima.Node(_expand_collapse) \
			.anima_property("rotate") \
			.anima_from(0) \
			.anima_to(180) \
			.anima_duration(0.3) \
			.anima_pivot(Anima.PIVOT.CENTER)
	)

	if expanded:
		anima.play()
	else:
		anima.play_backwards_with_speed(1.5)

func set_label(new_label: String) -> void:
	label = new_label

	if _label == null:
		_label = find_node("Label")

	_label.text = new_label

func _on_ExpandCollapse_pressed():
	set_expanded(!expanded)

func _on_AnimaAccordion_tree_entered():
	set_expanded(expanded, false)

