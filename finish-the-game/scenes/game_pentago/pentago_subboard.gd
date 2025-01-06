extends TextureButton
class_name PentagoSubboard

const subboard_width = 3

signal request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int])
signal request_set_cell_disabled(disabled_to_set: bool)
signal request_select_subboard(subboard_index_to_rotate: Array[int])

@export var subboard_index: Array[int] = []

@export var cells_to_export: Array[PentagoCell] = []
var cells: Array[Array] = []

func _ready() -> void:
	# set cells array
	for y in range(subboard_width):
		var temp: Array[PentagoCell] = []
		for x in range(subboard_width):
			temp.append(cells_to_export[x+y*subboard_width])
		cells.append(temp)
	
func receive_request_place_stone(requested_cell_index: Array[int]) -> void:
	request_place_stone.emit(subboard_index, requested_cell_index)

func place_stone(cell_index_to_place: Array[int], color_to_place: Pentago.CELL_STATE) -> void:
	var _x: int = cell_index_to_place[0]
	var _y: int = cell_index_to_place[1]
	cells[_y][_x].place_stone(color_to_place)

func receive_request_set_subboard_disabled(disabled_to_set: bool) -> void:
	disabled = disabled_to_set

func receive_request_set_cell_disabled(disabled_to_set: bool) -> void:
	request_set_cell_disabled.emit(disabled_to_set)

func _on_pressed() -> void:
	request_select_subboard.emit(subboard_index)

func rotate_subboard(rotation_direction_to_rotate: Pentago.ROTATION_DIRECTION) -> void:
	var rotation_amount: float = PI/2 \
	if rotation_direction_to_rotate == Pentago.ROTATION_DIRECTION.CW \
	else -PI/2
	
	var tween_rotation: Tween = get_tree().create_tween()
	tween_rotation.tween_property(self, "rotation", rotation+rotation_amount, 0.05)
