extends Node2D
class_name Orbito

const board_size = 4

var board: Array[Array] = []
var move_start_cell: Array[int] = []
var count_stone = 0

enum CELL_STATE
{
	EMPTY,
	BLACK,
	WHITE
}

enum TURN_STATE
{
	BLACK_MOVE,
	BLACK_PLACE,
	BLACK_ORBIT,
	WHITE_MOVE,
	WHITE_PLACE,
	WHITE_ORBIT
}
var turn_state: TURN_STATE = TURN_STATE.BLACK_PLACE

signal approve_and_reply_move_stone(approved_start_cell_index: Array[int], approved_end_cell_index: Array[int], approved_color: CELL_STATE)
signal deny_and_reply_move_stone(denied_start_cell_index: Array[int], denied_end_cell_index: Array[int])
signal approve_and_reply_place_stone(approved_cell_index: Array[int], approved_color: CELL_STATE)
signal deny_and_reply_place_stone(denied_cell_index: Array[int])
signal approve_and_reply_orbit_board()
signal approve_and_reply_do_not_move()
signal approve_and_reply_remove_stone(approved_cell_index: Array[int])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_board()
	
func initialize_board() -> void:
	for y: int in range(board_size):
		var temp: Array[CELL_STATE] = []
		for x: int in range(board_size):
			temp.append(CELL_STATE.EMPTY)
		board.append(temp)
		
func receive_select_stone(cell_index: Array[int]):
	var _x = cell_index[0]
	var _y = cell_index[1]
	
	# 돌 놓기
	if (turn_state == TURN_STATE.BLACK_PLACE or turn_state == TURN_STATE.WHITE_PLACE) \
	and (board[_y][_x] == CELL_STATE.EMPTY):
		var stone_to_place: CELL_STATE \
		= CELL_STATE.BLACK if turn_state == TURN_STATE.BLACK_PLACE else CELL_STATE.WHITE
		board[_y][_x] = stone_to_place
		increase_turn_state()
		approve_and_reply_place_stone.emit(cell_index, stone_to_place)
		
	# 돌 움직이기
	elif ((turn_state == TURN_STATE.BLACK_MOVE and board[_y][_x] == CELL_STATE.WHITE) or \
	(turn_state == TURN_STATE.WHITE_MOVE and board[_y][_x] == CELL_STATE.BLACK)) \
	and (move_start_cell == []):
		move_start_cell = [_x,_y]
	elif (turn_state == TURN_STATE.BLACK_MOVE or turn_state == TURN_STATE.WHITE_MOVE) \
	and (move_start_cell != []):
		var stone_to_move = board[move_start_cell[1]][move_start_cell[0]]
		var start_x = move_start_cell[0]
		var start_y = move_start_cell[1]
		if board[_y][_x] == CELL_STATE.EMPTY and \
		([start_x,start_y] == [_x+1,_y] or [start_x,start_y] == [_x-1,_y] or \
		[start_x,start_y] == [_x,_y+1] or [start_x,start_y] == [_x,_y-1]):
			board[_y][_x] = stone_to_move
			board[move_start_cell[1]][move_start_cell[0]] = CELL_STATE.EMPTY
			increase_turn_state()
			approve_and_reply_move_stone.emit(move_start_cell,cell_index,stone_to_move)
		move_start_cell = []
	
func receive_do_not_move():
	if (turn_state == TURN_STATE.BLACK_MOVE or turn_state == TURN_STATE.WHITE_MOVE):
		increase_turn_state()
		move_start_cell = []
		approve_and_reply_do_not_move.emit()
		
func receive_orbit_board():
	if (turn_state == TURN_STATE.BLACK_ORBIT or turn_state == TURN_STATE.WHITE_ORBIT):
		orbit_board()
		increase_turn_state()
		approve_and_reply_orbit_board.emit()
	
var orbited_board: Array[Array] = []
func orbit_board() -> void:
	var rotated_board: Array[Array] = board.duplicate(true)
	for y: int in range(board_size/2):
		for x: int in range(board_size):
			if (x < y):
				rotated_board[y][x] = board[y-1][x]
			elif (x >= board_size - 1 - y):
				rotated_board[y][x] = board[y+1][x]
			else:
				rotated_board[y][x] = board[y][x+1]
	for y: int in range(board_size/2,board_size):
		for x: int in range(board_size):
			if (x > y):
				rotated_board[y][x] = board[y+1][x]
			elif (x <= board_size - 1 - y):
				rotated_board[y][x] = board[y-1][x]
			else:
				rotated_board[y][x] = board[y][x-1]
	board = rotated_board
	replace_all_stones()
	orbited_board = rotated_board.duplicate(true)
	count_stone += 1
	
# 디버깅 용
'''
var time = 0
func _process(delta):
	time += delta
	if time > 1:
		time -= 1
		for y: int in range(4):
			print(board[y])
		print()
'''

func replace_all_stones():
	for y: int in range(board_size):
		for x: int in range(board_size):
			var cell: Array[int] = []
			cell.append(x)
			cell.append(y)
			if board[y][x] == CELL_STATE.EMPTY:
				approve_and_reply_remove_stone.emit(cell)
			elif board[y][x] == CELL_STATE.BLACK:
				approve_and_reply_remove_stone.emit(cell)
				approve_and_reply_place_stone.emit(cell,CELL_STATE.BLACK)
			elif board[y][x] == CELL_STATE.WHITE:
				approve_and_reply_remove_stone.emit(cell)
				approve_and_reply_place_stone.emit(cell,CELL_STATE.WHITE)
			
func increase_turn_state():
	if turn_state == TURN_STATE.BLACK_MOVE:
		turn_state = TURN_STATE.BLACK_PLACE
	elif turn_state == TURN_STATE.BLACK_PLACE:
		turn_state = TURN_STATE.BLACK_ORBIT
	elif turn_state == TURN_STATE.BLACK_ORBIT:
		turn_state = TURN_STATE.WHITE_MOVE
	elif turn_state == TURN_STATE.WHITE_MOVE:
		turn_state = TURN_STATE.WHITE_PLACE
	elif turn_state == TURN_STATE.WHITE_PLACE:
		turn_state = TURN_STATE.WHITE_ORBIT
	elif turn_state == TURN_STATE.WHITE_ORBIT:
		turn_state = TURN_STATE.BLACK_MOVE
	
	
