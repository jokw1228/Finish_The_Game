extends Node2D
class_name PentagoBoard

const cell_image_size = 128.0 # pixel size

var board_size: int = 2
var subboard_size: int = 3

var subboards: Array = []

func _ready() -> void:
	set_board()

func set_board() -> void:
	var subboard_pixel_size: float = subboard_size * cell_image_size
	for i in range(board_size):
		var temp: Array[PentagoSubBoard] = []
		for j in range(board_size):
			var inst: PentagoSubBoard \
			= PentagoSubBoardCreator.create\
			(Vector2((i - float(board_size - 1.0) / 2.0) * subboard_pixel_size, \
			(j - float(board_size - 1.0) / 2.0) * subboard_pixel_size), \
			subboard_size)
			temp.append(inst)
			add_child(inst)
		subboards.append(temp)
