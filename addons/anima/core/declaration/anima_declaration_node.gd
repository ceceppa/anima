class_name AnimaDeclarationNode

var _data := {}
var _anima_declaration

func _init(node: Node = null):
	_data.clear()

	_data.node = node

func _set_data(data: Dictionary) -> void:
	_data = data

func _clear_data():
	_init(_data.node)

func _create_declaration_for_animation(data: Dictionary) -> AnimaDeclarationForAnimation:
	var c:= AnimaDeclarationForAnimation.new()

	_clear_data()

	for key in data:
		_data[key] = data[key]

	return c._init_me(_data)

func _create_declaration_with_easing(data: Dictionary) -> AnimaDeclarationForProperty:
	if _anima_declaration:
		_anima_declaration.clear()

	var c:= AnimaDeclarationForProperty.new()

	_clear_data()

	for key in data:
		_data[key] = data[key]

	return c._init_me(_data)

func _create_relative_declaration_with_easing(data: Dictionary) -> AnimaDeclarationForRelativeProperty:
	var c:= AnimaDeclarationForRelativeProperty.new()

	_clear_data()

	for key in data:
		_data[key] = data[key]

	return c._init_me(_data)
	
func anima_animation(animation: String, duration = null) -> AnimaDeclarationForAnimation:
	_anima_declaration = _create_declaration_for_animation({ animation = animation, duration = duration })

	return _anima_declaration

func anima_animation_frames(frames: Dictionary, duration = null) -> AnimaDeclarationForAnimation:
	_anima_declaration = _create_declaration_for_animation({ animation = frames, duration = duration })

	return _anima_declaration

func anima_property(property: String, final_value = null, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = property, to = final_value, duration = duration })

	return _anima_declaration

func anima_fade_in(duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "opacity", from = 0.0, to = 1.0, duration = duration })

	return _anima_declaration

func anima_fade_out(duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "opacity", from = 1.0, to = 0.0, duration = duration })

	return _anima_declaration

func anima_position(position: Vector2, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "position", to = position, duration = duration })

	return _anima_declaration

func anima_position3D(position: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "position", to = position, duration = duration })

	return _anima_declaration

func anima_position_x(x: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "x", to = x, duration = duration })

	return _anima_declaration

func anima_position_y(y: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "y", to = y, duration = duration })

	return _anima_declaration

func anima_position_z(z: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "z", to = z, duration = duration })

	return _anima_declaration

func anima_relative_position(position: Vector2, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "position", to = position, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position3D(position: Vector3, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "position", to = position, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position_x(x: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "x", to = x, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position_y(y: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "y", to = y, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position_z(z: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "z", to = z, duration = duration, relative = true })

	return _anima_declaration

func anima_scale(scale: Vector2, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale", to = scale, duration = duration })

	return _anima_declaration

func anima_scale3D(scale: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale", to = scale, duration = duration })

	return _anima_declaration

func anima_scale_x(x: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale:x", to = x, duration = duration })

	return _anima_declaration

func anima_scale_y(y: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale:y", to = y, duration = duration })

	return _anima_declaration

func anima_scale_z(z: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale:z", to = z, duration = duration })

	return _anima_declaration

func anima_size(size: Vector2, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size", to = size, duration = duration })

	return _anima_declaration

func anima_size3D(size: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size", to = size, duration = duration })

	return _anima_declaration

func anima_size_x(size: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size:x", to = size, duration = duration })

	return _anima_declaration

func anima_size_y(size: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size:y", to = size, duration = duration })

	return _anima_declaration

func anima_size_z(size: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size:z", to = size, duration = duration })

	return _anima_declaration

func anima_rotate(rotate: float, pivot: int = ANIMA.PIVOT.CENTER, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotate", to = rotate, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_rotate3D(rotate: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation", to = rotate, duration = duration })

	return _anima_declaration

func anima_rotate_x(x: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation:x", to = x, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_rotate_y(y: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation:y", to = y, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_rotate_z(z: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation:z", to = z, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_shader_param(param_name: String, to_value, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "shader_param:" + param_name, to = to_value, duration = duration })

	return _anima_declaration

func clear():
	if _anima_declaration:
		_anima_declaration.clear()
