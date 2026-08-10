@tool

extends Panel

@export var _fix: bool:
	set(v):
		%PanelShader.position = %AnimaCode.position
		%PanelShader.size = %AnimaCode.get_rect().size
		_apply(%Vanilla)

func _apply(source: Sprite2D):
	if not Engine.is_editor_hint():
		return

	source.region_rect.size.x = source.get_parent().get_rect().size.x / source.scale.x
	source.region_rect.size.y = source.get_parent().get_rect().size.y / source.scale.x

func play():
	var ease = AnimaEase.new()
	ease.kind = AnimaEase.Kind.EASE_OUT_QUAD

	var a = Anima.on(%Vanilla).move_by(Vector2(0, -%Vanilla.get_rect().size.y), 0.3).with_ease(ease)
	var b =	Anima.on(%Anima).move_by(Vector2(0, %AnimaPanel.get_rect().size.y), 0.3).with_ease(ease)
	var c = Anima.on(self).color(Color.TRANSPARENT, 0.3)

	Anima.play(a, %Vanilla)
	Anima.play(b, %Anima)
	Anima.play(c, self).finished
