## Edits one [AnimaGroupMotion] inside the Motion Composer workspace.
##
## It changes the authored Resource directly, so a group configured here is the
## same group played by code. Preview controls use the workspace's selected
## scene node and never create a second schedule or motion format.
@tool
class_name AnimaGroupComposer
extends VBoxContainer

var _undo_redo: EditorUndoRedoManager
var _group: AnimaGroupMotion = null
var _scene_node: Node = null
var _preview: AnimaPlayback = null
var _status: Label
var _add_group_button: Button
var _setup: VBoxContainer

## Connects this setup surface to Godot's editor undo and redo history.
func set_undo_redo(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo

## Shows [param motion] when it is a group, or offers group creation for a compatible parent.
func show_motion(motion: AnimaMotion, scene_node: Node) -> void:
	set_meta("selected_motion", motion)
	_group = motion as AnimaGroupMotion
	_scene_node = scene_node
	_refresh()

## Returns this view's own status line — including the next-step message
## shown when the selected motion isn't a group (`project-rules.md` §Editor Boundaries).
func status_message() -> String:
	return _status.text if _status != null else ""

## Adds a new group to [param parent] and returns it, or returns `null` when the parent cannot contain children.
func add_group(parent: AnimaMotion) -> AnimaGroupMotion:
	if not can_add_group(parent):
		return null
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	var children := _children_for_parent(parent)
	children.append(group)
	_change_property(parent, "children", children, "Add Group Motion")
	_group = group
	_refresh()
	return group

## Returns whether [param motion] is a composite parent that can contain a group.
func can_add_group(motion: AnimaMotion) -> bool:
	return motion is AnimaSequence or motion is AnimaParallel or motion is AnimaRace

## Changes one authored group setting through the Composer's undo-aware edit path.
##
## Returns `false` when no group is selected. This is used by the setup controls
## so edits made in the panel change the same Resource code later plays.
func set_group_property(property: StringName, value: Variant) -> bool:
	if _group == null:
		return false
	_change_property(_group, property, value, "Set group %s" % property)
	return true

func _children_for_parent(parent: AnimaMotion) -> Array[AnimaMotion]:
	if parent is AnimaSequence:
		return (parent as AnimaSequence).children.duplicate()
	if parent is AnimaParallel:
		return (parent as AnimaParallel).children.duplicate()
	if parent is AnimaRace:
		return (parent as AnimaRace).children.duplicate()
	return []

## Starts a forward preview when the selected group has a usable scene-node context.
func preview_forward() -> void:
	if _group == null or _scene_node == null or not is_instance_valid(_scene_node):
		_set_status("Select a scene node before previewing this group.")
		return
	var errors := _group.validate()
	if not errors.is_empty():
		_set_status(errors[0])
		return
	_preview = Anima.play(_group, _scene_node)
	_set_status("Preview is playing.")

## Stops the current preview without changing the authored group.
func stop_preview() -> void:
	if _preview != null:
		_preview.cancel()
		_preview = null
	_set_status("Preview stopped.")

## Reverses the current group preview after it has started forward.
func preview_reverse() -> void:
	if _preview == null:
		_set_status("Start a forward preview before reversing this group.")
		return
	_preview.reverse()
	_set_status("Preview is playing in reverse.")

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if not is_node_ready():
		return
	for child in get_children():
		child.queue_free()
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)
	_add_group_button = Button.new()
	_add_group_button.text = "Add Group Motion"
	_add_group_button.visible = _group == null and can_add_group(_selected_parent())
	_add_group_button.pressed.connect(_on_add_group_pressed)
	add_child(_add_group_button)
	_setup = VBoxContainer.new()
	_setup.visible = _group != null
	add_child(_setup)
	if _group == null:
		if _add_group_button.visible:
			_set_status("This motion isn't a group — press Add Group Motion below, or pick a Group Motion or Property Motion from the dropdown above.")
		else:
			_set_status("This motion isn't a group and can't hold one — pick a Group Motion or Property Motion from the dropdown above.")
		return
	_build_setup()

func _selected_parent() -> AnimaMotion:
	if not has_meta("selected_motion"):
		return null
	return get_meta("selected_motion", null) as AnimaMotion

