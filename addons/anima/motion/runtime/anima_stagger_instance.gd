## Runtime instance for [_AnimaStagger] — advances one [member _AnimaStagger.template]
## instance per target, started per the resolved stagger order.
class_name AnimaStaggerInstance
extends AnimaMotionInstance

class _EntryState:
	var target: Node
	var scheduled_start: float = 0.0
	var instance: Variant = null
	var started: bool = false
	var finished: bool = false

var _elapsed: float = 0.0
var _entries: Array[_EntryState] = []

func _init(p_motion: AnimaMotion, p_value_context: AnimaValueContext = null) -> void:
	super._init(p_motion, p_value_context)

	var stagger := motion as _AnimaStagger
	if stagger.template == null or stagger.targets.is_empty():
		return

	var order := stagger.resolve_order()
	for position in range(order.size()):
		var entry := _EntryState.new()
		entry.target = stagger.targets[order[position]]
		entry.scheduled_start = float(position) * stagger.interval
		_entries.append(entry)

## Ignores the target this instance's own advance() receives — each entry
## drives its own target from `targets`, per _AnimaStagger's contract.
func advance(_target: Node, delta: float) -> bool:
	if _entries.is_empty():
		return true

	var stagger := motion as _AnimaStagger
	_elapsed += delta

	for entry in _entries:
		if entry.finished:
			continue

		if not entry.started:
			if _elapsed < entry.scheduled_start:
				continue
			entry.started = true
			entry.instance = stagger.template.create_runtime()

		entry.finished = entry.instance.advance(entry.target, delta)

	for entry in _entries:
		if not entry.finished:
			return false
	return true

## Restores every started entry's own captured initial value on its own
## target — [param _target] is ignored, the same way [method advance]'s is.
func restore_initial(_target: Node) -> void:
	for entry in _entries:
		if entry.started and entry.instance != null:
			entry.instance.restore_initial(entry.target)

## Forces every entry to its own final state on its own target, starting any
## that have not begun yet.
func force_complete(_target: Node) -> void:
	var stagger := motion as _AnimaStagger
	for entry in _entries:
		if not entry.started:
			entry.started = true
			entry.instance = stagger.template.create_runtime()
		entry.instance.force_complete(entry.target)
		entry.finished = true
