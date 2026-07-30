class_name AnimaSequenceInstance
extends AnimaMotionInstance

var _enabled_children: Array[AnimaMotion] = []
var _current_index: int = -1
var _current_instance: Variant = null

func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)

	var sequence := motion as AnimaSequence
	for child in sequence.children:
		if child.enabled:
			_enabled_children.append(child)

	_advance_to_next_child()

func _advance_to_next_child() -> void:
	_current_index += 1
	if _current_index < _enabled_children.size():
		_current_instance = _enabled_children[_current_index].create_runtime()
	else:
		_current_instance = null

func advance(target: Node, delta: float) -> bool:
	if _current_instance == null:
		return true

	var child_finished: bool = _current_instance.advance(target, delta)
	if child_finished:
		_advance_to_next_child()
		if _current_instance == null:
			return true

	return false
