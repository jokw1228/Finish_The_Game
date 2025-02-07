extends RicochetRobot
class_name FTGRicochetRobot

signal request_disable_input(disable)
signal end_ftg(is_game_cleared: bool)


var impossible_location: Array[Vector2] = [Vector2(7,7),Vector2(7,8),Vector2(8,7),Vector2(8,8)]
var new_robot_location: Array[Vector2] = []

func start_ftg() -> void:
	impossible_location = [Vector2(7,7),Vector2(7,8),Vector2(8,7),Vector2(8,8)]
	initialize_board()
	impossible_location.append(goal)
	new_robot_location = []
	for i in range(robot_location.size()):
		var _x = randi() % board_size
		var _y = randi() % board_size
		if Vector2(_x,_y) not in impossible_location:
			impossible_location.append(Vector2(_x,_y))
			new_robot_location.append(Vector2(_x,_y))
	robot_location = new_robot_location.duplicate(true)
	reset_board(robot_location)
	#print(board)
	#print(robot_location)
	var duration = 12
	start_timer.emit(duration)

func game_cleared() -> void:
	request_disable_input.emit(true)
	pause_timer.emit()
	end_ftg.emit(true)
	return
	
func _on_game_utils_game_timer_timeout() -> void:
	request_disable_input.emit(true)
	end_ftg.emit(false)
	return
