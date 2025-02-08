extends Node2D
class_name RicochetRobotUI

signal request_generate_wall_to_board(board: Array[Array], board_size: int)
signal request_generate_goal_to_board(goal: Vector2, goal_color: int, board_size: int)
signal request_generate_robots_to_board(robot_location: Array[Vector2])

signal request_reset_ui_to_board()

signal request_cell_pressed_to_game(cell_index: Vector2)

signal request_move_robot_to_board(robot_to_move: RicochetRobot.COLOR, location_from: Vector2, location_to: Vector2)
signal deliver_move_finished_to_game()
signal deliver_disable_input(disable: bool)

func receive_request_generate_wall_ui(board, board_size) -> void:
	request_generate_wall_to_board.emit(board, board_size)

func receive_request_generate_goal_ui(goal, goal_color, board_size) -> void:
	request_generate_goal_to_board.emit(goal, goal_color, board_size)
	
func receive_request_generate_robots_ui(robot_location) -> void:
	request_generate_robots_to_board.emit(robot_location)
	
func receive_request_reset_ui() -> void:
	request_reset_ui_to_board.emit()

func receive_request_cell_pressed_to_ui(cell_index: Vector2) -> void:
	request_cell_pressed_to_game.emit(cell_index)
	
func receive_request_move_robot_ui(robot_to_move: RicochetRobot.COLOR, location_from: Vector2, location_to: Vector2) -> void:
	request_move_robot_to_board.emit(robot_to_move, location_from, location_to)

func receive_move_finished() -> void:
	deliver_move_finished_to_game.emit()
	
func receive_request_disable_input(disable: bool) -> void:
	deliver_disable_input.emit(disable)
