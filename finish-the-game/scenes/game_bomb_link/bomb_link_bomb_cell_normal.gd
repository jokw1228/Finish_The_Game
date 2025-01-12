extends BombLinkBombCell
class_name BombLinkBombCellNormal

signal request_bomb_rotation()

func _on_pressed() -> void:
	request_bomb_rotation.emit()
