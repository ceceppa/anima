class_name AnimaDeclarationNode

var _node: Node

func _init(node: Node):
	_node = node

	return self

func anima_animation(animation: String, duration = null) -> AnimaDeclarationBase:
	var c:= AnimaDeclarationBase.new()

	return c._init_me({ node = _node, animation = animation, duration = duration })

func anima_property(property: String, value, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = property, to = value, duration = duration })

func anima_fade_in(duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "opacity", to = 1.0, duration = duration })

func anima_fade_out(duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "opacity", to = 1.0, duration = duration })

func anima_position(position: Vector2, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "position", to = position, duration = duration })

func anima_position3D(position: Vector3, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "position", to = position, duration = duration })

func anima_position_x(x: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "x", to = x, duration = duration })

func anima_position_y(y: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "y", to = y, duration = duration })

func anima_position_z(z: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "z", to = z, duration = duration })

func anima_relative_position(position: Vector2, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "position", to = position, duration = duration, relative = true })

func anima_relative_position3D(position: Vector3, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "position", to = position, duration = duration, relative = true })

func anima_relative_position_x(x: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "x", to = x, duration = duration, relative = true })

func anima_relative_position_y(y: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "y", to = y, duration = duration, relative = true })

func anima_relative_position_z(z: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "z", to = z, duration = duration, relative = true })

func anima_scale(scale: Vector2, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "scale", to = scale, duration = duration })

func anima_scale3D(scale: Vector3, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "scale", to = scale, duration = duration })

func anima_scale_x(x: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "scale:x", to = x, duration = duration })

func anima_scale_y(y: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "scale:y", to = y, duration = duration })

func anima_scale_z(z: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "scale:z", to = z, duration = duration })

func anima_rotate(rotate: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "rotation", to = rotate, duration = duration })

func anima_rotate3D(rotate: Vector3, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "rotation", to = rotate, duration = duration })

func anima_rotate_x(x: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "rotation:x", to = x, duration = duration })

func anima_rotate_y(y: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "rotation:y", to = y, duration = duration })

func anima_rotate_z(z: float, duration = null) -> AnimaDeclarationWithEasing:
	var c:= AnimaDeclarationWithEasing.new()

	return c._init_me({ node = _node, property = "rotation:z", to = z, duration = duration })
