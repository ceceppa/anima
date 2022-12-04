@tool
extends VBoxContainer

signal select_animation
signal select_easing
signal select_relative_property(source)
signal updated
signal removed
signal highlight_node(node)
signal select_property_to_animate
signal preview_animation(data)

@onready var _property_data = find_child("PropertyData")
@onready var _select_animation = find_child("SelectAnimation")
@onready var _animate_property = find_child("AnimateProperty")
@onready var _title = find_child("Title")
@onready var _property_or_animation = find_child("PropertyOrAnimation")

var _property_name = ""
var _property_type = TYPE_NIL
var _animation_name: String
var _is_restoring := false

func _ready():
	_select_animation.hide()
	_on_PropertyOrAnimation_item_selected(0)

	find_child("PropertyOrAnimation").set_items([
		{ icon = "res://addons/anima/visual-editor/icons/Property.svg", label = "Animate proeprty" },
		{ icon = "res://addons/anima/visual-editor/icons/Animation.svg", label = "Use existing animation" },
	])

	_update_title()

	if _animation_name == "" and _property_name == "":
		_title.button_pressed = true

func get_data() -> Dictionary:
	if _property_data == null:
		_property_data = find_child("PropertyData")

	var easing_value = ANIMA.EASING.LINEAR
	var easing_button: Button = _property_data.find_child("EasingButton")

	if easing_button.has_meta("easing_value"):
		easing_value = int(easing_button.get_meta("easing_value"))

	var data =  {
		animation_name = _animation_name,
		property_type = _property_type,
		property_name = _property_name,
		animate_with = _property_or_animation.get_selected_id(),
		property = {
			from = _property_data.find_child("FromValue").get_value(),
			to = _property_data.find_child("ToValue").get_value(),
			initialValue = _property_data.find_child("InitialValue").get_value(),
			relative = _property_data.find_child("RelativeCheck").pressed,
			pivot = _property_data.find_child("PivotButton").get_value(),
			easing = [easing_button.text, easing_value]
		}
	}

	return data

func restore_data(data: Dictionary) -> void:
	_is_restoring = true

	if data.has("animation_name"):
		selected_animation(data.animation_name)

	if _property_data == null:
		_property_data = find_child("PropertyData")

	set_property_to_animate(data.property_name, data.property_type)

	_property_data.find_child("FromValue").set_value(data.property.from)
	_property_data.find_child("ToValue").set_value(data.property.to)
	_property_data.find_child("InitialValue").set_value(data.property.initialValue)
	_property_data.find_child("RelativeCheck").button_pressed = data.property.relative
	_property_data.find_child("PivotButton").set_value(data.property.pivot)

	if data.has("animate_with"):
		_property_or_animation.set_selected_id(data.animate_with)
	else:
		_property_or_animation.set_selected_id(0)

	set_easing(data.property.easing[0], data.property.easing[1])

	if _animation_name == "" and _property_name == "":
		_title.button_pressed = true

	_on_PropertyOrAnimation_item_selected(_property_or_animation.get_selected_id())

	_is_restoring= false

func selected_animation(name) -> void:
	if name:
		_animation_name = name
		find_child("SelectAnimation").set_text(name)

	_update_title()

	_emit_node_update()

func set_easing(name: String, value: int) -> void:
	var button: Button = find_child("EasingButton")

	button.text = name
	button.set_meta("easing_value", value)

	_emit_node_update()

func set_property_to_animate(name: String, type) -> void:
	_property_name = name
	_property_type = type

	_property_data.show()

	_set_property_type(type)

	_update_title()

	_emit_node_update()

func _update_title() -> void:
	var title = "(no animation)"
	var id = find_child("PropertyOrAnimation").get_selected_id()
	var show_preview := false

	if id == 0 and _property_name:
		title = "Property: " + _property_name
		show_preview = true
	elif id == 1 and _animation_name:
		title = "Animation: " + _animation_name
		show_preview = true

	find_child("Preview").visible = show_preview
	_title.set_text(title)

func _set_property_type(property_type) -> void:
	for child in _property_data.get_children():
		if child.has_method('set_type') and property_type != TYPE_NIL:
			child.set_type(property_type)

func _on_SelectProperty_pressed():
	emit_signal("select_property_to_animate")

func _on_PropertyOrAnimation_item_selected(id):
	_property_data.visible = id == 0 and _property_name != ""
	find_child("SelectProperty").visible = id == 0
	_select_animation.visible = id == 1

	_update_title()

	_emit_node_update()

func _emit_node_update() -> void:
	if not _is_restoring:
		emit_signal("updated")

func _on_EasingButton_pressed():
	emit_signal("select_easing")

func _on_ConfirmationDialog_confirmed():
	queue_free()
	_emit_node_update()

func _on_Remove_pressed():
	$ConfirmationDialog.popup_centered()

#
# Force the "MarginContainer" to recalculate the correct height when 
# a button is hidden
#
func _adjust_property_data_height():
	if _property_data:
		_property_data.get_parent().get_parent().size.y = 0

func _on_FromValue_select_relative_property():
	emit_signal("select_relative_property", find_child("FromValue"))

func _on_ToValue_select_relative_property():
	emit_signal("select_relative_property", find_child("ToValue"))

func _on_InitialValue_select_relative_property():
	emit_signal("select_relative_property", find_child("InitialValue"))

func _on_SelectAnimation_pressed():
	emit_signal("select_animation")

func _on_MarginContainer_item_rect_changed():
	var bg_color: ColorRect = find_child("BGColor")

	bg_color.offset_right = $MarginContainer.size.x
	bg_color.offset_bottom = $MarginContainer.size.y

func _on_MarginContainer_visibility_changed():
	find_child("BGColor").visible = $MarginContainer.visible

func _on_Preview_pressed():
	print(get_meta("_data_index"))
	emit_signal("preview_animation", { preview_button = find_child("Preview"), single_animation_id = get_meta("_data_index") })
