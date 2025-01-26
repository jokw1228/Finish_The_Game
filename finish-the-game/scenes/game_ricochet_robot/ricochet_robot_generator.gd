extends Node
class_name RicochetRobotGenerator

const ricochet_robot_wall_scene = "res://scenes/game_ricochet_robot/ricochet_robot_wall.tscn"
static func generate_wall(location, direction) -> RicochetRobotWall:
	var inst: RicochetRobotWall = preload(ricochet_robot_wall_scene).instantiate() as RicochetRobotWall
	inst.position = Vector2(location[0] + (int(direction) - 2) * 32 * (int(direction)%2), location[1] + (int(direction) - 1) * 32 * ((int(direction)+1)%2))
	inst.rotation = (PI/2 * int(direction))
	return inst


const ricochet_robot_goal_scene = "res://scenes/game_ricochet_robot/ricochet_robot_goal.tscn"
static func generate_goal(goal, goal_color) -> RicochetRobotGoal:
	var inst: RicochetRobotGoal = preload(ricochet_robot_goal_scene).instantiate() as RicochetRobotGoal
	inst.position = goal
	match goal_color:
		int(RicochetRobot.COLOR.RED):
			inst.texture = inst.goal_red
		int(RicochetRobot.COLOR.GREEN):
			inst.texture = inst.goal_green
		int(RicochetRobot.COLOR.BLUE):
			inst.texture = inst.goal_blue
		int(RicochetRobot.COLOR.YELLOW):
			inst.texture = inst.goal_yellow
		int(RicochetRobot.COLOR.BLACK):
			inst.texture = inst.goal_black
		_:
			pass
	return inst

const ricochet_robot_cell_scene = "res://scenes/game_ricochet_robot/ricochet_robot_cell.tscn"
static func generate_cell(cell_index: Vector2) -> RicochetRobotCell:
	var inst: RicochetRobotCell = preload(ricochet_robot_cell_scene).instantiate() as RicochetRobotCell
	inst.cell_index = cell_index
	inst.scale = Vector2(0.5,0.5)
	return inst

const ricochet_robot_robot_scene = "res://scenes/game_ricochet_robot/ricochet_robot_robot.tscn"
static func generate_robot(location: Vector2, index: int) -> RicochetRobotRobot:
	var inst: RicochetRobotRobot = preload(ricochet_robot_robot_scene).instantiate() as RicochetRobotRobot
	match index:
		int(RicochetRobot.COLOR.RED):
			inst.texture = inst.robot_red
		int(RicochetRobot.COLOR.GREEN):
			inst.texture = inst.robot_green
		int(RicochetRobot.COLOR.BLUE):
			inst.texture = inst.robot_blue
		int(RicochetRobot.COLOR.YELLOW):
			inst.texture = inst.robot_yellow
		int(RicochetRobot.COLOR.BLACK):
			inst.texture = inst.robot_black
	inst.position = location
	return inst
