extends Node2D
class_name FTGPentago

var board_size: int = 2
var subboard_size: int = 3
var N: int = 6 # board_size * subboard_size

signal set_ftg_board(board: Array)

func _ready() -> void:
	generate_board()

func generate_board() -> void:
	"""
	'거꾸로 구성' 아이디어
	1) next_player(1 or 2) 정하기
	2) board 초기화
	3) next_player가 5목이 되도록 임의 배치, 그리고 해당 5목이 깨지도록 한 돌 제거
	4) 무작위 서브보드 하나 골라서 회전
	5) 상대 돌도 좀 배치해서 돌 개수 차이 0 또는 1 맞추기
	6) 최종 board에서 정말로 next_player가 '한 수 + 서브보드 회전'으로 5목을 만들 수 있는지 확인
	"""
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	# 1) next_player(1 or 2) 정하기
	# 1: black, 2: white
	var next_player: int = rng.randi_range(1, 2)
	
	# 2) board 초기화
	# board
	var board: Array = []
	for i in range(N):
		var temp: Array[int] = []
		for j in range(N):
			temp.append(0)
		board.append(temp)
	
	# 3) next_player가 5목이 되도록 임의 배치, 그리고 해당 5목이 깨지도록 한 돌 제거
	# Five in a row 4 cases
	var direction: int = rng.randi_range(0, 3)
	var start: int = rng.randi_range(0, N-5)
	var elimination: int = rng.randi_range(0, 4) # 플레이어가 두어야 하는 수(5목에서 제거되는 수)
	# 0: →, 1: ↑, 2: ↖, 3: ↗
	if direction == 0: # 0: →
		var start_y: int = rng.randi_range(0, N-1)
		for delta in range(0, 5):
			if delta == elimination:
				board[start_y][start+delta] = -1
			else:
				board[start_y][start+delta] = next_player
	elif direction == 1: # 1: ↑
		var start_x: int = rng.randi_range(0, N-1)
		for delta in range(0, 5):
			if delta == elimination:
				board[start+delta][start_x] = -1
			else:
				board[start+delta][start_x] = next_player
	elif direction == 2: # 2: ↖
		var start2: int = rng.randi_range(0, N-5)
		for delta in range(0, 5):
			if delta == elimination:
				board[start+delta][start2+delta] = -1
			else:
				board[start+delta][start2+delta] = next_player
	elif direction == 3: # 3: ↗
		var start2: int = rng.randi_range(0, N-5)
		for delta in range(0, 5):
			if delta == elimination:
				board[N-start-delta-1][start2+delta] = -1
			else:
				board[N-start-delta-1][start2+delta] = next_player
	
	# 4) 무작위 서브보드 하나 골라서 회전
	var subboard_to_rotate: Vector2 = Vector2(\
	randi_range(0, board_size-1), \
	randi_range(0, board_size-1))
	var x_offset: int = floor(subboard_to_rotate.x)*subboard_size
	var y_offset: int = floor(subboard_to_rotate.y)*subboard_size
	
	var paste_cells: Array = []
	for y in range(subboard_size):
		var temp: Array[int] = []
		for x in range(subboard_size):
			temp.append(0)
		paste_cells.append(temp)
	
	var rotation_direction: int = rng.randi_range(0, 1)
	# 0: ccw, 1: cw
	if rotation_direction == 0:
		for i in range(subboard_size):
			for j in range(subboard_size):
				paste_cells[subboard_size - 1 - j][i] \
				= board[i+y_offset][j+x_offset]
	elif rotation_direction == 1:
		for i in range(subboard_size):
			for j in range(subboard_size):
				paste_cells[j][subboard_size - 1 - i] \
				= board[i+y_offset][j+x_offset]
	
	for y in range(subboard_size):
		for x in range(subboard_size):
			board[y+y_offset][x+x_offset] = paste_cells[y][x]
	
	# 5) 상대 돌도 좀 배치해서 돌 개수 차이 0 또는 1 맞추기
	var current_player: int = 2 if next_player == 1 else 1
	
	var zero_indexes: Array[Vector2] = []
	for y in range(N):
		for x in range(N):
			if board[y][x] == 0:
				zero_indexes.append(Vector2(x, y))
	
	# next player's stone count = 5 + k - 1
	var k: int = rng.randi_range(1, 10)
	for i in range(k):
		var random_index: int = rng.randi_range(0, zero_indexes.size()-1)
		var selected: Vector2 = zero_indexes[random_index]
		zero_indexes.remove_at(random_index)
		board[selected.y][selected.x] = next_player
	var l: int = k + 4 if next_player == 1 else k + 5
	for i in range(l):
		var random_index: int = rng.randi_range(0, zero_indexes.size()-1)
		var selected: Vector2 = zero_indexes[random_index]
		zero_indexes.remove_at(random_index)
		board[selected.y][selected.x] = current_player
	
	var for_loop_found: bool = false
	for y in range(N):
		for x in range(N):
			if board[y][x] == -1:
				board[y][x] = 0
				for_loop_found = true
				break
		if for_loop_found == true:
			break
	
	print(board)
	print(next_player)
	set_ftg_board.emit(board)
