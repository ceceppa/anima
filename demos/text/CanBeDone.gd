extends Control

func _ready():
	var player := Anima.player(self)

	player.then($AnimaSquare/Text.get_anima())
	player.then($AnimaSquare/SecondScene.get_anima())

	player.play_with_delay(0.5)
