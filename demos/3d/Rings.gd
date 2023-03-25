@tool
extends Node3D

func _ready():
	if $Group1.get_child_count() == 1:
		_add_rings($Group1, $Group1/RingA)
	if $Group2.get_child_count() == 1:
		_add_rings($Group2, $Group2/RingB, 0.06)
	if $Group3.get_child_count() == 1:
		_add_rings($Group3, $Group3/RingC, 0.06)

	AnimaAnimationsUtils.register_animation("ring1", ring1_frames())
	AnimaAnimationsUtils.register_animation("ring2", ring2_frames())
	AnimaAnimationsUtils.register_animation("ring3", ring3_frames())

	_setup_animation($Group1, 'ring1')
	_setup_animation($Group2, 'ring2')
	_setup_animation($Group3, 'ring3')

func _setup_animation(group: Node3D, animation_name: String) -> void:
	var anima := Anima.begin(group)
	anima.then({ group = group, animation = animation_name, duration = 5.0, items_delay = 0.05 })
	anima.loop()

func _add_rings(parent: Node3D, mesh, scale_value: float = 0.05) -> void:
	for index in 10:
		var ring = mesh.duplicate()
		var p = float(index + 1) / 100
		var scale = Vector3(scale_value, ring.scale.z, scale_value) + Vector3(p, 0, p)

		ring.scale = ring.scale + (scale * Vector3(index + 1, 1, index + 1))

		parent.add_child(ring)

func ring1_frames():
	return {
		0: {
			"translate:y": 0,
			"easing": ANIMA.EASING.EASE_IN_CIRC
		},
		10: {
			"translate:y": 0.5,
			"easing": ANIMA.EASING.EASE_IN_OUT_CIRC
		},
		60: {
			"translate:y": -1,
			"easing": ANIMA.EASING.EASE_IN_CIRC
		},
		100: {
			"translate:y": 0,
			"easing": ANIMA.EASING.EASE_IN_OUT_BACK
		}
	}

func ring2_frames():
	return {
		0: {
			rotation = Vector3.ZERO,
			easing = ANIMA.EASING.EASE_IN_CIRC
		},
		"to": {
			rotation = Vector3(0, 0, PI * 2),
			easing = ANIMA.EASING.EASE_OUT_BACK
		}
	}

func ring3_frames():
	return {
		from = {
			rotation = Vector3.ZERO,
			easing = ANIMA.EASING.EASE_OUT_BACK
		},
		to = {
			rotation = Vector3(0, 0, PI)
		}
	}
