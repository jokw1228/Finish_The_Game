extends Pentago
class_name FTGPentago

signal request_disable_input(disable_to_set: bool)
signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

signal request_set_color(color_to_place: Pentago.CELL_STATE)

var player_color: CELL_STATE

func start_ftg(difficulty: float) -> void:
	var time_limit: float
	if difficulty < 0.6:
		time_limit = 15
	else:
		time_limit = 15 - (difficulty-0.6) * 5
	
	var diagonal_threshold: float = 0.4
	
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
	#var direction: int = rng.randi_range(0, 3) # Five in a row 4 cases
	var direction: int
	if difficulty < diagonal_threshold:
		direction = rng.randi_range(0, 1)
	else:
		direction = rng.randi_range(0, 3)
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
		#var test_board: Array[Array] = board.duplicate(true)
		#var test_zero_indexes: Array[Array] = zero_indexes.duplicate(true)
		# Warning! Godot can NOT deep copy subresources!
		var test_board: Array[Array] = []
		for y: int in range(board_width):
			var temp: Array[CELL_STATE] = []
			for x: int in range(board_width):
				temp.append(board[y][x])
			test_board.append(temp)
		
		var test_zero_indexes: Array[Array] = []
		for zero_index: Array[int] in zero_indexes:
			test_zero_indexes.append([zero_index[0], zero_index[1]])
		
		const MIN_PLACEMENT = 1
		const MAX_PLACEMENT = 8
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
	
	start_timer.emit(time_limit)

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
	request_disable_input.emit(true)
	
	var is_cleared: bool = check_five_in_a_row(board, player_color)
	
	if is_cleared == true:
		pause_timer.emit()
		await get_tree().create_timer(0.3).timeout
		end_ftg.emit(true)
	
	elif is_cleared == false:
		await get_tree().create_timer(0.3).timeout
		open_retry_button()


func _on_game_utils_game_timer_timeout() -> void:
	request_disable_input.emit()
	end_ftg.emit(false)


@export var PentagoUI_node: PentagoUI

var placed_subboard_index: Array[int]
var placed_cell_index: Array[int]
func remember_placed_stone(approved_subboard_index: Array[int], approved_cell_index: Array[int], _approved_color: CELL_STATE) -> void:
	placed_subboard_index = approved_subboard_index
	placed_cell_index = approved_cell_index

var rotated_subboard_index: Array[int]
var rotated_subboard_direction: ROTATION_DIRECTION
func remember_rotated_subboard(approved_subboard_index: Array[int], approved_rotation_direction: ROTATION_DIRECTION) -> void:
	rotated_subboard_index = approved_subboard_index
	rotated_subboard_direction = approved_rotation_direction

func ftg_rollback() -> void: # 슈퍼 하드 코딩...Pentago나 PentagoUI 수정 시 이쪽 코드 정상 작동 안 할 확률 매우 높음.
	var rotated_subboard_direction_inversion: ROTATION_DIRECTION = \
	ROTATION_DIRECTION.CCW if rotated_subboard_direction == ROTATION_DIRECTION.CW \
	else ROTATION_DIRECTION.CW
	
	rotate_subboard(rotated_subboard_index, rotated_subboard_direction_inversion)
	
	PentagoUI_node.subboards[rotated_subboard_index[1]][rotated_subboard_index[0]].rotate_subboard(rotated_subboard_direction_inversion)
	
	var cell: PentagoCell = \
	PentagoUI_node.subboards[placed_subboard_index[1]][placed_subboard_index[0]]\
	.cells[placed_cell_index[1]][placed_cell_index[0]]
	cell.get_child(0).queue_free()
	
	board[placed_subboard_index[1]*subboard_width+placed_cell_index[1]][placed_subboard_index[0]*subboard_width+placed_cell_index[0]] \
	= CELL_STATE.EMPTY
	
	turn_state = TURN_STATE.BLACK_PLACE \
	if player_color == CELL_STATE.BLACK \
	else TURN_STATE.WHITE_PLACE
	
	PentagoUI_node.set_ui_state(PentagoUI_node.UI_STATE.PLACE_STONE)
	request_disable_input.emit(false)

@export var retry_button: GameUtilsRetryButton

func open_retry_button() -> void:
	retry_button.set_disabled(false)
	
	var opened_position: Vector2 = Vector2(256, 512)
	const duration = 0.2
	
	var tween_position: Tween = get_tree().create_tween()
	tween_position.tween_property\
	(retry_button, "position", opened_position, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

func close_retry_button() -> void:
	retry_button.set_disabled(true)
	
	var closed_position: Vector2 = Vector2(256+512, 512)
	const duration = 0.2
	
	var tween_position: Tween = get_tree().create_tween()
	tween_position.tween_property\
	(retry_button, "position", closed_position, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
