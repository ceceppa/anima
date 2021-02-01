tool
extends Spatial

func _ready():
	if $Group1.get_child_count() == 1:
		_add_rings($Group1, $Group1/RingA)
	if $Group2.get_child_count() == 1:
		_add_rings($Group2, $Group2/RingB, 0.06)
	if $Group3.get_child_count() == 1:
		_add_rings($Group3, $Group3/RingC, 0.06)

	Anima.register_animation(self, 'ring1')
	Anima.register_animation(self, 'ring2')
	Anima.register_animation(self, 'ring3')

	_setup_animation($Group1, 'ring1')
	_setup_animation($Group2, 'ring2')
	_setup_animation($Group3, 'ring3')

func _setup_animation(group: Spatial, animation_name: String) -> void:
	var anima := Anima.group(group)
	anima.set_animation(animation_name)
	anima.set_start_delay(0.5)
	anima.set_item_duration(5.0)
	anima.set_items_delay(0.05)
	anima.end()

	anima.loop()

func _add_rings(parent: Spatial, mesh, scale_value: float = 0.05) -> void:
	for index in 10:
		var ring = mesh.duplicate()
		var p = float(index + 1) / 100
		var scale = Vector3(scale_value, ring.scale.z, scale_value) + Vector3(p, 0, p)

		ring.scale = ring.scale + (scale * Vector3(index + 1, 1, index + 1))

		parent.add_child(ring)

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var frames = [
		{ percentage = 0, from = 0, easing = Anima.EASING.EASE_IN_CIRC },
		{ percentage = 10, to = 0.5, easing = Anima.EASING.EASE_IN_OUT_CIRC },
		{ percentage = 60, to = -1, easing = Anima.EASING.EASE_IN_CIRC },
		{ percentage = 100, to = 0.5, easing = Anima.EASING.EASE_IN_OUT_BACK },
	]

	var rotate = [
		{ from = Vector3(0, 0, 0), to = Vector3(0, 0, 180), easing = Anima.EASING.EASE_OUT_BACK }
	]

	var rotate2 = [
		{ percentage = 0, from = Vector3(0, 0, 0), easing = Anima.EASING.EASE_IN_CIRC }, 
		{ percentage = 100, to = Vector3(0, 0, 360), easing = Anima.EASING.EASE_OUT_BACK }
	]

	var rotate3 = [
		{ from = Vector3(0, 0, 0), to = Vector3(360, 180, 180), easing = Anima.EASING.EASE_OUT_BACK }
	]

	if data.animation == 'ring1':
		anima_tween.add_relative_frames(data, "y", frames)

	if data.animation == 'ring2':
		anima_tween.add_frames(data, "rotation", rotate2)

	if data.animation == 'ring3':
		anima_tween.add_frames(data, "rotation", rotate3)
