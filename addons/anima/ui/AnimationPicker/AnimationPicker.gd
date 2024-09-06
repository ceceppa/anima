@tool
extends VBoxContainer

const HEADER_BUTTON = preload("res://addons/anima/ui/AnimationPicker/HeaderButton.tscn")

@onready var List: VBoxContainer = find_child("ListContainer")
@onready var LabelDemo: Control = find_child("LabelDemo")
@onready var SpriteDemo: Sprite2D = find_child("SpriteDemo")
@onready var AnimationSpeed: LineEdit = find_child("AnimationSpeed")

var ActiveDemoNode: Node

signal animation_selected(name: String)
signal close_pressed

var _anima: AnimaNode
var _animation_name: String

func _ready():
	var animations = AnimaAnimationsUtils.get_available_animation_by_category()
	var is_first_header := true

	AnimationSpeed.set_text(str(ANIMA.DEFAULT_DURATION))

	for group in animations:
		var header: Button = _create_new_header(group)
		List.add_child(header)
		
		var container := VBoxContainer.new()

		container.add_theme_constant_override("separation", 0)
		container.name = "__" + group
		container.hide()

		for animation in animations[group]:
			container.add_child(_create_animation_button(animation))

		List.add_child(container)
		List.add_spacer(false)

		if is_first_header:
			header.set_pressed(true)
			container.show()

		is_first_header = false

	_anima = Anima.begin(self)

	ActiveDemoNode = SpriteDemo
	ActiveDemoNode.show()
	LabelDemo.modulate.a = 0
	_on_item_rect_changed()

func _create_new_header(animation: String) -> Button:
	var button: Button = HEADER_BUTTON.instantiate()

	button.set_text(animation.replace('_', ' ').capitalize())
	button.pressed.connect(func():
		var group: VBoxContainer

		for child in List.get_children():
			if child.name == "__" + animation:
				group = child

				break

		group.visible = button.is_pressed()
	)

	return button

func _create_animation_button(label: String) -> HBoxContainer:
	var container := HBoxContainer.new()
	var button: Button = Button.new()

	button.text = label.replace('_', ' ').capitalize()
	button.set_meta('_animation', label)
	button.pressed.connect(_on_animation_button_pressed.bind(label))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_PASS

	var edit_button := Button.new()
	edit_button.icon = load("res://addons/anima/icons/more.svg")
	edit_button.text = "Edit"
	edit_button.hide()
	edit_button.mouse_filter = Control.MOUSE_FILTER_PASS

	container.add_child(button)
	container.add_child(edit_button)
	container.mouse_entered.connect(func ():
		edit_button.show()
	)

	container.mouse_exited.connect(func ():
		edit_button.hide()
	)

	return container

func _on_close_requested():
	hide()

func _on_animation_button_pressed(animation_name: String):
	_animation_name = animation_name

	_anima.reset_and_clear()

	var anima := _anima.then( 
		Anima.Node(ActiveDemoNode).anima_animation(animation_name, AnimationSpeed.get_text().to_float())
	).play()

	await anima.animation_completed

func _on_use_animation_pressed():
	animation_selected.emit(_animation_name)

func _on_close_button_pressed():
	close_pressed.emit()

func _on_animation_speed_text_submitted(new_text):
	_on_animation_button_pressed(_animation_name)

func _on_item_rect_changed():
	if SpriteDemo:
		SpriteDemo.position = LabelDemo.position
		SpriteDemo.position += (SpriteDemo.get_rect().size / 2) - (SpriteDemo.get_rect().size - LabelDemo.get_rect().size) / 2
