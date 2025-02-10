extends ColorRect
class_name OptionsPopup

func _ready() -> void:
	visible = false
	return

func _on_options_button_pressed() -> void:
	visible = true
	return

func _on_exit_options_button_pressed() -> void:
	visible = false
	return
