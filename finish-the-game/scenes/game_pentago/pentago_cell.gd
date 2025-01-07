extends TextureButton
class_name  PentagoCell

const cell_image_width = 128 # pixel size

signal request_place_stone(requested_cell_index: Array[int])

@export var cell_index: Array[int] = []

func set_cell_index(index_to_set: Array[int]):
	cell_index = index_to_set

func _on_pressed() -> void:
	request_place_stone.emit(cell_index)

func place_stone(color_to_place: Pentago.CELL_STATE) -> void:
	add_child(PentagoStoneCreator.create(Vector2(cell_image_width/2, cell_image_width/2), color_to_place))

func receive_request_set_cell_disabled(disabled_to_set: bool) -> void:
	disabled = disabled_to_set
