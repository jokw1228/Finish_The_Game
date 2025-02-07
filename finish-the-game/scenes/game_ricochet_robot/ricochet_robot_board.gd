extends Sprite2D
class_name RicochetRobotBoard

const board_size: int = 8
const cell_size: int = 64

signal request_cell_pressed_to_ui(cell_index: Vector2)
signal move_finished()

var robots: Array[RicochetRobotRobot] = []

func _ready() -> void:
	$GridContainer.columns = board_size
	for y in range(board_size):
		for x in range(board_size):
			generate_cell(Vector2(x,y))
	pass
	
func generate_cell(cell_index) -> void:
	var cell_inst = RicochetRobotGenerator.generate_cell(cell_index)
	$GridContainer.add_child(cell_inst)
	cell_inst.connect("request_cell_pressed",receive_request_cell_pressed)
	return

func receive_request_generate_wall(board, board_size: int) -> void:
	for y in range(board_size):
		for x in range(board_size):
			if RicochetRobot.WALL.NORTH in board[y][x]:
				generate_wall([x,y], RicochetRobot.WALL.NORTH, board_size)
			if RicochetRobot.WALL.WEST in board[y][x]:
				generate_wall([x,y], RicochetRobot.WALL.WEST, board_size)
			if y == board_size - 1:
				generate_wall([x,y], RicochetRobot.WALL.SOUTH, board_size)
			if x == board_size - 1:
				generate_wall([x,y], RicochetRobot.WALL.EAST, board_size)
	return
	
func generate_wall(coords, direction, board_size) -> void:
	add_child(RicochetRobotGenerator.generate_wall([-board_size * (cell_size/2) + (cell_size/2) + coords[0] * cell_size, -board_size * (cell_size/2) + (cell_size/2) + coords[1] * cell_size],direction))
	return
	
func receive_request_generate_goal(goal, goal_color, board_size) -> void:
	add_child(RicochetRobotGenerator.generate_goal(Vector2(-board_size * (cell_size/2) + cell_size * goal[0],-board_size * (cell_size/2) + cell_size * goal[1]),goal_color))
	return

func receive_request_generate_robots(robot_location: Array[Vector2]) -> void:
	for i: int in range(robot_location.size()):
		var _x: int = robot_location[i][0]
		var _y: int = robot_location[i][1]
		var robot: RicochetRobotRobot = RicochetRobotGenerator.generate_robot(Vector2(-board_size * (cell_size/2) + 64 * _x, -board_size * (cell_size/2) + 64 * _y),i)
		add_child(robot)
		robots.append(robot)
	return
	
func receive_request_reset_ui() -> void:
	var children = self.get_children()
	for child in children:
		if child != $GridContainer:
			self.remove_child(child)
			child.queue_free()
	robots = []
	return

func receive_request_cell_pressed(cell_index: Vector2) -> void:
	request_cell_pressed_to_ui.emit(cell_index)
	pass

func receive_move_robot(robot_to_move: RicochetRobot.COLOR, location_from: Vector2, location_to: Vector2) -> void:
	var cells = $GridContainer.get_children()
	var target: RicochetRobotRobot = robots[int(robot_to_move)]
	var tween: Tween = get_tree().create_tween()
	for child: RicochetRobotCell in cells:
		child.disabled = true
	#var mx = max(abs(location_from[0]-location_to[0]), abs(location_from[1]-location_to[1]))
	tween.tween_property(target,"position",target.position + (location_to - location_from) * 64, 0.1).from_current()
	await tween.finished
	for child: RicochetRobotCell in cells:
		child.disabled = false
	move_finished.emit()
	return

func receive_disable_input(disable: bool) -> void:
	var cells = $GridContainer.get_children()
	for child: RicochetRobotCell in cells:
		child.disabled = disable
	return
