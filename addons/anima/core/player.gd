class_name AnimaPlayer
extends Node

signal completed

var _nodes_data := []

func then(anima_node: AnimaNode, delay := 0.0) -> void:
	_nodes_data.push_back([{ node = anima_node, delay = delay }])

func with(anima_node: AnimaNode, delay := 0.0) -> void:
	var size = _nodes_data.size()

	if size > 0:
		_nodes_data[size - 1].push_back({ node = anima_node, delay = delay })
	else:
		then(anima_node, delay)

func play() -> void:
	for node_data in _nodes_data:
		yield(_play(node_data), 'completed')

	emit_signal("completed")

func play_with_delay(delay: float) -> void:
	yield(get_tree().create_timer(delay), "timeout")

	play()

func _play(nodes_data: Array) -> void:
	var max_duration: float = Anima.MINIMUM_DURATION

	for data in nodes_data:
		var node = data.node
		var delay = data.delay

		if delay == 0:
			node.play()
		else:
			node.play_with_delay(delay)

		max_duration = max(node.get_length() + delay, max_duration)

	yield(get_tree().create_timer(max_duration), "timeout")
