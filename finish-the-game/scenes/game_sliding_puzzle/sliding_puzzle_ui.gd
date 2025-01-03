extends Node2D
class_name SlidingPuzzleUI

const width = 4
const height = 4

var cells: Array = []
const cell_image_size = 128.0 # pixel size

func _ready() -> void:
	initialize_board_ui()

func initialize_board_ui() -> void:
	for y: int in range(height):
		var temp: Array[SlidingPuzzleCell] = []
		for x: int in range(width):
			if !(x == width-1 and y == height-1):
				var inst: SlidingPuzzleCell \
				= SlidingPuzzleCellCreator.create\
				(Vector2(\
				(x - float(width - 1.0) / 2.0) * cell_image_size, \
				(y - float(height - 1.0) / 2.0) * cell_image_size), \
				(x+width*y) + 1)
				temp.append(inst)
				add_child(inst)
		cells.append(temp)
