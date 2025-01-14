extends Node2D
class_name RushHour

@export var player_scene: PackedScene
@export var truck_scene: PackedScene

const board_size = 6
const cell_size = 128
# 0 = empty
# 1 = player
# 2 = truck2
# 3 = truck3

var board  = []
var state : bool #selecting  confirming the move
var selected_piece : Node = null #position of selected piece

#const tiles = preload("res://game_rush_hour_board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	create_grid()
	place_pieces()

func create_grid():
	for x in range(board_size):
		for y in range(board_size):
			board.append([0, 0, 0, 2, 0, 3])
			board.append([0, 0, 0, 2, 0, 3])
			board.append([1, 1, 0, 0, 0, 3])
			board.append([0, 0, 0, 0, 0, 0])
			board.append([0, 0, 0, 2, 2, 0])
			board.append([0, 0, 0, 0, 0, 0])
			
			
	
func is_horizontal(row, col,value):
	return col +1 < len(board[row]) and board[row][col+1] == value
	
func is_vertical(row, col,value):
	return row +1 < len(board) and board[row+1][col] == value
	
func place_piece(cell, row, col, horizontal):
	var piece
	if cell == 1:
		piece = player_scene.instantiate()
	else:
		piece = truck_scene.instantiate()
		if cell == 2:
			piece.truck_type = 1
		else:
			piece.truck_type = 2
			
	piece.position = Vector2(col * cell_size, row * cell_size)
	
	
	if horizontal:
		piece.direction = 0
	else:
		piece.direction = 1
	add_child(piece)

#
	
func mark_pos(row, col, value, horizontal, checked_pos):
	if horizontal:
		while col < len(board[row]) and board[row][col] == value:
			checked_pos.append(Vector2(row, col))
			col += 1
	else:
		while row < len(board) and board[row][col] == value:
			checked_pos.append(Vector2(row, col))
			row += 1

func place_pieces():
	var checked_pos = []
	for row in range(board_size):
		for col in range(board_size):
			var cell = board[row][col]
			if cell != 0 and Vector2(row, col) not in checked_pos:
				if is_horizontal(row, col, cell):
					place_piece(cell, row, col, true)
					mark_pos(row, col,cell, true, checked_pos)
				elif is_vertical(row, col, cell):
					place_piece(cell, row, col,false)
					mark_pos(row, col, cell, false, checked_pos)
					
