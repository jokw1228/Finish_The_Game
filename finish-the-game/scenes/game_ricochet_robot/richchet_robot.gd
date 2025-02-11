extends Node2D
class_name RicochetRobot

const board_size = 8

signal request_generate_wall_ui(board: Array[Array], board_size: int)
signal request_generate_goal_ui(goal: Vector2, goal_color: int, board_size: int)
signal request_generate_robots_ui(robot_location: Array[Vector2])

signal request_reset_ui()

signal request_move_robot_ui(robot_to_move: COLOR, location_from: Vector2, location_to: Vector2)
signal move_finished()
signal game_clear()

signal start_timer(duration: float)
signal pause_timer()
signal resume_timer()

enum WALL
{
	NORTH,
	WEST,
	SOUTH,
	EAST
}

enum COLOR
{
	RED,
	GREEN,
	BLUE,
	YELLOW,
	BLACK,
	NONE
}

enum TURN_STATE
{
	SELECT,
	MOVE
}
var turn_state: TURN_STATE = TURN_STATE.SELECT
var color_selected: COLOR = COLOR.NONE

var board = []
var goal: Vector2
var goal_color: int
var robot_location: Array[Vector2]

var test_robot_location: Array[Vector2] = [Vector2(0,0), Vector2(0,1), Vector2(0,2), Vector2(0,3), Vector2(0,4)]
	
var board_sample = [
	[[WALL.NORTH,WALL.WEST],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[WALL.SOUTH]],
	[[WALL.WEST],[],[],[],[],[],[WALL.EAST],[WALL.NORTH,WALL.WEST]],
	[]
]

var board_r1 = [
	[[WALL.NORTH,WALL.WEST],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH,WALL.EAST],[WALL.NORTH,WALL.WEST],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[WALL.SOUTH,WALL.EAST],[WALL.WEST],[]],
	[[WALL.WEST],[],[WALL.SOUTH],[],[],[WALL.NORTH],[],[]],
	[[WALL.WEST,WALL.SOUTH],[],[WALL.NORTH,WALL.EAST],[WALL.WEST],[],[],[],[]],
	[[WALL.NORTH,WALL.WEST],[WALL.SOUTH],[],[],[],[],[WALL.EAST],[WALL.WEST,WALL.SOUTH]],
	[[WALL.WEST,WALL.EAST],[WALL.NORTH,WALL.WEST],[],[],[],[],[],[WALL.NORTH,WALL.SOUTH]],
	[[WALL.WEST],[],[],[],[],[],[WALL.EAST],[WALL.NORTH,WALL.WEST]],
	[Vector2(7,5),Vector2(2,4),Vector2(5,2),Vector2(1,6)]
]

var board_g1 = [
	[[WALL.NORTH,WALL.WEST],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH,WALL.EAST],[WALL.NORTH,WALL.WEST],[WALL.NORTH],[WALL.NORTH]],
	[[WALL.WEST],[WALL.SOUTH],[],[],[],[],[WALL.SOUTH,WALL.EAST],[WALL.WEST]],
	[[WALL.WEST,WALL.EAST],[WALL.WEST,WALL.NORTH],[],[],[],[],[WALL.NORTH],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[WALL.SOUTH],[]],
	[[WALL.WEST,WALL.SOUTH],[],[],[],[],[],[WALL.NORTH,WALL.EAST],[WALL.WEST]],
	[[WALL.NORTH,WALL.WEST],[],[WALL.EAST],[WALL.WEST,WALL.SOUTH],[],[],[],[WALL.SOUTH]],
	[[WALL.WEST],[],[],[WALL.NORTH],[],[],[WALL.EAST],[WALL.NORTH,WALL.WEST]],
	[Vector2(3,6),Vector2(1,2),Vector2(6,5),Vector2(6,1)]
]

var board_b1 = [
	[[WALL.NORTH,WALL.WEST],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH],[WALL.NORTH]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[]],
	[[WALL.WEST],[],[],[],[],[],[],[WALL.SOUTH]],
	[[WALL.WEST],[],[],[],[],[],[WALL.EAST],[WALL.NORTH,WALL.WEST]],
	[]
]

var red_boards = [board_r1]
var green_boards = [board_g1]
var board_list = [red_boards, green_boards]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_board()
	robot_location = test_robot_location
	request_generate_wall_ui.emit(board,board_size)
	request_generate_goal_ui.emit(goal,goal_color,board_size)
	request_generate_robots_ui.emit(robot_location)

