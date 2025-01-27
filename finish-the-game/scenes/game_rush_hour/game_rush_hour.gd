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
var player_direction = 0
var checked_pos = []
var piece_list = []
signal start(value: Vector2)



signal player_piece_instantiated(player_piece)

# Called when the node enters the scene tree for the first time.
func _ready():
	select_grid()
	place_pieces()
	const duration = 10.0
	start_timer.emit(duration)
	start.emit(target_location, player_direction)
	#print(piece_list)
	#print_board(board)
	
func start_ftg():
	print("start ftg")
	
	
func _process(delta):
	#debugging
	#var pos = get_viewport().get_mouse_position()
	#print("Mouse po: ", pos)
	if flag == 0 and player_piece and player_piece.cell_loc == target_location:
		pause_timer.emit()
		end_ftg.emit(true)
		flag = 1
	
	_update_board(board)
	#print_board(board)

		#print("ftg")
func _update_board(board):
	for i in range(board_size):
		for j in range(board_size):
			board[i][j] = 0
	var cell = Vector2(0,0)
	var offset = Vector2(0,64)
	var temp 
	for piece in piece_list:
		#print(piece)
		var board_start = Vector2(-226-128, -256-64)
		#var board_finish = Vector2(286+128, 384+64)
		if piece.piece_type == "truck2":
			offset.x = 128*3/2
			if piece.direction == 0:
				#find col
				cell.x = round( (piece.position.x - board_start.x+offset.x*0.7)/cell_size)-1
				if cell.x < 0: cell.x = 0
				elif cell.x > 5: cell.x = 5
				board[piece.cell_loc.y][cell.x] = 3
				board[piece.cell_loc.y][cell.x-1] = 3
				board[piece.cell_loc.y][cell.x-2] = 3
				piece.cell_loc.x = cell.x
			else:
				temp = offset.x
				offset.x = offset.y
				offset.y = temp
				cell.y = round( (piece.position.y - board_start.y-offset.y*0.7)/cell_size)-1
				if cell.y < 0: cell.y = 0
				elif cell.y > 5: cell.y = 5
				board[cell.y][piece.cell_loc.x] = 3
				board[cell.y-1][piece.cell_loc.x] = 3
				board[cell.y-2][piece.cell_loc.x] = 3
				piece.cell_loc.y = cell.y
			
		else:
			offset.x = 128
			if piece.direction == 0:
				#find col
				cell.x = round( (piece.position.x - board_start.x+offset.x*0.7)/cell_size)-1
				#print(cell.x)
				if cell.x < 0: cell.x = 0
				elif cell.x > 5: cell.x = 5
				if piece.piece_type == "truck1":
					board[piece.cell_loc.y][cell.x] = 2
					board[piece.cell_loc.y][cell.x-1] = 2
				else:
					board[piece.cell_loc.y][cell.x] = 1
					board[piece.cell_loc.y][cell.x-1] = 1
				piece.cell_loc.x = cell.x
			else:
				temp = offset.x
				offset.x = offset.y
				offset.y = temp
				cell.y = round( (piece.position.y - board_start.y-offset.y*0.003)/cell_size)-1
				if cell.y < 0: cell.y = 0
				elif cell.y > 5: cell.y = 5
				if piece.piece_type == "truck1":
					board[cell.y][piece.cell_loc.x] = 2
					board[cell.y-1][piece.cell_loc.x] = 2
				else:
					board[cell.y][piece.cell_loc.x]  = 1
					board[cell.y-1][piece.cell_loc.x] = 1
				piece.cell_loc.y = cell.y

func print_board(board):
	for k in board:
		print(k)
	print("")
			
			
