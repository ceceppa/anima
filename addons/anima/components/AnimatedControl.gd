@tool
extends Control
class_name AnimaAnimatedController

@export var tree_entered_animation := ""
@export var tree_exiting_animation := ""
@export var ready_animation := ""
@export var focus_entered_animation := ""
@export var focus_exited_animation := ""
@export var mouse_entered_animation := ""
@export var mouse_exited_animation := ""

func _ready():
	if mouse_entered_animation:
		mouse_entered.connect(_on_simple_event(mouse_entered_animation))

	if mouse_exited_animation:
		mouse_exited.connect(_on_simple_event(mouse_exited_animation))
	
func _draw():
	draw_rect(get_rect(), Color.REBECCA_PURPLE)

func _on_mouse_entered():
	Anima.Node(self).anima_animation(mouse_entered_animation).play()

func _on_simple_event(animation: String):
	print(animation)

	return func ():
		print(animation)
		Anima.Node(self).anima_animation(animation).play()

func is_anima_animated_control():
	return true
