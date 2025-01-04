extends TextureButton
class_name PentagoSubboard

const subboard_width = 3

signal request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int])

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
