class_name AnimaDeclarationNode

var _data: Dictionary

func _init(node: Node = null):
	_data.node = node

func _set_data(data: Dictionary) -> void:
	_data = data

func _create_declaration_for_animation(data: Dictionary) -> AnimaDeclarationForAnimation:
	var c:= AnimaDeclarationForAnimation.new()

	for key in data:
		_data[key] = data[key]

	return c._init_me(_data)

func _create_declaration_with_easing(data: Dictionary) -> AnimaDeclarationForProperty:
	var c:= AnimaDeclarationForProperty.new()

	for key in data:
		_data[key] = data[key]

	return c._init_me(_data)

func _create_relative_declaration_with_easing(data: Dictionary) -> AnimaDeclarationForRelativeProperty:
	var c:= AnimaDeclarationForRelativeProperty.new()

	for key in data:
		_data[key] = data[key]

	return c._init_me(_data)

func anima_animation(animation: String, duration = null) -> AnimaDeclarationForAnimation:
	return _create_declaration_for_animation({ animation = animation, duration = duration })

func anima_animation_frames(frames: Dictionary, duration = null) -> AnimaDeclarationForAnimation:
	return _create_declaration_for_animation({ animation = frames, duration = duration })

func anima_property(property: String, final_value = null, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = property, to = final_value, duration = duration })

func anima_fade_in(duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "opacity", from = 0.0, to = 1.0, duration = duration })

func anima_fade_out(duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "opacity", from = 1.0, to = 0.0, duration = duration })

func anima_position(position: Vector2, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "position", to = position, duration = duration })

func anima_position3D(position: Vector3, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "position", to = position, duration = duration })

func anima_position_x(x: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "x", to = x, duration = duration })

func anima_position_y(y: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "y", to = y, duration = duration })

func anima_position_z(z: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "z", to = z, duration = duration })

func anima_relative_position(position: Vector2, duration = null) -> AnimaDeclarationForRelativeProperty:
	return _create_relative_declaration_with_easing({ property = "position", to = position, duration = duration, relative = true })

func anima_relative_position3D(position: Vector3, duration = null) -> AnimaDeclarationForRelativeProperty:
	return _create_relative_declaration_with_easing({ property = "position", to = position, duration = duration, relative = true })

func anima_relative_position_x(x: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	return _create_relative_declaration_with_easing({ property = "x", to = x, duration = duration, relative = true })

func anima_relative_position_y(y: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	return _create_relative_declaration_with_easing({ property = "y", to = y, duration = duration, relative = true })

func anima_relative_position_z(z: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	return _create_relative_declaration_with_easing({ property = "z", to = z, duration = duration, relative = true })

func anima_scale(scale: Vector2, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "scale", to = scale, duration = duration })

func anima_scale3D(scale: Vector3, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "scale", to = scale, duration = duration })

func anima_scale_x(x: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "scale:x", to = x, duration = duration })

func anima_scale_y(y: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "scale:y", to = y, duration = duration })

func anima_scale_z(z: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "scale:z", to = z, duration = duration })

func anima_size(size: Vector2, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "size", to = size, duration = duration })

func anima_size3D(size: Vector3, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "size", to = size, duration = duration })

func anima_size_x(size: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "size:x", to = size, duration = duration })

func anima_size_y(size: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "size:y", to = size, duration = duration })

func anima_size_z(size: float, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "size:z", to = size, duration = duration })

func anima_rotate(rotate: float, pivot: int = ANIMA.PIVOT.CENTER, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "rotate", to = rotate, duration = duration, pivot = pivot })

func anima_rotate3D(rotate: Vector3, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "rotation", to = rotate, duration = duration })

func anima_rotate_x(x: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "rotation:x", to = x, duration = duration, pivot = pivot })

func anima_rotate_y(y: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "rotation:y", to = y, duration = duration, pivot = pivot })

func anima_rotate_z(z: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "rotation:z", to = z, duration = duration, pivot = pivot })

func anima_shader_param(param_name: String, to_value, duration = null) -> AnimaDeclarationForProperty:
	return _create_declaration_with_easing({ property = "shader_param:" + param_name, to = to_value, duration = duration })
