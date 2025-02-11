extends Control
class_name Title

signal player_has_tapped_anywhere()

var is_ready_to_get_input: bool = true

func _input(event: InputEvent) -> void:
	if is_ready_to_get_input == true:
		if (event is InputEventMouseButton and event.pressed):
			player_has_tapped_anywhere.emit()

func receive_player_started_game() -> void:
	is_ready_to_get_input = false
	slide_out()

func slide_out() -> void:
	var viewport_height = get_viewport_rect().size.y
	var target_position = Vector2(position.x, -viewport_height)

	create_tween().tween_property(self, "position", target_position, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
