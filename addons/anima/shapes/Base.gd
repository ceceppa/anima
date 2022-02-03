tool
extends Control
class_name AnimaShape

const PropertyList = preload("res://addons/anima/utils/anima_properties_list.gd")

var property_list

func _get(property: String):
	return property_list.get(property)

func _set(property: String, value):
	property_list.set(property, value)

	update()

func _get_property_list() -> Array:
	if property_list:
		return property_list.get_property_list()

	return []

func get_property(name: String):
	return _get(name)

func animate(anima_data: AnimaDeclarationBase, auto_play := true) -> AnimaNode:
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.then(anima_data)

	if auto_play:
		anima.play()

	return anima