func _build_setup() -> void:
	var is_configured: bool = _group.item_motion != null and _group.target_collection != null
	if not is_configured:
		_set_status("This group has no target collection or item motion yet — assign both above before previewing or inspecting.")
	else:
		_set_status("Select a scene node before previewing this group." if _scene_node == null else "This group uses the selected scene node for preview.")
	_add_resource_picker("Target collection", "AnimaTargetCollection", _group.target_collection, func(value: Resource): _change_property(_group, "target_collection", value, "Set group target collection"))
	_add_resource_picker("Item motion", "AnimaMotion", _group.item_motion, func(value: Resource): _change_property(_group, "item_motion", value, "Set group item motion"))
	_add_option("Playback", ["Sequential", "Parallel", "Staggered"], _group.playback_mode, func(index: int): _change_property(_group, "playback_mode", index, "Set group playback"))
	if _group.playback_mode == AnimaGroupMotion.PlaybackMode.SEQUENTIAL:
		_add_number("Sequential gap", _group.sequential_gap, func(value: float): _change_property(_group, "sequential_gap", value, "Set sequential gap"))
	if _group.playback_mode == AnimaGroupMotion.PlaybackMode.STAGGERED:
		_add_option("Distribution", ["Fixed interval", "Total duration"], _group.distribution.mode, func(index: int): _change_property(_group.distribution, "mode", index, "Set group distribution"))
		if _group.distribution.mode == AnimaGroupDistribution.Mode.FIXED_INTERVAL:
			_add_number("Stagger interval", _group.distribution.stagger_interval, func(value: float): _change_property(_group.distribution, "stagger_interval", value, "Set stagger interval"))
		else:
			_add_number("Total stagger duration", _group.distribution.total_stagger_duration, func(value: float): _change_property(_group.distribution, "total_stagger_duration", value, "Set total stagger duration"))
	_add_option("Order", ["Forward", "Reverse", "Centered", "Edge", "Random", "Grid", "Distance"], mini(_group.order.kind, 6), func(index: int): _change_property(_group.order, "kind", index, "Set group order"))
	if _group.order.kind == AnimaGroupOrder.Kind.GRID or _group.order.kind == AnimaGroupOrder.Kind.DISTANCE:
		_add_option("Origin", ["First", "Last", "Center", "Index", "Point"], _group.order.origin, func(index: int): _change_property(_group.order, "origin", index, "Set group origin"))
	if _group.target_collection != null:
		_add_option("Target source", ["Children", "Explicit", "Scene group", "Descendants", "Runtime supplied"], _group.target_collection.kind, func(index: int): _change_property(_group.target_collection, "kind", index, "Set target source"))
		_add_option("Filter", ["All", "Odd positions", "Even positions"], _group.target_collection.filter, func(index: int): _change_property(_group.target_collection, "filter", index, "Set target filter"))
	_add_option("Completion", ["All items", "First item"], _group.completion_policy, func(index: int): _change_property(_group, "completion_policy", index, "Set completion policy"))
	_add_option("Reverse order", ["Reuse execution", "Reverse execution"], _group.reverse_order_policy, func(index: int): _change_property(_group, "reverse_order_policy", index, "Set reverse order"))
	_add_option("Invalid target", ["Skip", "Cancel group"], _group.invalid_target_policy, func(index: int): _change_property(_group, "invalid_target_policy", index, "Set invalid target policy"))
	_add_option("Empty group", ["Complete", "Report error"], _group.empty_group_policy, func(index: int): _change_property(_group, "empty_group_policy", index, "Set empty group policy"))
	if is_configured:
		var controls := HBoxContainer.new()
		for data in [["Preview", preview_forward], ["Stop", stop_preview], ["Reverse", preview_reverse]]:
			var button := Button.new()
			button.text = data[0]
			button.pressed.connect(data[1])
			controls.add_child(button)
		_setup.add_child(controls)

func _add_resource_picker(label_text: String, base_type: String, value: Resource, changed: Callable) -> void:
	if not Engine.is_editor_hint():
		# EditorResourcePicker can only be instantiated inside a real editor
		# session; outside it (headless test runs), this row is skipped.
		return
	var picker := EditorResourcePicker.new()
	picker.base_type = base_type
	picker.edited_resource = value
	picker.resource_changed.connect(changed)
	_add_labeled_control(label_text, picker)

func _add_option(label_text: String, choices: Array[String], selected: int, changed: Callable) -> void:
	var option := OptionButton.new()
	for choice in choices:
		option.add_item(choice)
	option.select(clampi(selected, 0, choices.size() - 1))
	option.item_selected.connect(changed)
	_add_labeled_control(label_text, option)

func _add_number(label_text: String, value: float, changed: Callable) -> void:
	var input := SpinBox.new()
	input.min_value = 0.0
	input.step = 0.01
	input.value = value
	input.value_changed.connect(changed)
	_add_labeled_control(label_text, input)

func _add_labeled_control(label_text: String, control: Control) -> void:
	var row := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 160.0
	row.add_child(label)
	row.add_child(control)
	_setup.add_child(row)

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

func _on_add_group_pressed() -> void:
	add_group(_selected_parent())

func _set_status(message: String) -> void:
	if _status != null:
		_status.text = message
