## Edits one [AnimaPropertyMotion] inside the Motion Composer workspace.
##
## Shows its semantic convenience name (when it was created through [method
## Anima.on] or [method Anima.item] — see [member AnimaMotion.metadata]'s
## `convenience_method`/`convenience_factory` keys) alongside the canonical
## property path, target, values, timing, and easing it actually holds.
## Editing here changes the same authored Resource code and playback read;
## the panel is another view of that one Resource, never a second format
## (`tech-spec.md` §Target-bound authoring contract).
@tool
class_name AnimaPropertyMotionComposer
extends VBoxContainer

var _undo_redo: EditorUndoRedoManager
var _motion: AnimaPropertyMotion = null
var _scene_node: Node = null

var _semantic_label: Label
var _property_label: Label
var _target_label: Label
var _from_field: LineEdit
var _to_field: LineEdit
var _duration_field: SpinBox
var _ease_picker: OptionButton
var _property_search: LineEdit
var _property_results: ItemList
var _validation_label: Label

## Connects this panel to Godot's editor undo and redo history.
func set_undo_redo(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo

func _ready() -> void:
	if _semantic_label != null:
		return

	_semantic_label = Label.new()
	add_child(_semantic_label)
	_property_label = Label.new()
	add_child(_property_label)
	_target_label = Label.new()
	add_child(_target_label)

	_from_field = LineEdit.new()
	_from_field.text_submitted.connect(func(_text: String) -> void: _commit_from())
	_from_field.focus_exited.connect(_commit_from)
	add_child(_from_field)

	_to_field = LineEdit.new()
	_to_field.text_submitted.connect(func(_text: String) -> void: _commit_to())
	_to_field.focus_exited.connect(_commit_to)
	add_child(_to_field)

	_duration_field = SpinBox.new()
	_duration_field.min_value = 0.0
	_duration_field.max_value = 3600.0
	_duration_field.step = 0.01
	_duration_field.value_changed.connect(_on_duration_changed)
	add_child(_duration_field)

	_ease_picker = OptionButton.new()
	for kind_name in AnimaEase.Kind.keys():
		_ease_picker.add_item(kind_name)
	_ease_picker.item_selected.connect(_on_ease_selected)
	add_child(_ease_picker)

	_property_search = LineEdit.new()
	_property_search.placeholder_text = "Search target properties…"
	_property_search.text_changed.connect(_on_property_search_changed)
	add_child(_property_search)

	_property_results = ItemList.new()
	_property_results.item_selected.connect(_on_property_result_selected)
	add_child(_property_results)

	_validation_label = Label.new()
	add_child(_validation_label)

## Shows [param motion] and uses [param scene_node] (when present) as the
## live target read for current values, the generic property search, and
## validation feedback.
func show_motion(motion: AnimaPropertyMotion, scene_node: Node) -> void:
	_motion = motion
	_scene_node = scene_node
	_refresh()

func _refresh() -> void:
	if not is_node_ready() or _motion == null:
		return

	var method: String = _motion.metadata.get("convenience_method", "")
	var semantic := _semantic_label_for(method)
	_semantic_label.text = semantic if not semantic.is_empty() else "Property Motion"

	_property_label.text = "Underlying property: %s" % _motion.target_property

	if _scene_node != null and is_instance_valid(_scene_node):
		_target_label.text = "Target: %s" % _scene_node.name
	else:
		_target_label.text = "Target: select a scene node to preview and validate against."

	_from_field.text = "" if _motion.from_value == null else var_to_str(_motion.from_value)
	_from_field.placeholder_text = "(reads the target's current value when playback starts)"
	_to_field.text = var_to_str(_motion.to_value)

	_duration_field.set_value_no_signal(_motion.duration)
	_ease_picker.select(_motion.ease.kind)

	_property_results.clear()
	_validation_label.text = _validation_message()

## Human-readable label for the convenience method that created [member
## AnimaMotion.metadata]'s `convenience_method`, matching the semantic names
## `tech-spec.md` §Convenience method interface uses. Empty for a motion with
## no recorded convenience origin (e.g. authored directly through [method
## Motion.to]).
static func _semantic_label_for(method: String) -> String:
	match method:
		"position": return "Position"
		"position_x": return "Position X"
		"position_y": return "Position Y"
		"position_z": return "Position Z"
		"move_by": return "Move By"
		"scale": return "Scale"
		"scale_by": return "Scale By"
		"rotation": return "Rotation"
		"rotate_by": return "Rotate By"
		"opacity": return "Opacity"
		"color": return "Colour"
		"size": return "Size"
		"property": return "Property"
		_: return ""

func _validation_message() -> String:
	if _motion.target_property.is_empty():
		return "No property is set yet."
	if _scene_node == null or not is_instance_valid(_scene_node):
		return ""

	var base_property := String(_motion.target_property).split(":")[0]
	var has_property := false
	for property in _scene_node.get_property_list():
		if String(property.name) == base_property:
			has_property = true
			break
	if not has_property:
		return "'%s' was not found on %s." % [_motion.target_property, _scene_node.name]
	return "Current value: %s" % var_to_str(_scene_node.get_indexed(_motion.target_property))

func _commit_from() -> void:
	if _motion == null:
		return
	if _from_field.text.strip_edges().is_empty():
		_change_property(_motion, "from_value", null, "Clear Property Motion from value")
		return
	var parsed: Variant = str_to_var(_from_field.text)
	if parsed == null:
		_refresh()
		return
	_change_property(_motion, "from_value", parsed, "Set Property Motion from value")

func _commit_to() -> void:
	if _motion == null:
		return
	var parsed: Variant = str_to_var(_to_field.text)
	if parsed == null:
		_refresh()
		return
	_change_property(_motion, "to_value", parsed, "Set Property Motion to value")

func _on_duration_changed(value: float) -> void:
	if _motion == null:
		return
	_change_property(_motion, "duration", value, "Set Property Motion duration")

func _on_ease_selected(index: int) -> void:
	if _motion == null:
		return
	_change_property(_motion.ease, "kind", index, "Set Property Motion ease")

func _on_property_search_changed(query: String) -> void:
	_property_results.clear()
	if _scene_node == null or not is_instance_valid(_scene_node) or query.is_empty():
		return
	for property in _scene_node.get_property_list():
		if not (property.usage & PROPERTY_USAGE_EDITOR):
			continue
		var name := String(property.name)
		if query.to_lower() in name.to_lower():
			_property_results.add_item("%s — %s" % [name, _scene_node.get(name)])
			_property_results.set_item_metadata(_property_results.item_count - 1, name)

func _on_property_result_selected(index: int) -> void:
	if _motion == null:
		return
	var property_name: String = _property_results.get_item_metadata(index)
	_change_property(_motion, "target_property", NodePath(property_name), "Set Property Motion property")

func _change_property(object: Object, property: StringName, value: Variant, action_name: String) -> void:
	var previous := object.get(property)
	if previous == value:
		return
	if _undo_redo == null:
		object.set(property, value)
		_refresh()
		return
	_undo_redo.create_action(action_name)
	_undo_redo.add_do_property(object, property, value)
	_undo_redo.add_undo_property(object, property, previous)
	_undo_redo.commit_action()
	_refresh()
