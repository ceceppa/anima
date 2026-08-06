## Starts every enabled child in [member children] together; [member completion_policy]
## decides which child (or children) must finish for the group to complete.
class_name AnimaParallel
extends AnimaMotion

## Which child (or children) must finish for the group to complete.
enum CompletionPolicy {
	ALL_CHILDREN,
	FIRST_CHILD,
	NAMED_CHILD,
}

## The motions to run together.
@export var children: Array[AnimaMotion] = []
## Which child (or children) must finish for the group to complete.
@export var completion_policy: CompletionPolicy = CompletionPolicy.ALL_CHILDREN
## The [member AnimaMotion.display_name] to match against when
## [member completion_policy] is [constant CompletionPolicy.NAMED_CHILD].
@export var completion_child_name: String = ""

## Returns the single child whose completion decides the group's completion
## for FIRST_CHILD/NAMED_CHILD policies, or null for ALL_CHILDREN / no match.
func get_completion_child() -> AnimaMotion:
	match completion_policy:
		CompletionPolicy.FIRST_CHILD:
			for child in children:
				if child.enabled:
					return child
			return null
		CompletionPolicy.NAMED_CHILD:
			for child in children:
				if child.enabled and child.display_name == completion_child_name:
					return child
			return null
		_:
			return null

## Under [constant CompletionPolicy.ALL_CHILDREN], the slowest enabled child's
## duration (worst-kind-wins across children first). Otherwise defers entirely
## to [method get_completion_child]'s own duration.
func estimate_duration() -> AnimaDuration:
	if completion_policy == CompletionPolicy.ALL_CHILDREN:
		var child_durations: Array[AnimaDuration] = []
		for child in children:
			if child.enabled:
				child_durations.append(child.estimate_duration())

		var kind := AnimaDuration.worst_kind(child_durations)
		if kind != AnimaDuration.Kind.FIXED:
			return AnimaDuration.new(kind, 0.0)

		var longest := 0.0
		for child_duration in child_durations:
			longest = maxf(longest, child_duration.seconds)
		return AnimaDuration.fixed(longest)

	var completion_child := get_completion_child()
	return completion_child.estimate_duration() if completion_child != null else AnimaDuration.fixed(0.0)

## Builds the runtime instance that plays every enabled child together.
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaParallelInstance.new(self, context)

## Validates every child recursively.
func validate() -> Array[String]:
	var errors: Array[String] = []
	for child in children:
		errors.append_array(child.validate())
	return errors
