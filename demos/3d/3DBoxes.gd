extends Spatial

export (bool) var _play_backwards = false

const DEFAULT_START_POSITION := Vector3(23.142, 1.798, 0)
const TOTAL_BOXES := 20
const DISTANCE := 0.3

export var _test_me:= false setget set_test_me

func _ready():
	AnimaAnimationsUtils.register_animation('3dboxes', _boxes_animation())
	AnimaAnimationsUtils.register_animation('ring', _ring())

	_init_boxes($Node)

	if not Engine.editor_hint:
		_do_animation()

func _do_animation(loop:= true) -> void:
	var start_position: Vector3 = DEFAULT_START_POSITION
	_reset_boxes_position($Node, start_position)

	var anima := Anima.begin($Node) \
		.then( Anima.Group($Node, 0.02).anima_animation('3dboxes', 3) )
#		.then( Anima.Group($Node, 0.02).anima_shader_param("albedo", Color("#6b9eb1")).anima_from(Color('#6b9eb1')).debug() )

	if _play_backwards:
		_init_reverse_boxes()
		start_position.z -= 2

	if loop:
		anima.loop()
	else:
		anima.play()

	var ring := Anima.begin($ring)
	ring.then( Anima.Node($ring).anima_animation('ring', 3) )

	if _play_backwards:
		ring.loop_backwards()
	else:
		ring.loop()

func _ring() -> Dictionary:
	return { 
		from = {
			"rotation:x": 0, 
		},
		to = {
			"rotation:x": 360
		}
	}

func _boxes_animation() -> Dictionary:
	return {
		from = {
			scale = Vector3(0.1, 1, 1),
			"shader_param:albedo": Color('#6b9eb1'),
		},
		30: {
			"shader_param:albedo": Color('#6b9eb1')
		},
		35: {
			"+x": -28.117,
			easing = ANIMA.EASING.EASE_OUT_QUAD,
		},
		40: {
			"shader_param:albedo": Color('#e63946'),
			"+x": -28.117,
		},
		65: {
			"+x": -28.117,
			scale = Vector3(0.1, 1, 1),
			"shader_param:albedo": Color('#e63946')
		},
		70: {
			scale = Vector3(0.1, 1, 1),
		},
		85: {
			scale = Vector3.ZERO,
		},
		to = {
			"+x": -25.619,
			easing = ANIMA.EASING.EASE_IN_CIRC,
			"+rotation:x": 360,
			"shader_param:albedo": Color('#6b9eb1')
		},
	}

func _init_reverse_boxes() -> void:
	var node = Node.new()
	var box = $Node.get_child(0)
	var clone = box.duplicate()

	node.add_child(clone)
	add_child(node)

	_init_boxes(node)
	_reset_boxes_position(node, DEFAULT_START_POSITION + Vector3(0, 0, 2))

	var anima_reverse := Anima.begin(node)
	anima_reverse.then({ group = node, animation = '3dboxes', duration = 3, items_delay = 0.02 })

	anima_reverse.loop_backwards()

func _init_boxes(parentNode: Node) -> void:
	var box := parentNode.get_child(0)

	box.remove_meta("_initial_relative_value_rotation:x")
	box.remove_meta("_last_relative_value_rotation:x")

	for i in TOTAL_BOXES:
		var clone := box.duplicate()
		clone.global_transform = box.global_transform

		clone.remove_meta("_initial_relative_value_rotation:x")
		clone.remove_meta("_last_relative_value_rotation:x")

		parentNode.add_child(clone)

func _reset_boxes_position(parentNode: Node, start_position: Vector3) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in parentNode.get_child_count():
		var box = parentNode.get_child(i)
		if not box is MeshInstance:
			continue

		box.global_transform.origin = start_position + Vector3(DISTANCE, 0, 0) * i
		
		var r = rng.randf_range(0, 360)
		box.rotation.x = r

func set_test_me(_ignore) -> void:
	_do_animation()
