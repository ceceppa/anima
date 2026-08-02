@tool
extends EditorPlugin

const MotionComposer = preload("res://addons/anima/editor/anima_motion_composer.gd")

var _composer: AnimaMotionComposer
var _inspector_plugin: AnimaMotionInspectorPlugin

class AnimaMotionInspectorPlugin extends EditorInspectorPlugin:
	var composer: AnimaMotionComposer

	func _init(p_composer: AnimaMotionComposer) -> void:
		composer = p_composer

	func _can_handle(object: Object) -> bool:
		return object is AnimaMotion

	func _parse_begin(object: Object) -> void:
		var button := Button.new()
		button.text = "Open in Motion Composer"
		button.pressed.connect(_open_motion.bind(object as AnimaMotion))
		add_custom_control(button)

	func _open_motion(motion: AnimaMotion) -> void:
		composer.open_motion(motion)

## Adds the Motion Composer panel and Inspector action when the Anima plugin starts.
func _enter_tree() -> void:
	_composer = MotionComposer.new()
	_composer.set_undo_redo(get_undo_redo())
	add_control_to_bottom_panel(_composer, "Anima")
	_inspector_plugin = AnimaMotionInspectorPlugin.new(_composer)
	add_inspector_plugin(_inspector_plugin)

## Removes editor-only Composer controls when the Anima plugin stops.
func _exit_tree() -> void:
	if _inspector_plugin != null:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	if _composer != null:
		remove_control_from_bottom_panel(_composer)
		_composer.queue_free()
		_composer = null

## Keeps the Composer's scene-node context aligned with Godot's current selection.
func _process(_delta: float) -> void:
	if _composer == null:
		return
	var selected_nodes := get_editor_interface().get_selection().get_selected_nodes()
	_composer.select_scene_node(selected_nodes[0] if not selected_nodes.is_empty() else null)

## Returns the name shown for this editor plugin in Godot.
func get_name():
	return 'Anima'
