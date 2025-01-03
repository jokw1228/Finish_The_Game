extends Node2D
class_name SlidingPuzzleUI

const width = 3
const height = 3

var cells: Array = []
const cell_image_size = 128.0 # pixel size

@export var SlidingPuzzle_node: SlidingPuzzle

signal request_slide(index_to_request: Array[int])

func _ready() -> void:
	initialize_board_ui()

func initialize_board_ui() -> void:
	for y: int in range(height):
		var temp: Array[SlidingPuzzleCell] = []
		for x: int in range(width):
			if !(x == width-1 and y == height-1):
				var number_to_set: int = (x+width*y) + 1
				var inst: SlidingPuzzleCell \
				= SlidingPuzzleCellCreator.create\
				(Vector2(\
				(x - float(width) / 2.0) * cell_image_size, \
				(y - float(height) / 2.0) * cell_image_size), \
				number_to_set, \
				[(number_to_set-1)%width, floor(number_to_set-1)/width], \
				Callable(self, "receive_request_slide"))
				temp.append(inst)
				add_child(inst)
			else:
				temp.append(null)
		cells.append(temp)

func receive_request_slide(index_to_request: Array[int]) -> void:
	request_slide.emit(index_to_request)

func receive_approve_and_reply_slide(approved_index: Array[int], empty_index: Array[int]) -> void:
	cells[approved_index[1]][approved_index[0]].set_index(empty_index)
	
	var position_to_move: Vector2 = \
	Vector2(\
	(empty_index[0] - float(width) / 2.0) * cell_image_size, \
	(empty_index[1] - float(height) / 2.0) * cell_image_size)
	cells[approved_index[1]][approved_index[0]].move_to_position(position_to_move)
	
	cells[empty_index[1]][empty_index[0]] = cells[approved_index[1]][approved_index[0]]
	cells[approved_index[1]][approved_index[0]] = null

func receive_request_ftg_move(target_index: Array[int], empty_index: Array[int]):
	cells[target_index[1]][target_index[0]].set_index(empty_index)
	
	var position_to_move: Vector2 = \
	Vector2(\
	(empty_index[0] - float(width) / 2.0) * cell_image_size, \
	(empty_index[1] - float(height) / 2.0) * cell_image_size)
	cells[target_index[1]][target_index[0]].position = position_to_move
	
	cells[empty_index[1]][empty_index[0]] = cells[target_index[1]][target_index[0]]
	cells[target_index[1]][target_index[0]] = null
