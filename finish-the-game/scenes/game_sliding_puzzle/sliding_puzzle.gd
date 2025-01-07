extends Node2D
class_name SlidingPuzzle

const width = 3
const height = 3

var board: Array[Array] = []
var current_empty_index: Array[int]

signal approve_and_reply_slide(approved_index: Array[int], empty_index: Array[int])
signal deny_and_reply_slide(denied_index: Array[int], empty_index: Array[int])

signal request_immediately_move(target_index: Array[int], empty_index: Array[int])

func _ready() -> void:
	initialize_board()

func initialize_board() -> void:
	for y: int in range(height):
		var temp: Array[int] = []
		for x: int in range(width):
			temp.append( (x+width*y) + 1 ) # positive integer <- puzzle value
		board.append(temp)
	board[height-1][width-1] = 0 # 0 <- empty cell
	current_empty_index = [width-1, height-1]

func receive_request_slide(index_to_request: Array[int]) -> void:
	var x_r: int = index_to_request[0]
	var y_r: int = index_to_request[1]
	var x_e: int = current_empty_index[0]
	var y_e: int = current_empty_index[1]
	
	if (x_r == x_e+1 and y_r == y_e) \
	or (x_r == x_e and y_r == y_e-1) \
	or (x_r == x_e-1 and y_r == y_e) \
	or (x_r == x_e and y_r == y_e+1):
		var _current_empty_index: Array[int] = current_empty_index
		slide_cell(index_to_request)
		approve_and_reply_slide.emit(index_to_request, _current_empty_index)
	else:
		deny_and_reply_slide.emit(index_to_request, current_empty_index)

func slide_cell(index_to_slide: Array[int]) -> void:
	board[current_empty_index[1]][current_empty_index[0]] \
	= board[index_to_slide[1]][index_to_slide[0]]
	board[index_to_slide[1]][index_to_slide[0]] = 0
	
	current_empty_index = index_to_slide.duplicate(true)
