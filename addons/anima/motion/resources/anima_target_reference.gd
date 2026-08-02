## Stores a target in a way an authored motion can safely find again.
##
## A target is the Godot node that visibly changes during a motion. Use a
## scene-relative path before saving an authored motion. A direct node is only
## for immediate playback because it cannot be stored in a reusable resource.
class_name AnimaTargetReference
extends Resource

## How this reference finds its target when a motion begins.
enum ResolutionMode {
	## Finds a node by its path relative to the supplied scene root.
	SCENE_RELATIVE,
	## Uses the node supplied by the playback caller.
	PLAYBACK_CONTEXT,
	## Keeps one live node for immediate playback only. This cannot be saved.
	TRANSIENT_LIVE,
}

## The way this target is resolved. New references use the portable
## [constant ResolutionMode.PLAYBACK_CONTEXT] mode by default.
@export var resolution_mode: ResolutionMode = ResolutionMode.PLAYBACK_CONTEXT
## The path from a supplied scene root to the target for
## [constant ResolutionMode.SCENE_RELATIVE].
@export var scene_relative_path: NodePath = NodePath()

var _live_target: Node = null

## Creates a portable reference to [param target] below [param scene_root].
## Returns an error when the target is not part of that scene tree.
func set_scene_relative(scene_root: Node, target: Node) -> String:
	if scene_root == null or target == null or not scene_root.is_ancestor_of(target):
		return "Choose a target that belongs to the scene root before saving this motion."
	scene_relative_path = scene_root.get_path_to(target)
	resolution_mode = ResolutionMode.SCENE_RELATIVE
	_live_target = null
	return ""

## Uses [param target] for immediate playback. Call [method set_scene_relative]
## before saving the resource so a reopened motion can find its target again.
func set_live_target(target: Node) -> void:
	_live_target = target
	resolution_mode = ResolutionMode.TRANSIENT_LIVE
	scene_relative_path = NodePath()

## Resolves this reference using [param scene_root] or [param playback_target].
## Returns `null` when the required node is unavailable.
func resolve(scene_root: Node = null, playback_target: Node = null) -> Node:
	match resolution_mode:
		ResolutionMode.SCENE_RELATIVE:
			if scene_root != null and not scene_relative_path.is_empty():
				return scene_root.get_node_or_null(scene_relative_path)
		ResolutionMode.PLAYBACK_CONTEXT:
			return playback_target
		ResolutionMode.TRANSIENT_LIVE:
			if is_instance_valid(_live_target):
				return _live_target
	return null

## Returns a clear message when this reference cannot safely be serialized,
## or an empty string when it is portable.
func serialization_error() -> String:
	if resolution_mode == ResolutionMode.TRANSIENT_LIVE:
		return "This motion uses a live target. Set a scene-relative target before saving it."
	if resolution_mode == ResolutionMode.SCENE_RELATIVE and scene_relative_path.is_empty():
		return "Set a scene-relative target path before saving this motion."
	return ""
