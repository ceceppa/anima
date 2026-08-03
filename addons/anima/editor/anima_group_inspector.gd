## Shows resolved targets, generated timing, validation, and compilation status for one group.
##
## Inspection reads the same resolver and scheduler used by playback. It does
## not create a timeline or a second schedule, so the details shown here match
## what the group will use when it plays.
@tool
class_name AnimaGroupInspector
extends VBoxContainer

## Requests a return to the Group Setup view for the same authored resource.
signal setup_requested

## The latest resolved targets in collection order.
var targets: Array[Node] = []
## The latest generated per-target start offsets.
var start_offsets: Array[float] = []
## Plain-language validation and compilation messages for this inspection.
var messages: Array[String] = []
## Whether the current group can compile into a native Animation.
var compile_eligible: bool = false
var _group: AnimaGroupMotion = null
var _root: Node = null
var _details: RichTextLabel
var _status: Label

## Inspects [param group] against [param root] and refreshes its derived details.
func inspect(group: AnimaGroupMotion, root: Node) -> void:
	_group = group
	_root = root
	_refresh_inspection()

## Recalculates target resolution, generated timing, validation, and compile eligibility.
func validate() -> void:
	_refresh_inspection()

## Compiles the inspected group when it is eligible, otherwise keeps its blocker visible.
func compile() -> Animation:
	if _group == null or _root == null or not compile_eligible:
		return null
	var animation := AnimaGroupCompiler.compile(_group, _root)
	messages.append("Compiled native Animation with %d tracks." % animation.get_track_count())
	_refresh_visible_details()
	return animation

func _ready() -> void:
	var actions := HBoxContainer.new()
	var validate_button := Button.new()
	validate_button.text = "Validate"
	validate_button.pressed.connect(validate)
	actions.add_child(validate_button)
	var compile_button := Button.new()
	compile_button.text = "Compile"
	compile_button.pressed.connect(compile)
	actions.add_child(compile_button)
	var back_button := Button.new()
	back_button.text = "Back to Setup"
	back_button.pressed.connect(func(): setup_requested.emit())
	actions.add_child(back_button)
	add_child(actions)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)
	_details = RichTextLabel.new()
	_details.fit_content = true
	_details.bbcode_enabled = true
	add_child(_details)
	_refresh_visible_details()

func _refresh_inspection() -> void:
	targets.clear()
	start_offsets.clear()
	messages.clear()
	compile_eligible = false
	if _group == null:
		messages.append("Select a Group Motion before opening inspection.")
		_refresh_visible_details()
		return
	if _root == null or not is_instance_valid(_root):
		messages.append("Select a scene node before inspecting this group.")
		_refresh_visible_details()
		return
	messages.append_array(_group.validate())
	var resolution := AnimaTargetResolver.resolve(_group.target_collection, _root, [], _group.invalid_target_policy, _group.empty_group_policy)
	targets = resolution.targets
	messages.append_array(resolution.messages)
	var schedule := AnimaGroupScheduler.derive(_group, targets)
	for entry in schedule.entries:
		start_offsets.append(entry.start_offset)
	var eligibility := AnimaGroupCompiler.check_eligibility(_group, _root)
	compile_eligible = eligibility.is_eligible()
	if not compile_eligible:
		messages.append(eligibility.message)
	_refresh_visible_details()

## Returns this view's own resolved-target detail text — including the
## next-step message shown when the resolved target list is empty
## (`project-rules.md` §Editor Boundaries).
func resolved_targets_message() -> String:
	return _details.text if _details != null else ""

func _refresh_visible_details() -> void:
	if _status == null or _details == null:
		return
	_status.text = "Eligible for compilation." if compile_eligible else (messages[0] if not messages.is_empty() else "Validation is required.")
	var lines: Array[String] = []
	for index in targets.size():
		lines.append("%d. %s — starts at %.2fs" % [index + 1, targets[index].name, start_offsets[index]])
	_details.text = "\n".join(lines) if not lines.is_empty() else "No resolved targets yet — return to Group Setup and assign a target collection."
