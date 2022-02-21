extends Spatial

export (bool) var _play_backwards = false

const DEFAULT_START_POSITION := Vector3(23.142, 1.798, 0)

func _ready():
	Anima.register_animation(self, '3dboxes')
	Anima.register_animation(self, 'ring')

	_init_boxes($Node)
	
	var start_position: Vector3 = DEFAULT_START_POSITION

	var anima: AnimaNode = Anima.begin($Node)
	anima.then({ group = $Node, animation = '3dboxes', duration = 3, items_delay = 0.02 })

	if _play_backwards:
		_init_reverse_boxes()
		start_position.z -= 2

	_reset_boxes_position($Node, start_position)
	anima.loop()

	var ring: AnimaNode = Anima.begin($ring)
	ring.then({ node = $ring, animation = 'ring', duration = 3 })

	if _play_backwards:
		ring.loop_backwards()
	else:
		ring.loop()

func generate_animation(tween: AnimaTween, data: Dictionary) -> void:
	if data.animation == '3dboxes':
		_boxes_animation(tween, data)

		return

	var rotate = [
		{ from = 0, to = 360 }
	]

#	tween.add_frames(data, "rotation:y", rotate)

func _boxes_animation(tween: AnimaTween, data: Dictionary) -> void:
	var position_frames = [
		{ percentage = 35, to = -28.117, easing = Anima.EASING.EASE_OUT_CUBIC },
		{ percentage = 65, to = 0 },
		{ percentage = 100, to = -25.619, easing = Anima.EASING.EASE_IN_CIRC },
	]
	
	var rotation_frames = [
		{ percentage = 100, to = 360 },
	]

	var scale_frames = [
		{ percentage = 0, from = Vector3(0.1, 1, 1) },
		{ percentage = 65, to = Vector3(0.1, 1, 1) },
		{ percentage = 100, to = Vector3.ZERO },
	]

	var shader_params = [
		{ percentage = 0, from = Color('#6b9eb1') },
		{ percentage = 30, to = Color('#e63946') },
		{ percentage = 40, to = Color('#e63946') },
		{ percentage = 100, to = Color('#6b9eb1') },
	]

#	tween.add_relative_frames(data, "position:x", position_frames)
#	tween.add_relative_frames(data, "rotation:x", rotation_frames)
#	tween.add_frames(data, "scale", scale_frames)
#	tween.add_frames(data, "shader_param:albedo", shader_params)

func _init_reverse_boxes() -> void:
	var node = Node.new()
	var box = $Node.get_child(0)
	var clone = box.duplicate()

	node.add_child(clone)
	add_child(node)

	_init_boxes(node)
	_reset_boxes_position(node, DEFAULT_START_POSITION + Vector3(0, 0, 2))

	var anima_reverse: AnimaNode = Anima.begin(node)
	anima_reverse.then({ group = node, animation = '3dboxes', duration = 3, items_delay = 0.02 })

	anima_reverse.loop_backwards()

func _init_boxes(parentNode: Node) -> void:
	var box := parentNode.get_child(0)

	for i in 10:
		var clone := box.duplicate()
		clone.global_transform = box.global_transform

		parentNode.add_child(clone)

func _reset_boxes_position(parentNode: Node, start_position: Vector3) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in parentNode.get_child_count():
		var box = parentNode.get_child(i)
		if not box is MeshInstance:
			continue

		box.global_transform.origin = start_position + Vector3(0.2, 0, 0) * i
		
		var r = rng.randf_range(0, 360)
		box.rotation.x = r
