extends HBoxContainer
class_name PentagoRotationButtons

signal request_rotate_subboard(requested_rotation_direction: Pentago.ROTATION_DIRECTION)

func receive_request_set_rotation_buttons_disabled(disabled_to_set: bool) -> void:
	if disabled_to_set == true:
		visible = false
		mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	elif disabled_to_set == false:
		visible = true
		mouse_filter = MouseFilter.MOUSE_FILTER_PASS

func _on_ccw_pressed() -> void:
	request_rotate_subboard.emit(Pentago.ROTATION_DIRECTION.CCW)

func _on_cw_pressed() -> void:
	request_rotate_subboard.emit(Pentago.ROTATION_DIRECTION.CW)
