extends GridContainer
class_name PentagoUI

const subboard_width = 3
const subboard_count_x = 2

signal request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int])

@export var subboards_to_export: Array[PentagoSubboard] = []
var subboards: Array[Array] = []

func _ready() -> void:
	# set subboards array
	for y in range(subboard_count_x):
		var temp: Array[PentagoSubboard] = []
		for x in range(subboard_count_x):
			temp.append(subboards_to_export[x+y*subboard_count_x])
		subboards.append(temp)

func receive_request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int]) -> void:
	request_place_stone.emit(requested_subboard_index, requested_cell_index)

func receive_approve_and_reply_place_stone(approved_subboard_index: Array[int], approved_cell_index: Array[int], approved_color: Pentago.CELL_STATE) -> void:
	var _x: int = approved_subboard_index[0]
	var _y: int = approved_subboard_index[1]
	subboards[_y][_x].place_stone(approved_cell_index, approved_color)
