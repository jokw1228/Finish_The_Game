extends Node2D
class_name BombLink

const width = 4
const height = 10

var board: Array[Array] = []

func _ready() -> void:
	initialize_board()

func initialize_board() -> void:
	for y: int in range(height):
		var temp: Array[BombLinkBomb] = []
		for x: int in range(width):
			temp.append(null)
		board.append(temp)
