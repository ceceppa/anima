## Keeps one Motion Composer workspace focused on an authored motion graph.
##
## A motion graph is one motion Resource and the child motions it contains.
## The session remembers what an author is editing and which scene node gives
## group previews their context; it never stores a second copy of that motion.
@tool
class_name AnimaComposerSession
extends RefCounted

## Chooses whether the workspace is editing settings or showing inspection.
enum View {
	## Shows the selected motion's editable settings.
	SETUP,
	## Shows read-only information about the selected motion.
	INSPECTION,
}

## The motion Resource that was opened in this workspace.
var root_motion: AnimaMotion = null
## The motion currently shown in the workspace.
var selected_motion: AnimaMotion = null
## The scene node used to resolve group targets and run previews.
var selected_scene_node: Node = null
## The workspace view currently shown to the author.
var active_view: View = View.SETUP

## Opens [param motion] as this workspace's resource graph.
##
## The root and selected motion initially refer to the same authored Resource.
## Any prior selection and preview context belongs to the previous workspace and
## is cleared.
func open_motion(motion: AnimaMotion) -> void:
	root_motion = motion
	selected_motion = motion
	selected_scene_node = null
	active_view = View.SETUP

## Selects [param motion] when it belongs to the open motion graph.
##
## Returns `true` after changing the editing context. A motion outside the
## graph is ignored so the workspace never starts editing a different asset.
func select_motion(motion: AnimaMotion) -> bool:
	if motion == null or not graph_motions().has(motion):
		return false
	selected_motion = motion
	active_view = View.SETUP
	return true

## Sets [param node] as the scene context for resolving and previewing groups.
##
## Passing `null` keeps the resource editable but clears the context that a
## group needs to find its target nodes.
func select_scene_node(node: Node) -> void:
	selected_scene_node = node

## Returns whether this workspace has a usable scene node for group actions.
func has_scene_node_context() -> bool:
	return selected_scene_node != null and is_instance_valid(selected_scene_node)

## Explains why resolution and preview are unavailable when no node is selected.
func scene_node_context_message() -> String:
	if has_scene_node_context():
		return "The selected scene node provides group target and preview context."
	return "Select a scene node before resolving targets or previewing this group."

## Returns every motion in the opened graph, with the root first.
##
## The order follows the Resource properties that hold child motions. Each
## Resource appears once even when more than one parent property references it.
func graph_motions() -> Array[AnimaMotion]:
	var motions: Array[AnimaMotion] = []
	if root_motion == null:
		return motions
	_append_motion(root_motion, motions, {})
	return motions

func _append_motion(motion: AnimaMotion, motions: Array[AnimaMotion], seen: Dictionary) -> void:
	if motion == null or seen.has(motion.get_instance_id()):
		return
	seen[motion.get_instance_id()] = true
	motions.append(motion)
	for property in motion.get_property_list():
		if not (property.usage & PROPERTY_USAGE_STORAGE):
			continue
		_append_motion_value(motion.get(property.name), motions, seen)

func _append_motion_value(value: Variant, motions: Array[AnimaMotion], seen: Dictionary) -> void:
	if value is AnimaMotion:
		_append_motion(value, motions, seen)
	elif value is Array:
		for entry in value:
			_append_motion_value(entry, motions, seen)
