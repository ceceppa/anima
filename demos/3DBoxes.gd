extends Spatial

func _ready():
	Anima.register_animation(self, '3dboxes')
	Anima.register_animation(self, 'ring')

	_init_boxes()
	_reset_boxes_position()

	var anima := Anima.group($Node)
	anima.set_animation('3dboxes')
	anima.set_duration(3)
	anima.set_items_delay(0.02)
	anima.end()
	anima.loop()

	var ring := Anima.begin($ring)
	ring.then({ node = $ring, animation = 'ring', duration = 3 })
	ring.loop()

func generate_animation(tween: AnimaTween, data: Dictionary) -> void:
	if data.animation == '3dboxes':
		_boxes_animation(tween, data)

		return

	var rotate = [
		{ from = 0, to = 360 }
	]

	tween.add_frames(data, "rotation:y", rotate)

func _boxes_animation(tween: AnimaTween, data: Dictionary) -> void:
	var position_frames = [
		{ percentage = 0, from = 0 },
		{ percentage = 35, to = -28.117, easing = Anima.EASING.EASE_OUT_CUBIC },
		{ percentage = 65, to = 0 },
		{ percentage = 100, to = -25.619, easing = Anima.EASING.EASE_IN_CIRC },
	]
	
	var rotation_frames = [
		{ percentage = 0, from = 0 },
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

	tween.add_relative_frames(data, "position:x", position_frames)
	tween.add_relative_frames(data, "rotation:x", rotation_frames)
	tween.add_frames(data, "scale", scale_frames)
	tween.add_frames(data, "shader_param:albedo", shader_params)

func _init_boxes() -> void:
	for i in 20:
		var clone := $Node/Box.duplicate()
		clone.global_transform = $Node/Box.global_transform

		$Node.add_child(clone)

func _reset_boxes_position() -> void:
	var rng = RandomNumberGenerator.new()

	for i in $Node.get_child_count():
		var box = $Node.get_child(i)
		if not box is MeshInstance:
			continue

		box.global_transform.origin = Vector3(23.142, 1.798, 0) + (Vector3(0.2, 0, 0) * i)
		box.rotation.x = rng.randf_range(0, deg2rad(360))
