#extends "res://addons/anima/shapes/Rectangle.gd"
tool
extends Control

const PropertyList = preload("res://addons/anima/utils/anima_properties_list.gd")

var hovered_background_color := Color("628ad1")
var pressed_background_color := Color("425d8d")
var font_color := Color("425d8d")
var hovered_font_color := Color("425d8d")
var pressed_font_color := Color("425d8d")
export var label := "Anima Button" setget set_label

onready var _original_bg_color: Color = Color.red #background_color
#
#var property_list = PropertyList.new([
#	["Hovered/BackgroundColor",TYPE_COLOR, Color("628ad1")],
#	["Hovered/FontColor",TYPE_COLOR, Color("ffffff")],
#	["Pressed/BackgroundColor",TYPE_COLOR, Color("628ad1")],
#	["Pressed/FontColor",TYPE_COLOR, Color("ffffff")],
#])
#
#func _get(property):
#	return property_list.get(property)
#
#func _set(property, value):
#	property_list.set(property, value)
#
#func _get_property_list() -> Array:
#	return property_list.properties

func set_hovered_background_color(color: Color) -> void:
	hovered_background_color = color

func set_pressed_background_color(color: Color) -> void:
	pressed_background_color = color

func set_font_color(color: Color) -> void:
	font_color = color

func set_hovered_font_color(color: Color) -> void:
	hovered_font_color = color

func set_pressed_font_color(color: Color) -> void:
	pressed_font_color = color

func set_label(label: String) -> void:
	find_node("Label").text = label

func animate(a) -> void:
	pass

func _on_mouse_entered():
	animate(
		Anima.Node() \
			.anima_property("color") \
			.anima_to(hovered_background_color) \
			.anima_duration(0.15)
	)

func _on_mouse_exited():
	animate(
		Anima.Node() \
			.anima_property("color") \
			.anima_to(_original_bg_color) \
			.anima_duration(0.15)
	)

func _on_mouse_down():
	animate(
		Anima.Node() \
			.anima_property("color") \
			.anima_to(pressed_background_color) \
			.anima_duration(0.15)
	)
