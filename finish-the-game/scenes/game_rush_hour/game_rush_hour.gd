extends Node2D
class_name RushHour

@export var player_scene: PackedScene
@export var truck_scene: PackedScene

var mouse_sprite: Sprite2D 

signal start_timer(duration: float)
signal pause_timer()

const board_size = 6
const cell_size = 128
var flag = 0

# 0 = empty
# 1 = player
# 2 = truck2
# 3 = truck3
var player_piece = null
var board  = []
var state : bool #selecting  confirming the move
var selected_piece : Node = null #position of selected piece
var mouse_offset  = Vector2(0,0)
signal end_ftg(game_cleard: bool)
var target_location = Vector2(288, 0) 
var threshold = 20
var grid_width = board_size * cell_size
var grid_height = board_size * cell_size
var viewport_size = get_viewport_rect().size
#var start_position = Vector2(
#(viewport_size.x - grid_width/4-256) / 2,
#(viewport_size.y - grid_height/4-320) / 2)
var start_position = Vector2(-320+30,-320)




signal player_piece_instantiated(player_piece)
#const tiles = preload("res://game_rush_hour_board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	select_grid()
	place_pieces()
	mouse_sprite = Sprite2D.new()
	mouse_sprite.texture = preload("res://resources/images/game_rush_hour/sprite_rush_hour_truck_type1.png") 
	const duration = 10.0
	start_timer.emit(duration)
	#add_child(mouse_sprite)
	print( get_viewport().size)
func start_ftg():
	print("start ftg")
	
	
func _process(delta):
	#debugging
	var pos = get_viewport().get_mouse_position()
	#print("Mouse po: ", pos)
	if not flag and player_piece and player_piece.position.distance_to(target_location) < threshold:
		end_ftg.emit(true)
		pause_timer.emit()
		flag = 1
	
		#print("ftg")
#func _update_board():
	

func create_grid():
	for x in range(board_size):
		for y in range(board_size):
			board.append([0, 0, 0, 2, 0, 0])
			board.append([0, 0, 0, 2, 0, 2])
			board.append([1, 1, 0, 0, 0, 2])
			board.append([0, 0, 0, 0, 0, 0])
			board.append([0, 0, 0, 2, 2, 0])
			board.append([0, 0, 0, 0, 0, 0])
			
			
func select_grid():
	var board1 = [[0, 0, 0, 0, 0, 3],
				 [0, 0, 2, 0, 3, 3],
				 [1, 1, 2, 0, 3, 3],
				 [0, 0, 0, 0, 3, 0],
				 [0, 0, 0, 0, 2, 2],
				 [0, 2, 2, 0, 0, 0]]
	var board2 = [[0, 0, 0, 0, 0, 0],
				[0, 0, 0, 2, 0, 0],
				[1, 1, 0, 2, 0, 0],
				[0, 0, 0, 0, 0, 0],
				[0, 3, 3,3 , 2, 0],
				[0, 0, 0, 0, 2, 0]]
	var board3 = [[0, 0, 0, 0, 0, 0],
				[0, 0, 0, 3, 0, 0],
				[0, 0, 0, 3, 0, 0],
				[1, 1, 2, 3, 0, 0],
				[0, 0, 2, 2, 2, 0],
				[0, 0, 0, 0, 0, 0]]
	var board4 = [[3, 3, 3, 0, 2, 0],
				 [0, 0, 0, 0, 2, 3],
				 [0, 3, 3, 3, 0, 3],
				 [0, 0, 1, 0, 0, 3],
				 [2, 0, 1, 0, 0, 0],
				 [2, 3, 3, 3, 2, 2]]
	var board5 = [[3, 3, 3, 0, 2, 0],
				 [0, 0, 0, 0, 2, 3],
				 [0, 0, 0, 0, 0, 3],
				 [0, 0, 1, 0, 0, 3],
				 [2, 0, 1, 0, 0, 0],
				 [2, 3, 3, 3, 2, 2]]
	var board6 = [[0, 3, 3, 3, 2, 0],
				 [0, 0, 2, 2, 2, 3],
				 [0, 2, 3, 3, 3, 3],
				 [0, 2, 0, 0, 0, 3],
				 [0, 0, 0, 1, 0, 0],
				 [0, 0, 0, 1, 2, 2]]
	var arr = [[board1, Vector2(288, 0)], [board2, Vector2(288, 0)], [board3, Vector2(288, 128)], [board4, Vector2(-34, -48*4)], [board5, Vector2(-34, -48*4)], [board6, Vector2(94, -48*4)]]
	
	var selected_array = arr[randi() % arr.size()]
	board = selected_array[0]
	target_location = selected_array[1]
	#board = board8
	#target_location =  Vector2(94, -48*4)
	
