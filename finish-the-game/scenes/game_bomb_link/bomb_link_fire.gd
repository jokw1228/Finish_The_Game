extends Sprite2D
class_name BombLinkFire

func move_to_position(position_to_move) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", position_to_move, BombLinkUI.delay)\
	.set_trans(Tween.TransitionType.TRANS_QUART)

func spawn() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), BombLinkUI.delay)

func extinguish() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), BombLinkUI.delay)
