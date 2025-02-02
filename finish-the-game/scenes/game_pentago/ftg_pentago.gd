extends Pentago
class_name FTGPentago

signal request_disable_input()
signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

signal request_set_color(color_to_place: Pentago.CELL_STATE)

var player_color: CELL_STATE

func start_ftg() -> void:
	"""
	'거꾸로 구성' 아이디어
	1) next_player(BLACK or WHITE) 정하기.
	2) next_player가 5목이 되도록 임의 배치, 그리고 해당 5목이 깨지도록 한 돌 제거.
	3) 무작위 서브보드 하나 골라서 무작위 방향으로 회전.
	4) 추가적인 돌들을 배치해서 흑돌과 백돌의 개수 차이 0 또는 1이 되도록 맞추기.
	5) 만약 이 상태에서 5목이 존재한다면, 다시 4)로 가서 반복.
	"""
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	# 1) next_player(BLACK or WHITE) 정하기.
	var next_player: CELL_STATE = [CELL_STATE.BLACK, CELL_STATE.WHITE].pick_random()
	turn_state = TURN_STATE.BLACK_PLACE \
	if next_player == CELL_STATE.BLACK \
	else TURN_STATE.WHITE_PLACE
	player_color = next_player
	request_set_color.emit(next_player)
	
	# 2) next_player가 5목이 되도록 임의 배치, 그리고 해당 5목이 깨지도록 한 돌 제거.
	const N = 6
	var direction: int = rng.randi_range(0, 3) # Five in a row 4 cases
	var start: int = rng.randi_range(0, N-5)
	var elimination: int = rng.randi_range(0, 4) # 플레이어가 두어야 하는 수(5목에서 제거되는 수)
	# 0: →, 1: ↑, 2: ↖, 3: ↗
	if direction == 0: # 0: →
		var start_y: int = rng.randi_range(0, N-1)
		for delta in range(0, 5):
			if delta == elimination:
				board[start_y][start+delta] = CELL_STATE.BLOCKED
			else:
				board[start_y][start+delta] = next_player
	elif direction == 1: # 1: ↑
		var start_x: int = rng.randi_range(0, N-1)
		for delta in range(0, 5):
			if delta == elimination:
				board[start+delta][start_x] = CELL_STATE.BLOCKED
			else:
				board[start+delta][start_x] = next_player
	elif direction == 2: # 2: ↖
		var start2: int = rng.randi_range(0, N-5)
		for delta in range(0, 5):
			if delta == elimination:
				board[start+delta][start2+delta] = CELL_STATE.BLOCKED
			else:
				board[start+delta][start2+delta] = next_player
	elif direction == 3: # 3: ↗
		var start2: int = rng.randi_range(0, N-5)
		for delta in range(0, 5):
			if delta == elimination:
				board[N-start-delta-1][start2+delta] = CELL_STATE.BLOCKED
			else:
				board[N-start-delta-1][start2+delta] = next_player
	
	# 3) 무작위 서브보드 하나 골라서 무작위 방향으로 회전.
	var subboard_index_to_rotate: Array[int] = \
	[randi_range(0,1), randi_range(0,1)]
	var x_i: int = subboard_index_to_rotate[0]
	var y_i: int = subboard_index_to_rotate[1]
	
	var target_subboard: Array[Array] = []
	for y: int in range(3):
		var temp: Array[CELL_STATE] = []
		for x: int in range(3):
			temp.append(board[y+subboard_width*y_i][x+subboard_width*x_i])
		target_subboard.append(temp)
	
	var rotation_direction: ROTATION_DIRECTION = \
	[ROTATION_DIRECTION.CCW, ROTATION_DIRECTION.CW].pick_random()
	target_subboard = rotate_3x3_matrix_ccw(target_subboard) \
	if rotation_direction == ROTATION_DIRECTION.CCW \
	else rotate_3x3_matrix_cw(target_subboard)
	
	for y: int in range(3):
		for x: int in range(3):
			board[y+subboard_width*y_i][x+subboard_width*x_i] = target_subboard[y][x]
	
	# 4) 추가적인 돌들을 배치해서 흑돌과 백돌의 개수 차이 0 또는 1이 되도록 맞추기.
	# 5) 만약 이 상태에서 5목이 존재한다면, 다시 4)로 가서 반복.
	var zero_indexes: Array[Array] = []
	for y in range(N):
		for x in range(N):
			if board[y][x] == CELL_STATE.EMPTY:
				zero_indexes.append([x, y])
	
	while true:
		var test_board: Array[Array] = board.duplicate(true)
		var test_zero_indexes: Array[Array] = zero_indexes.duplicate(true)
		
		const MIN_PLACEMENT = 1
		const MAX_PLACEMENT = 10
		var placement: int = rng.randi_range(MIN_PLACEMENT, MAX_PLACEMENT)
		
		for i: int in range(placement):
			var selected_zero_index: Array \
			= test_zero_indexes.pop_at(randi_range(0, test_zero_indexes.size() - 1))
			test_board[selected_zero_index[1]][selected_zero_index[0]] = next_player
		
		var enemy_player: CELL_STATE
		var enemy_placement: int
		if next_player == CELL_STATE.BLACK:
			enemy_player = CELL_STATE.WHITE
			enemy_placement = placement + 4
		elif next_player == CELL_STATE.WHITE:
			enemy_player = CELL_STATE.BLACK
			enemy_placement = placement + 5
		for i: int in range(enemy_placement):
			var selected_zero_index: Array \
			= test_zero_indexes.pop_at(randi_range(0, test_zero_indexes.size() - 1))
			test_board[selected_zero_index[1]][selected_zero_index[0]] = enemy_player
		
		if check_five_in_a_row(test_board, CELL_STATE.BLACK) == false \
		and check_five_in_a_row(test_board, CELL_STATE.WHITE) == false:
			board = test_board
			break
		
	for y: int in range(N):
		for x: int in range(N):
			if board[y][x] == CELL_STATE.BLOCKED:
				board[y][x] = CELL_STATE.EMPTY
			elif board[y][x] == CELL_STATE.BLACK or board[y][x] == CELL_STATE.WHITE:
				var target_subboard_index: Array[int] = \
				[int(x/subboard_width), int(y/subboard_width)]
				var target_cell_index: Array[int] = \
				[int(x%subboard_width), int(y%subboard_width)]
				request_immediately_place_stone.emit(target_subboard_index, target_cell_index, board[y][x])
	
	const duration = 8.0
	start_timer.emit(duration)

