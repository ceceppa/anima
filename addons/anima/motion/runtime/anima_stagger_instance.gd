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

func _init(p_motion: AnimaMotion) -> void:
	super._init(p_motion)

	var stagger := motion as AnimaStagger
	if stagger.template == null or stagger.targets.is_empty():
		return

	var order := stagger.resolve_order()
	for position in range(order.size()):
		var entry := _EntryState.new()
		entry.target = stagger.targets[order[position]]
		entry.scheduled_start = float(position) * stagger.interval
		_entries.append(entry)

## Ignores the target this instance's own advance() receives — each entry
## drives its own target from `targets`, per AnimaStagger's contract.
func advance(_target: Node, delta: float) -> bool:
	if _entries.is_empty():
		return true

	var stagger := motion as AnimaStagger
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
