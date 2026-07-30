class_name AnimaParallel
extends AnimaMotion

enum CompletionPolicy {
	ALL_CHILDREN,
	FIRST_CHILD,
	NAMED_CHILD,
}

@export var children: Array[AnimaMotion] = []
@export var completion_policy: CompletionPolicy = CompletionPolicy.ALL_CHILDREN
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

func estimate_duration() -> float:
	if completion_policy == CompletionPolicy.ALL_CHILDREN:
		var longest := 0.0
		for child in children:
			if child.enabled:
				longest = maxf(longest, child.estimate_duration())
		return longest

	var completion_child := get_completion_child()
	return completion_child.estimate_duration() if completion_child != null else 0.0

func create_runtime() -> Variant:
	return AnimaParallelInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	for child in children:
		errors.append_array(child.validate())
	return errors
