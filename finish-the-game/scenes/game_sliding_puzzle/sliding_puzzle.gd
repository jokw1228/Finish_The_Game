extends Node2D
class_name SlidingPuzzle

const width = 4
const height = 4

var board: Array = []
var current_empty_index: Array[int]

var cells: Array = []
const cell_image_size = 128.0 # pixel size

func _ready() -> void:
	initialize_board()

func initialize_board() -> void:
	for y: int in range(height):
		var temp: Array[int] = []
		for x: int in range(width):
			temp.append( (x+width*y) + 1 ) # positive integer <- puzzle value
		board.append(temp)
	board[height-1][width-1] = 0 # 0 <- empty cell
	current_empty_index = [height-1, width-1]
