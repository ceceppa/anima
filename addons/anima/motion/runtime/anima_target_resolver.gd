## Resolves an [AnimaTargetCollection] into the nodes a group can animate.
##
## This helper keeps collection choices predictable: it preserves each source's
## visible order, removes duplicates, then applies an optional odd or even
## filter. Ordering and animation timing are deliberately separate work.
class_name AnimaTargetResolver
extends RefCounted

## Reports the usable targets and any messages found while resolving them.
##
## A cancelled result must not start playback. An empty result can still be a
## successful no-op when the chosen empty-group policy is `COMPLETE`.
class Resolution:
	## The unique target nodes, in their collection order after filtering.
	var targets: Array[Node] = []
	## Plain-language messages for missing, duplicate, or otherwise unusable targets.
	var messages: Array[String] = []
	## Whether the invalid-target policy stopped the whole group.
	var cancelled: bool = false
	## Whether the empty-group policy treats an empty result as an error.
	var empty_is_error: bool = false

	## Returns true when playback may continue with this resolved collection.
	func can_play() -> bool:
		return not cancelled and not empty_is_error

## Resolves [param collection] from [param root] and optional runtime targets.
##
## [param root] is the node whose children, descendants, and relative paths are
## inspected. [param runtime_targets] is used only for `RUNTIME_CALLABLE`.
## Invalid and empty policies come from the owning [AnimaGroupMotion].
static func resolve(
	collection: AnimaTargetCollection,
	root: Node,
	runtime_targets: Array = [],
	invalid_target_policy: AnimaGroupMotion.InvalidTargetPolicy = AnimaGroupMotion.InvalidTargetPolicy.SKIP,
	empty_group_policy: AnimaGroupMotion.EmptyGroupPolicy = AnimaGroupMotion.EmptyGroupPolicy.COMPLETE,
) -> Resolution:
	var result := Resolution.new()
	if collection == null:
		result.cancelled = true
		result.messages.append("A target collection is required before a group can play.")
		return result

	var candidates := _source_candidates(collection, root, runtime_targets, result)
	var seen := {}
	for candidate in candidates:
		if not (candidate is Node) or not is_instance_valid(candidate):
			_add_invalid_target_message(result, "A target has left the scene or is no longer available.", invalid_target_policy)
			if result.cancelled:
				return result
			continue

		var target := candidate as Node
		var instance_id := target.get_instance_id()
		if seen.has(instance_id):
			_add_invalid_target_message(result, "The same target appears more than once in this collection.", invalid_target_policy)
			if result.cancelled:
				return result
			continue

		seen[instance_id] = true
		result.targets.append(target)

	_apply_filter(result.targets, collection.filter)
	if result.targets.is_empty() and empty_group_policy == AnimaGroupMotion.EmptyGroupPolicy.REPORT_ERROR:
		result.empty_is_error = true
		result.messages.append("This target collection has no usable targets, so the group cannot play.")
	return result

static func _source_candidates(
	collection: AnimaTargetCollection,
	root: Node,
	runtime_targets: Array,
	result: Resolution,
) -> Array:
	match collection.kind:
		AnimaTargetCollection.Kind.CHILDREN:
			if root == null:
				result.messages.append("Children need a root node to resolve targets.")
				return []
			return root.get_children()
		AnimaTargetCollection.Kind.EXPLICIT:
			return _explicit_candidates(collection.reference_data, root, result)
		AnimaTargetCollection.Kind.SCENE_GROUP:
			return _scene_group_candidates(collection.reference_data, root, result)
		AnimaTargetCollection.Kind.DESCENDANTS:
			if root == null:
				result.messages.append("Descendants need a root node to resolve targets.")
				return []
			var descendants: Array = []
			_append_descendants(root, descendants)
			return descendants
		AnimaTargetCollection.Kind.RUNTIME_CALLABLE:
			return runtime_targets.duplicate()
		_:
			result.messages.append("This target collection uses an unknown source.")
			return []

static func _explicit_candidates(reference_data: Array, root: Node, result: Resolution) -> Array:
	var candidates: Array = []
	for reference in reference_data:
		if reference is Node:
			candidates.append(reference)
		elif reference is NodePath:
			if root == null:
				result.messages.append("A node path needs a root node to resolve targets.")
				continue
			var target := root.get_node_or_null(reference)
			if target == null:
				candidates.append(null)
			else:
				candidates.append(target)
		else:
			candidates.append(null)
	return candidates

static func _scene_group_candidates(reference_data: Array, root: Node, result: Resolution) -> Array:
	if root == null or root.get_tree() == null:
		result.messages.append("Scene-group targets need a root node inside a scene tree.")
		return []

	var candidates: Array = []
	for group_name in reference_data:
		if not (group_name is String or group_name is StringName) or String(group_name).is_empty():
			result.messages.append("A scene-group target needs a non-empty group name.")
			continue
		candidates.append_array(root.get_tree().get_nodes_in_group(StringName(group_name)))
	return candidates

static func _append_descendants(node: Node, descendants: Array) -> void:
	for child in node.get_children():
		descendants.append(child)
		_append_descendants(child, descendants)

static func _apply_filter(targets: Array[Node], filter: AnimaTargetCollection.Filter) -> void:
	if filter == AnimaTargetCollection.Filter.NONE:
		return

	var filtered: Array[Node] = []
	for index in targets.size():
		var keep := filter == AnimaTargetCollection.Filter.ODD_ONLY and index % 2 == 1
		keep = keep or (filter == AnimaTargetCollection.Filter.EVEN_ONLY and index % 2 == 0)
		if keep:
			filtered.append(targets[index])
	targets.assign(filtered)

static func _add_invalid_target_message(
	result: Resolution,
	message: String,
	invalid_target_policy: AnimaGroupMotion.InvalidTargetPolicy,
) -> void:
	result.messages.append(message)
	if invalid_target_policy == AnimaGroupMotion.InvalidTargetPolicy.CANCEL_GROUP:
		result.cancelled = true