func is_horizontal(row, col,value):
	if value == 3:
		return  col +1 < len(board[row]) and board[row][col+1] == value and (col +2 < len(board[row]) and board[row][col+2] == value)
	return col +1 < len(board[row]) and board[row][col+1] == value
	
func is_vertical(row, col,value):
	if value == 3:
		return  row +1 < len(board[row]) and board[row+1][col] == value and (row +2 < len(board[row]) and board[row+2][col] == value)
	return row +1 < len(board) and board[row+1][col] == value
	
func place_piece(cell, row, col, horizontal):
	var piece
	#place player piece
	if cell == 1:
		piece = player_scene.instantiate()
		player_piece = piece 
		#emit_signal("player_piece_instantiated", player_piece)
		#print("player_piece initialized:", player_piece)
		var half = cell_size/2
		if horizontal:
			piece.direction = 0
			
			piece.position =  start_position+  Vector2(col * cell_size+64, row * cell_size+64)
		
		else:
			piece.direction = 1
		
			piece.position = start_position +  Vector2(col * cell_size, row * cell_size+128)
			
			#print(col, row, position)
			#(540, -1375)
			#(540, 785)
			
	else:
		piece = truck_scene.instantiate()
		#truck type one
		if cell == 2:
			piece.truck_type = 1
			if horizontal:
				piece.direction = 0
				piece.position =  start_position+ Vector2((col) * cell_size+64, (row) * cell_size+64)
			else:
				piece.direction = 1
				piece.position = start_position + Vector2((col) * cell_size, (row) * cell_size+128)
			
		#truck type 2
		else:
			piece.truck_type = 2
			if horizontal:
				piece.direction = 0
				piece.position =  start_position+ Vector2(col * cell_size+128, row * cell_size+64)
			else:
				piece.direction = 1
				piece.position = start_position + Vector2(col * cell_size, row * cell_size+128+64)
	add_child(piece)		
	if cell == 1:
		player_piece = piece 
	
func mark_pos(row, col, value, horizontal, checked_pos):
	var i = 0
	if value == 3:
		i = 3
	else:
		i = 2
	if horizontal:
		while col < len(board[row]) and board[row][col] == value and i >0:
			checked_pos.append(Vector2(row, col))
			col += 1
			i-=1
	else:
		while row < len(board) and board[row][col] == value and i >0:
			checked_pos.append(Vector2(row, col))
			row += 1
			i-=1

func place_pieces():
	var checked_pos = []
	for row in range(board_size):
		for col in range(board_size):
			var cell = board[row][col]
			if cell != 0 and Vector2(row, col) not in checked_pos:
				if is_horizontal(row, col, cell):
					#print("HOrizontal Row and col: ",row," ", col)
					place_piece(cell, row, col, true)
					mark_pos(row, col,cell, true, checked_pos)
				elif is_vertical(row, col, cell):
					#print("Vertifcal Row and col: ",row," ", col)
					place_piece(cell, row, col,false)
					mark_pos(row, col, cell, false, checked_pos)
					
func get_player_position(target_location):
	return player_piece.position.distance_to(target_location)

func _on_game_utils_game_timer_timeout() -> void:
	end_ftg.emit(false)
