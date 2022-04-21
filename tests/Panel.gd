extends Panel

func _ready():
	Anima.begin_single_shot(self) \
		.then( Anima.Node(self).anima_scale_y(1.0, 0.3).anima_from(0) ) \
		.then( Anima.Node($VBoxContainer/Label).anima_animation("typewrite", 0.01) ) \
		.then( Anima.Node($VBoxContainer/Button).anima_animation('tada', 0.5 ).anima_delay(-0.1) )
