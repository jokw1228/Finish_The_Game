extends SlidingPuzzle
class_name FTGSlidingPuzzle

func start_ftg() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	var last_index: Array[int] = current_empty_index.duplicate(true)
	var _x: int
	var _y: int
	for shuffle_count: int in range(rng.randi_range(2, 4)):
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
		request_immediate_move.emit(_selected, current_empty_index)
		slide_cell(_selected)
