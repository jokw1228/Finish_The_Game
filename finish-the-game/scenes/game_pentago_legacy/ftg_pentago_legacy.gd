extends Node2D
class_name FTGPentagoLegacy

@export var PentagoBoard_node: PentagoBoard

var board_size: int = 2
var subboard_size: int = 3
var N: int = 6 # board_size * subboard_size

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
	add_child(PentagoStoneCreator.create(Vector2(540,256), next_player))
	
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
	# 돌을 추가했을 때 5목이 완성되는 경우는 버려야함.
	while true:
		var test_board: Array = []
		for y in range(N):
			var temp: Array[int] = []
			for x in range(N):
				temp.append(board[y][x])
			test_board.append(temp)
		var test_zero_indexes: Array[Vector2] = []
		for i in range(zero_indexes.size()):
			test_zero_indexes.append(zero_indexes[i])
		
		const add_min = 1
		const add_max = 10
		var k: int = rng.randi_range(add_min, add_max)
		for i in range(k):
			var random_index: int = rng.randi_range(0, test_zero_indexes.size()-1)
			var selected: Vector2 = test_zero_indexes[random_index]
			test_zero_indexes.remove_at(random_index)
			test_board[selected.y][selected.x] = next_player
		var l: int = k + 4 if next_player == 1 else k + 5
		for i in range(l):
			var random_index: int = rng.randi_range(0, test_zero_indexes.size()-1)
			var selected: Vector2 = test_zero_indexes[random_index]
			test_zero_indexes.remove_at(random_index)
			test_board[selected.y][selected.x] = current_player
		
		if check_five_in_a_row(test_board, 1) == false \
		and check_five_in_a_row(test_board, 2) == false:
			board = test_board
			break
	
	var for_loop_found: bool = false
	for y in range(N):
		for x in range(N):
			if board[y][x] == -1:
				board[y][x] = 0
				for_loop_found = true
				break
		if for_loop_found == true:
			break
	
	PentagoBoard_node.start_ftg_pentago(board, next_player)
	
	await PentagoBoard_node.player_action_finished
	
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func check_five_in_a_row(board_to_check: Array, color_to_check: int = 1) -> bool:
	# 가로
	for y in range(N):
		for start_x in range(N-5 + 1):
			var is_five: bool = true
			for delta in range(5):
				if board_to_check[y][start_x+delta] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	# 세로
	for x in range(N):
		for start_y in range(N-5 + 1):
			var is_five: bool = true
			for delta in range(5):
				if board_to_check[start_y+delta][x] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	# 대각선 ↘
	for start_y in range(N-5 + 1):
		for start_x in range(N-5 + 1):
			var is_five: bool = true
			for delta in range(5):
				if board_to_check[start_y+delta][start_x+delta] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	# 대각선 ↗
	for start_y in range(N-5 + 1):
		for start_x in range(N-5 + 1):
			var is_five: bool = true
			for delta in range(5):
				if board_to_check[N-start_y-delta-1][start_x+delta] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	return false
