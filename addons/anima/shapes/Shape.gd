tool
class_name AnimaShape
extends AnimaAnimatable

func _convert_to_percentage(position: Vector2) -> Vector2:
	#position.x = rect_size.x * (position.x / 100)
	#position.y = rect_size.y * (position.y / 100)

	#return position
	return Vector2.ZERO
