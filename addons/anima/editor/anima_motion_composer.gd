## Shows one authored motion graph in the Motion Composer bottom panel.
##
## The panel lets an author move between motions and see whether a selected
## scene node can provide group targets. It is an editor view of the original
## Resource, not a separate motion format.
@tool
class_name AnimaMotionComposer
extends VBoxContainer

const _COMPOSER_SESSION = preload("res://addons/anima/editor/anima_composer_session.gd")
const _GROUP_COMPOSER = preload("res://addons/anima/editor/anima_group_composer.gd")
const _GROUP_INSPECTOR = preload("res://addons/anima/editor/anima_group_inspector.gd")
const _PROPERTY_MOTION_COMPOSER = preload("res://addons/anima/editor/anima_property_motion_composer.gd")

## The transient selection and scene-node context for this open workspace.
var session = _COMPOSER_SESSION.new()
var _title: Label
var _motion_picker: OptionButton
var _context_message: Label
var _group_composer
var _group_inspector
var _property_motion_composer
var _inspect_button: Button
var _undo_redo: EditorUndoRedoManager

## Connects child editor surfaces to Godot's undo and redo history.
func set_undo_redo(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo
	if _group_composer != null:
		_group_composer.set_undo_redo(_undo_redo)
	if _property_motion_composer != null:
		_property_motion_composer.set_undo_redo(_undo_redo)

## Creates the lightweight workspace controls when the panel enters the editor.
func _ready() -> void:
	if _title != null:
		return
	_title = Label.new()
	_title.text = "Select a node with an Anima motion, or open one from the Inspector."
	add_child(_title)

	_motion_picker = OptionButton.new()
	_motion_picker.disabled = true
	_motion_picker.item_selected.connect(_on_motion_selected)
	add_child(_motion_picker)

	_context_message = Label.new()
	_context_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_context_message.text = session.scene_node_context_message()
	add_child(_context_message)

	_group_composer = _GROUP_COMPOSER.new()
	_group_composer.set_undo_redo(_undo_redo)
	add_child(_group_composer)
	_inspect_button = Button.new()
	_inspect_button.text = "Inspect Group"
	_inspect_button.pressed.connect(_open_group_inspection)
	add_child(_inspect_button)
	_group_inspector = _GROUP_INSPECTOR.new()
	_group_inspector.setup_requested.connect(_return_to_setup)
	add_child(_group_inspector)

	_property_motion_composer = _PROPERTY_MOTION_COMPOSER.new()
	_property_motion_composer.set_undo_redo(_undo_redo)
	add_child(_property_motion_composer)

## Opens [param motion] and shows it as the root of this workspace.
func open_motion(motion: AnimaMotion) -> void:
	session.open_motion(motion)
	_refresh_workspace()

## Selects [param motion] in the open graph and refreshes the visible context.
func select_motion(motion: AnimaMotion) -> bool:
	var changed: bool = session.select_motion(motion)
	if changed:
		_refresh_workspace()
	return changed

## Sets [param node] as the current scene-node context for group actions.
func select_scene_node(node: Node) -> void:
	session.select_scene_node(node)
	_refresh_context_message()

## Returns the authored motion currently selected in this workspace.
func selected_motion() -> AnimaMotion:
	return session.selected_motion

## Returns whether a selected scene node can supply group target context.
func has_scene_node_context() -> bool:
	return session.has_scene_node_context()

## Returns the author-facing explanation of the current scene-node context.
func scene_node_context_message() -> String:
	return session.scene_node_context_message()

## Returns the workspace's own top status line — the next-step message shown
## when nothing has been opened yet (`project-rules.md` §Editor Boundaries).
func workspace_status_message() -> String:
	return _title.text if _title != null else ""

func _refresh_workspace() -> void:
	if not is_node_ready():
		return
	_motion_picker.clear()
	var motions: Array = session.graph_motions()
	for motion in motions:
		var label: String = motion.display_name if not motion.display_name.is_empty() else motion.get_class()
		_motion_picker.add_item(label)
		if motion == session.selected_motion:
			_motion_picker.select(_motion_picker.item_count - 1)
	_motion_picker.disabled = motions.is_empty()
	_title.text = "Motion Composer: %s" % (session.selected_motion.get_class() if session.selected_motion != null else "No motion selected")
	_refresh_context_message()

	var showing_property_motion: bool = session.selected_motion is AnimaPropertyMotion and session.active_view == AnimaComposerSession.View.SETUP
	if showing_property_motion:
		_property_motion_composer.show_motion(session.selected_motion as AnimaPropertyMotion, session.selected_scene_node)
	else:
		_group_composer.show_motion(session.selected_motion, session.selected_scene_node)

	_property_motion_composer.visible = showing_property_motion
	_group_composer.visible = session.active_view == AnimaComposerSession.View.SETUP and not showing_property_motion
	_inspect_button.visible = session.selected_motion is AnimaGroupMotion and session.active_view == AnimaComposerSession.View.SETUP
	_group_inspector.visible = session.active_view == AnimaComposerSession.View.INSPECTION
	if session.active_view == AnimaComposerSession.View.INSPECTION:
		_group_inspector.inspect(session.selected_motion as AnimaGroupMotion, session.selected_scene_node)

func _refresh_context_message() -> void:
	if _context_message != null:
		_context_message.text = session.scene_node_context_message()

func _on_motion_selected(index: int) -> void:
	var motions: Array = session.graph_motions()
	if index >= 0 and index < motions.size():
		select_motion(motions[index])

func _open_group_inspection() -> void:
	if session.selected_motion is AnimaGroupMotion:
		session.active_view = AnimaComposerSession.View.INSPECTION
		_refresh_workspace()

func _return_to_setup() -> void:
	session.active_view = AnimaComposerSession.View.SETUP
	_refresh_workspace()
