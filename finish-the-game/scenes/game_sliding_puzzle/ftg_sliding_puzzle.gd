extends SlidingPuzzle
class_name FTGSlidingPuzzle

signal request_disable_input()
signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

func start_ftg() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	var last_index: Array[int] = current_empty_index.duplicate(true)
	var _x: int
	var _y: int
	for shuffle_count: int in range(rng.randi_range(3, 5)):
		_x = current_empty_index[0]
		_y = current_empty_index[1]
		var candidates: Array = []
		if (_x+1 < width) and ([_x+1, _y] != last_index):
			candidates.append([_x+1, _y])
		if (_y-1 >= 0) and ([_x, _y-1] != last_index):
			candidates.append([_x, _y-1])
		if (_x-1 >= 0) and ([_x-1, _y] != last_index):
			candidates.append([_x-1, _y])
		if (_y+1 < height) and ([_x, _y+1] != last_index):
			candidates.append([_x, _y+1])
		var selected: Array = candidates.pick_random()
		var _selected: Array[int] = [selected[0], selected[1]]
		last_index = current_empty_index.duplicate(true)
		var _current_empty_index: Array[int] = current_empty_index.duplicate(true)
		slide_cell(_selected)
		request_immediately_move.emit(_selected, _current_empty_index)
	
	const duration = 6.0
	start_timer.emit(duration)

func check_game_cleared(_1: Array[int], _2: Array[int]) -> void: # These parameters are not used.
	for i: int in range(width*height-1):
		if board[i/height][i%width] != i+1:
			return
	request_disable_input.emit()
	pause_timer.emit()
	end_ftg.emit(true)

func _on_game_utils_game_timer_timeout() -> void:
	request_disable_input.emit()
	end_ftg.emit(false)
