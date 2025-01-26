extends TextureButton
class_name RicochetRobotCell

var cell_index: Vector2 = Vector2(0,0)

signal request_cell_pressed(cell_index: Vector2)

func _on_pressed() -> void:
	request_cell_pressed.emit(cell_index)