func select_grid():
	var board1 = [[0, 0, 0, 0, 0, 3],
				 [0, 0, 2, 0, 3, 3],
				 [1, 1, 2, 0, 3, 3],
				 [0, 0, 0, 0, 3, 0],
				 [0, 0, 0, 0, 2, 2],
				 [0, 2, 2, 0, 0, 0]]
	var board2 = [[0, 0, 0, 0, 0, 0],
				[0, 0, 0, 0, 0, 0],
				[0, 0, 0, 2, 0, 0],
				[1, 1, 0, 2, 0, 0],
				[0, 3, 3,3 , 2, 0],
				[0, 0, 0, 0, 2, 0]]
	var board3 = [[0, 0, 0, 0, 0, 0],
				[0, 0, 0, 3, 0, 0],
				[0, 0, 0, 3, 0, 0],
				[0, 0, 2, 3, 2, 0],
				[1, 1, 2, 0, 2, 0],
				[0, 0, 0, 0, 0, 0]]
	var board4 = [[3, 3, 3, 0, 2, 0],
				 [0, 0, 0, 0, 2, 3],
				 [0, 3, 3, 3, 0, 3],
				 [0, 0, 1, 0, 0, 3],
				 [2, 0, 1, 0, 0, 0],
				 [2, 3, 3, 3, 2, 2]]
	var board5 = [[0, 3, 3, 3, 0, 0],
				 [0, 0, 0, 0, 0, 3],
				 [0, 0, 0, 0, 0, 3],
				 [0, 0, 0, 1, 0, 3],
				 [2, 0, 0, 1, 0, 0],
				 [2, 3, 3, 3, 2, 2]]
	var board6 = [[0, 3, 3, 3, 2, 0],
				 [0, 0, 2, 2, 2, 3],
				 [0, 2, 3, 3, 3, 3],
				 [0, 2, 0, 0, 0, 3],
				 [0, 0, 0, 1, 0, 0],
				 [0, 0, 0, 1, 2, 2]]
	var test1 = [[2, 0, 0, 0, 0, 2],
				 [2, 0, 2, 0, 0, 2],
				 [0, 0, 2, 0, 0, 0],
				 [0, 0, 0, 0, 0, 0],
				 [2, 0, 0, 0, 0, 2],
				 [2, 0, 0, 0, 0, 2]]
	var test2 = [[2, 2, 0, 0, 2, 2],
				 [0, 0, 2, 0, 0, 0],
				 [0, 0, 2, 0, 0, 0],
				 [0, 0, 0, 0, 2, 0],
				 [0, 0, 0, 0, 2, 0],
				 [2, 2, 0, 0, 2, 2]]
				
	var test3 = [[3, 0, 0, 0, 0, 3],
				 [3, 0, 2, 3, 3, 3],
				 [3, 0, 2, 0, 0, 3],
				 [0, 0, 0, 0, 0, 0],
				 [3, 3, 3, 0, 0, 0],
				 [0, 0, 0, 3, 3, 3]]
	var test4 = [[3, 3, 3, 0, 0, 3],
				 [3, 3, 3, 0, 0, 3],
				 [3, 3, 3, 0, 0, 3],
				 [0, 0, 0, 0, 1, 0],
				 [3, 3, 3, 0, 1, 0],
				 [0, 0, 0, 3, 3, 3]]
				
	#Vector2(col,row)			
	var arr = [board1, board2, board3, board4, board5, board6]
	var selected_array = randi() % arr.size()
	board = arr[selected_array]
	find_target_location()
	#for debugging:
	#board = board5
	#target_location =  Vector2(3, 0)
	
#exit is always at top or left side of board
func find_target_location():
	for row in board_size:
		for col in board_size:
			if board[row][col] == 1:
				if is_horizontal(row, col,1):
					target_location = Vector2(5,row)
					player_direction = 0
				elif is_vertical(row, col,1):
					target_location = Vector2(col,0)
					player_direction = 1
					
				
	
func is_horizontal(row, col,value):
	if value == 3:
		for i in range(3):
			if Vector2(row, col+i) in checked_pos:
				return false
		return  col +1 < len(board[row]) and board[row][col+1] == value and (col +2 < len(board[row]) and board[row][col+2] == value)
	if value == 2:
		for j in range(2):
			if Vector2(row, col+j) in checked_pos:
				return false
	return col +1 < len(board[row]) and board[row][col+1] == value
	
func is_vertical(row, col,value):
	if value == 3:
		for i in range(3):
			if Vector2(row+i, col) in checked_pos:
				return false
		return  row +1 < len(board[row]) and board[row+1][col] == value and (row +2 < len(board[row]) and board[row+2][col] == value)
	if value == 2:
		for j in range(2):
			if Vector2(row+j, col) in checked_pos:
				return false
	return row +1 < len(board) and board[row+1][col] == value
	
func place_piece(cell, row, col, horizontal):
	var piece
	#place player piece
	
	if cell == 1:
		piece = player_scene.instantiate()
		player_piece = piece 
		var half = cell_size/2
		if horizontal:
			piece.direction = 0
			
			piece.position =  start_position+  Vector2(col * cell_size+64, row * cell_size+64)
		
		else:
			piece.direction = 1
		
			piece.position = start_position +  Vector2(col * cell_size, row * cell_size+128)

	else:
		piece = truck_scene.instantiate()
		#truck type one
		if cell == 2:
			piece.piece_type = "truck1"
			piece.truck_type = 1
			if horizontal:
				piece.direction = 0
				piece.position =  start_position+ Vector2((col) * cell_size+64, (row) * cell_size+64)
			else:
				piece.direction = 1
				piece.position = start_position + Vector2((col) * cell_size, (row) * cell_size+128)
			
		#truck type 2
		else:
			piece.piece_type = "truck2"
			piece.truck_type = 2
			if horizontal:
				piece.direction = 0
				piece.position =  start_position+ Vector2(col * cell_size+128, row * cell_size+64)
			else:
				piece.direction = 1
				piece.position = start_position + Vector2(col * cell_size, row * cell_size+128+64)
	
	piece.cell_loc = Vector2(col,row) # save as x and y
	add_child(piece)		
	if cell == 1:
		piece.piece_type = "player"
		player_piece = piece 
	piece_list.append(piece)
	
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
	if not flag:
		end_ftg.emit(false)
		flag = 2
