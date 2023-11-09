@tool
extends AnimaAnimatedControl

func _on_button_pressed():
	_notification(NOTIFICATION_WM_CLOSE_REQUEST)
