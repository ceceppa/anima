## Adds an "Anima" Inspector entry point for opening a motion in the Motion
## Composer — either from an inspected [AnimaMotion] resource directly, or
## from an ordinary node whose script exports an [AnimaMotion] (or subtype)
## field (`tech-spec.md` §Motion Composer entry point).
@tool
class_name AnimaMotionInspectorPlugin
extends EditorInspectorPlugin

## The workspace panel a chosen motion opens into.
var composer: AnimaMotionComposer

func _init(p_composer: AnimaMotionComposer) -> void:
	composer = p_composer

func _can_handle(object: Object) -> bool:
	if object is AnimaMotion:
		return true
	return object is Node and not AnimaMotionFieldScanner.motion_fields(object).is_empty()

func _parse_begin(object: Object) -> void:
	if object is AnimaMotion:
		var button := Button.new()
		button.text = "Open in Motion Composer"
		button.pressed.connect(_open_motion.bind(object as AnimaMotion))
		add_custom_control(button)
		return

	var fields := AnimaMotionFieldScanner.motion_fields(object)
	if fields.is_empty():
		return

	var section := VBoxContainer.new()
	var title := Label.new()
	title.text = "Anima"
	section.add_child(title)
	for field_name in fields:
		section.add_child(_build_field_row(object, field_name))
	add_custom_control(section)

func _build_field_row(object: Object, field_name: String) -> Control:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = field_name
	row.add_child(label)

	var motion: AnimaMotion = object.get(field_name)
	if motion == null:
		var message := Label.new()
		message.text = "Assign an Anima motion to open it here."
		row.add_child(message)
	else:
		var button := Button.new()
		button.text = "Open Motion Composer"
		button.pressed.connect(_open_motion.bind(motion))
		row.add_child(button)
	return row

func _open_motion(motion: AnimaMotion) -> void:
	composer.open_motion(motion)