func check_five_in_a_row(board_to_check: Array[Array], color_to_check: CELL_STATE) -> bool:
	const N = 6
	# 가로
	for y: int in range(N):
		for start_x: int in range(N-5 + 1):
			var is_five: bool = true
			for delta: int in range(5):
				if board_to_check[y][start_x+delta] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	# 세로
	for x: int in range(N):
		for start_y: int in range(N-5 + 1):
			var is_five: bool = true
			for delta: int in range(5):
				if board_to_check[start_y+delta][x] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	# 대각선 ↘
	for start_y: int in range(N-5 + 1):
		for start_x: int in range(N-5 + 1):
			var is_five: bool = true
			for delta: int in range(5):
				if board_to_check[start_y+delta][start_x+delta] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	# 대각선 ↗
	for start_y: int in range(N-5 + 1):
		for start_x: int in range(N-5 + 1):
			var is_five: bool = true
			for delta: int in range(5):
				if board_to_check[N-start_y-delta-1][start_x+delta] != color_to_check:
					is_five = false
					break
			if is_five == true:
				return true
	
	return false

func check_game_is_cleared(_1, _2) -> void:
	request_disable_input.emit()
	pause_timer.emit()
	
	await get_tree().create_timer(0.3).timeout
	if check_five_in_a_row(board, player_color) == true:
		end_ftg.emit(true)
	else:
		end_ftg.emit(false)


func _on_game_utils_game_timer_timeout() -> void:
	request_disable_input.emit()
	end_ftg.emit(false)

func remember_stone_placed(approved_subboard_index: Array[int], approved_cell_index: Array[int], approved_color: CELL_STATE) -> void:
	pass

func remember_subboard_rotated(approved_subboard_index: Array[int], approved_rotation_direction: ROTATION_DIRECTION) -> void:
	pass
