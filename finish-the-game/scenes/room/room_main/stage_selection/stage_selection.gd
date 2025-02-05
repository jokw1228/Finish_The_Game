extends Control
class_name StageSelection

var is_ready_to_get_input: bool = false

func receive_player_started_game() -> void:
	is_ready_to_get_input = true
	slide_in()

func slide_in() -> void:
	var target_position = Vector2(0, 0)

	create_tween().tween_property(self, "position", target_position, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
