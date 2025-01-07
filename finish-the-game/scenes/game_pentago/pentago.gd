extends Node2D
class_name Pentago

const subboard_width = 3
const subboard_count_x = 2
const board_width = 6

var board: Array[Array] = []
# 0: empty, 1: black, 2: white
enum CELL_STATE
{
	EMPTY,
	BLACK,
	WHITE,
	BLOCKED # for generating FTG board
}

enum TURN_STATE
{
	BLACK_PLACE,
	BLACK_ROTATE,
	WHITE_PLACE,
	WHITE_ROTATE
}
var turn_state: TURN_STATE = TURN_STATE.BLACK_PLACE

enum ROTATION_DIRECTION
{
	CCW,
	CW
}

signal approve_and_reply_place_stone(approved_subboard_index: Array[int], approved_cell_index: Array[int], approved_color: CELL_STATE)
signal deny_and_reply_place_stone(denied_subboard_index: Array[int], denied_cell_index: Array[int])
signal approve_and_reply_rotate_subboard(approved_subboard_index: Array[int], approved_rotation_direction: ROTATION_DIRECTION)
signal deny_and_reply_rotate_subboard(denied_subboard_index: Array[int], denied_rotation_direction: ROTATION_DIRECTION)

func _ready() -> void:
	initialize_board()

func initialize_board() -> void:
	for y: int in range(board_width):
		var temp: Array[CELL_STATE] = []
		for x: int in range(board_width):
			temp.append(CELL_STATE.EMPTY)
		board.append(temp)

func receive_request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int]) -> void:
	var _x: int = requested_subboard_index[0]*subboard_width + requested_cell_index[0]
	var _y: int = requested_subboard_index[1]*subboard_width + requested_cell_index[1]
	if (board[_y][_x] == CELL_STATE.EMPTY) \
	and (turn_state == TURN_STATE.BLACK_PLACE or turn_state == TURN_STATE.WHITE_PLACE):
		var stone_to_place: CELL_STATE \
		= CELL_STATE.BLACK if turn_state == TURN_STATE.BLACK_PLACE \
		else CELL_STATE.WHITE
		# place the stone
		board[_y][_x] = stone_to_place
		increase_turn_state()
		approve_and_reply_place_stone.emit(requested_subboard_index, requested_cell_index, stone_to_place)
	else:
		deny_and_reply_place_stone.emit(requested_subboard_index, requested_cell_index)

func receive_request_rotate_subboard(requested_subboard_index: Array[int], requested_rotation_direction: ROTATION_DIRECTION) -> void:
	if turn_state == TURN_STATE.BLACK_ROTATE or turn_state == TURN_STATE.WHITE_ROTATE:
		# rotate the subboard
		rotate_subboard(requested_subboard_index, requested_rotation_direction)
		increase_turn_state()
		approve_and_reply_rotate_subboard.emit(requested_subboard_index, requested_rotation_direction)
	else:
		deny_and_reply_rotate_subboard.emit(requested_subboard_index, requested_rotation_direction)

func rotate_subboard(subboard_index_to_rotate: Array[int], rotation_direction_to_rotate: ROTATION_DIRECTION) -> void:
	var s_x: int = subboard_index_to_rotate[0]
	var s_y: int = subboard_index_to_rotate[1]
	
	var matrix_to_rotate: Array[Array] = []
	for y: int in range(subboard_width):
		var temp: Array[int] = []
		for x: int in range(subboard_width):
			temp.append(board[s_y*subboard_width + y][s_x*subboard_width + x])
		matrix_to_rotate.append(temp)
	
	var rotated_matrix: Array[Array] = \
	rotate_3x3_matrix_ccw(matrix_to_rotate) if rotation_direction_to_rotate == ROTATION_DIRECTION.CCW \
	else rotate_3x3_matrix_cw(matrix_to_rotate)
	
	for y: int in range(subboard_width):
		for x: int in range(subboard_width):
			board[s_y*subboard_width + y][s_x*subboard_width + x] = rotated_matrix[y][x]

func rotate_3x3_matrix_ccw(matrix_to_rotate: Array[Array]) -> Array[Array]:
	# New matrix initializaiton
	var matrix: Array[Array] = []
	for y: int in range(3):
		var temp: Array[int] = []
		for x: int in range(3):
			temp.append(0)
		matrix.append(temp)
	
	# Fill in the new cells
	for i: int in range(3):
		for j: int in range(3):
			matrix[3 - 1 - j][i] = matrix_to_rotate[i][j]
	
	# Return the rotated_matrix
	return matrix

func rotate_3x3_matrix_cw(matrix_to_rotate: Array[Array]) -> Array[Array]:
	# New matrix initializaiton
	var matrix: Array[Array] = []
	for y: int in range(3):
		var temp: Array[int] = []
		for x: int in range(3):
			temp.append(0)
		matrix.append(temp)
	
	# Fill in the new cells
	for i: int in range(3):
		for j: int in range(3):
			matrix[j][3 - 1 - i] = matrix_to_rotate[i][j]
	
	# Return the rotated_matrix
	return matrix

func increase_turn_state():
	if turn_state == TURN_STATE.BLACK_PLACE:
		turn_state = TURN_STATE.BLACK_ROTATE
	elif turn_state == TURN_STATE.BLACK_ROTATE:
		turn_state = TURN_STATE.WHITE_PLACE
	elif turn_state == TURN_STATE.WHITE_PLACE:
		turn_state = TURN_STATE.WHITE_ROTATE
	elif turn_state == TURN_STATE.WHITE_ROTATE:
		turn_state = TURN_STATE.BLACK_PLACE