func initialize_board():
	if board_size == 8:
		board_list.shuffle()
		var board_list_random_selected = board_list[0]
		board_list_random_selected.shuffle()
		board = board_list_random_selected[0]
		for y in range(board_size):
			for x in range(board_size):
				if y == 7:
					board[y][x].append(WALL.SOUTH)
				if x == 7:
					board[y][x].append(WALL.EAST)
		goal_color = randi() % 4
		goal = board[8][goal_color]
		return
	elif board_size == 16:
		pass #추후에 구현할 큰 보드의 리코셰로봇
		
func reset_board(new_robot_location: Array[Vector2]):
	request_reset_ui.emit()
	#initialize_board()
	turn_state = TURN_STATE.SELECT
	color_selected = COLOR.NONE
	robot_location = new_robot_location
	request_generate_wall_ui.emit(board,board_size)
	request_generate_goal_ui.emit(goal,goal_color,board_size)
	request_generate_robots_ui.emit(robot_location)

func receive_request_cell_pressed(cell_index: Vector2) -> void:
	#print(robot_location)
	var loc: int = robot_location.find(cell_index)
	if turn_state == TURN_STATE.MOVE:
		if loc != -1:
			if int_to_color(loc) == color_selected:
				increase_turn_state()
				color_selected = COLOR.NONE
			else:
				$RicochetRobotUI.receive_select_robot()
				color_selected = int_to_color(loc)
		else:
			var to_move = check_movement(color_selected, cell_index)
			if to_move != Vector2(-1,-1):
				pause_timer.emit()
				request_move_robot_ui.emit(color_selected, robot_location[int(color_selected)], to_move)
				robot_location[int(color_selected)] = to_move
				await move_finished
				resume_timer.emit()
				if robot_location[int(color_selected)] == goal and color_selected == goal_color:
					#print("Congrats!")
					game_clear.emit()
					#initialize_board()
					#reset_board(test_robot_location)
					#print("Board Reseted!")
			else:
				increase_turn_state()
				color_selected = COLOR.NONE
	elif turn_state == TURN_STATE.SELECT:
		if loc == -1:
			pass
		else:
			$RicochetRobotUI.receive_select_robot()
			color_selected = int_to_color(loc)
			increase_turn_state()
	return

func increase_turn_state() -> void:
	if turn_state == TURN_STATE.SELECT:
		turn_state = TURN_STATE.MOVE
		return
	elif turn_state == TURN_STATE.MOVE:
		turn_state = TURN_STATE.SELECT
		return

func check_movement(color: COLOR, cell_index) -> Vector2:
	var false_movement: Vector2 = Vector2(-1,-1)
	var robot_loc: Vector2 = robot_location[int(color)]
	if robot_loc[0] != cell_index[0] and robot_loc[1] != cell_index[1]:
		return false_movement
	else:
		if robot_loc[0] < cell_index[0]:
			if WALL.EAST not in board[robot_loc[1]][robot_loc[0]]:
				robot_loc[0] += 1
				while WALL.EAST not in board[robot_loc[1]][robot_loc[0]] and not robot_collision(robot_loc + Vector2(1, 0)):
					robot_loc[0] += 1
				return robot_loc
			else:
				return false_movement
		elif robot_loc[0] > cell_index[0]:
			if WALL.WEST not in board[robot_loc[1]][robot_loc[0]]:
				robot_loc[0] -= 1
				while WALL.WEST not in board[robot_loc[1]][robot_loc[0]] and not robot_collision(robot_loc + Vector2(-1, 0)):
					robot_loc[0] -= 1
				return robot_loc
			else:
				return false_movement
		elif robot_loc[1] < cell_index[1]:
			if WALL.SOUTH not in board[robot_loc[1]][robot_loc[0]]:
				robot_loc[1] += 1
				while WALL.SOUTH not in board[robot_loc[1]][robot_loc[0]] and not robot_collision(robot_loc + Vector2(0, 1)):
					robot_loc[1] += 1
				return robot_loc
			else:
				return false_movement
		elif robot_loc[1] > cell_index[1]:
			if WALL.NORTH not in board[robot_loc[1]][robot_loc[0]]:
				robot_loc[1] -= 1
				while WALL.NORTH not in board[robot_loc[1]][robot_loc[0]] and not robot_collision(robot_loc + Vector2(0, -1)):
					robot_loc[1] -= 1
				return robot_loc
			else:
				return false_movement
	return false_movement
	
func robot_collision(location: Vector2) -> bool:
	for item in robot_location:
		if item == location:
			return true
		else:
			pass
	return false
	
func int_to_color(integer: int) -> COLOR:
	match integer:
		0:
			return COLOR.RED
		1:
			return COLOR.GREEN
		2:
			return COLOR.BLUE
		3:
			return COLOR.YELLOW
		4:
			return COLOR.BLACK
		_:
			return COLOR.NONE
	return COLOR.NONE

func receive_move_finished() -> void:
	move_finished.emit()
