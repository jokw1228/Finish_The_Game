extends Sprite2D
class_name OrbitoBoard

var board_size = 4

@export var cells_to_export: Array[OrbitoCell] = []
var cells: Array[Array] = []

signal request_select_cell(cell_index: Array[int])

func _ready() -> void:
	# set cells array
	for y in range(board_size):
		var temp: Array[OrbitoCell] = []
		for x in range(board_size):
			temp.append(cells_to_export[x+y*board_size])
		cells.append(temp)

func receive_select_cell(cell_index: Array[int]):
	request_select_cell.emit(cell_index)
	
func receive_request_place_stone(cell_index: Array[int], color_to_place: Orbito.CELL_STATE):
	var _x = cell_index[0]
	var _y = cell_index[1]
	cells[_x][_y].place_stone(color_to_place)
	
func receive_request_move_stone(start_cell_index: Array[int], end_cell_index: Array[int], color_to_move: Orbito.CELL_STATE):
	var start_x = start_cell_index[0]
	var start_y = start_cell_index[1]
	var end_x = end_cell_index[0]
	var end_y = end_cell_index[1]
	cells[start_x][start_y].remove_stone()
	cells[end_x][end_y].place_stone(color_to_move)

func receive_request_remove_stone(cell_index: Array[int]):
	var _x = cell_index[0]
	var _y = cell_index[1]
	cells[_x][_y].remove_stone()
