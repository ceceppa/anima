extends Node2D

func _ready():
	var anima: AnimaNode = Anima.begin_single_shot(self, 'sequential')

	anima.then( Anima.Node($Logo).anima_position_x(100, 1) )
	anima.with( Anima.Node($Logo).anima_position_y(80, 1) )
	anima.with( Anima.Node($Logo).anima_rotate(90, 1) )
	anima.play_with_delay(2)
