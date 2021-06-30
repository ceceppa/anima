class_name AnimaPlayer
extends Node

var _nodes := []

func then(anima_node: AnimaNode) -> void:
	_nodes.push_back([anima_node])

func with(anima_node: AnimaNode) -> void:
	var size = _nodes.size()

	if size > 0:
		_nodes[size - 1].push_back(anima_node)
	else:
		then(anima_node)

func play() -> void:
	for node in _nodes:
		yield(_play(node), 'completed')


func play_with_delay(delay: float) -> void:
	yield(get_tree().create_timer(delay), "timeout")

	play()

func _play(nodes: Array) -> void:
	var max_duration := 0.000001

	for node in nodes:
		node.play()

		max_duration = max(node.get_length(), max_duration)

	yield(get_tree().create_timer(max_duration), "timeout")
