extends Orbito
class_name FTGOrbito

signal request_disable_input(disable)
signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()
signal resume_timer()

@export var retry_button: GameUtilsRetryButton

var my_color: CELL_STATE
var opponent_color: CELL_STATE

var my_color_backup: CELL_STATE
var opponent_color_backup: CELL_STATE

var board_backup: Array[Array]

func start_ftg(difficulty: float):
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	
	$orbito_ui.is_setting = true
	# 내 색깔 정하기
	my_color = [CELL_STATE.BLACK, CELL_STATE.WHITE].pick_random()
	my_color_backup = my_color
	opponent_color = CELL_STATE.WHITE if my_color == CELL_STATE.BLACK else CELL_STATE.BLACK
	opponent_color_backup = opponent_color
	
	board = make_kill_angle(difficulty)
	board_backup = board.duplicate(true)
	replace_all_stones()
	
	turn_state = TURN_STATE.BLACK_MOVE
	$orbito_ui.set_ui_state(OrbitoUI.UI_STATE.MOVE_STONE)
	$orbito_ui.hide_orbit_button()
	$orbito_ui.set_turn_color(OrbitoUI.TURN_COLOR.BLACK)
	if my_color == CELL_STATE.WHITE:
		turn_state = TURN_STATE.WHITE_MOVE
		$orbito_ui.set_turn_color(OrbitoUI.TURN_COLOR.WHITE)
		opponent_color = CELL_STATE.BLACK
	$orbito_ui.is_setting = false
	retry_button.set_disabled(true)
	#request_disable_input.emit(false)
		
		
func make_kill_angle(difficulty: float) -> Array[Array]:
	# 킬각만들기
	# 순서:
	# 1. 4목 놓기
	# 2. 다른 돌 추가하기
	# 3. 반대로 회전하기 (11번 똑바로 회전하면 반대로 한번 회전이랑 같음)
	# 4. 내 돌 하나 빼기
	# 5. 상대 돌 하나 움직이거나 안움직이기
	
	var completed_board: Array[Array] = []
	
	while true:
		completed_board.clear()
		for y: int in range(board_size):
			var temp: Array[CELL_STATE] = []
			for x: int in range(board_size):
				temp.append(CELL_STATE.EMPTY)
			completed_board.append(temp)
			
		# 1. 4목 놓기
		# difficulty 가 0.5 이하일 시, n = 0, 3, 4, 7로 설정
		# 즉, (보드 가운데 4칸을 경유 안하게 사목 생성)
		var n: int
		if difficulty <= 0.5:
			n = [0,3,4,7].pick_random()
		else:
			n = [1,2,5,6,8,9].pick_random()
		if n < 4:
			completed_board[n][0] = my_color
			completed_board[n][1] = my_color
			completed_board[n][2] = my_color
			completed_board[n][3] = my_color
		elif n < 8:
			n -= 4
			completed_board[0][n] = my_color
			completed_board[1][n] = my_color
			completed_board[2][n] = my_color
			completed_board[3][n] = my_color
		elif n == 8:
			completed_board[0][0] = my_color
			completed_board[1][1] = my_color
			completed_board[2][2] = my_color
			completed_board[3][3] = my_color
		else:
			completed_board[0][3] = my_color
			completed_board[1][2] = my_color
			completed_board[2][1] = my_color
			completed_board[3][0] = my_color
		
		# 2. 다른 돌 추가하기
		var temp_board: Array[Array] = []
		temp_board = completed_board.duplicate(true)
		while true:
			var empty_location = []
			for y: int in range(board_size):
				for x: int in range(board_size):
					var temp_loc = []
					if temp_board[y][x] == CELL_STATE.EMPTY:
						temp_loc.append(x)
						temp_loc.append(y)
						empty_location.append(temp_loc)
			empty_location.shuffle()
			for y: int in range(4):
				var temp_loc = empty_location.pop_front()
				temp_board[temp_loc[1]][temp_loc[0]] = opponent_color
			for y: int in range(2):
				var temp_loc = empty_location.pop_front()
				temp_board[temp_loc[1]][temp_loc[0]] = opponent_color
				temp_loc = empty_location.pop_front()
				temp_board[temp_loc[1]][temp_loc[0]] = my_color
			
			# 디버그 용
			'''
			for i: int in range(4):
				print(temp_board[i])
			print()
			OS.delay_msec(500)
			'''
			
			if four_in_a_row(temp_board, opponent_color) == false:
				completed_board = temp_board.duplicate(true)
				break
			else:
				temp_board.clear()
				temp_board = completed_board.duplicate(true)
		
		# 3. 반대로 회전하기 (11번 정회전)
		for i: int in range(11):
			var rotated_board: Array[Array] = completed_board.duplicate(true)
			for y: int in range(board_size/2):
				for x: int in range(board_size):
					if (x < y):
						rotated_board[y][x] = completed_board[y-1][x]
					elif (x >= board_size - 1 - y):
						rotated_board[y][x] = completed_board[y+1][x]
					else:
						rotated_board[y][x] = completed_board[y][x+1]
			for y: int in range(board_size/2,board_size):
				for x: int in range(board_size):
					if (x > y):
						rotated_board[y][x] = completed_board[y+1][x]
					elif (x <= board_size - 1 - y):
						rotated_board[y][x] = completed_board[y-1][x]
					else:
						rotated_board[y][x] = completed_board[y][x-1]
			completed_board = rotated_board
		
		# 4. 내 돌 하나 빼기
		var my_color_location = []
		for y: int in range(board_size):
			for x: int in range(board_size):
				var temp_loc = []
				if completed_board[y][x] == my_color:
					temp_loc.append(x)
					temp_loc.append(y)
					my_color_location.append(temp_loc)
		my_color_location.shuffle()
		var loc = my_color_location.pop_front()
		completed_board[loc[1]][loc[0]] = CELL_STATE.EMPTY
		
		# 5. 남의 돌 하나 옮기기
		var i: int = randi_range(0,4)
		if i == 0:
			pass
		else:
			var empty_location = []
			for y: int in range(board_size):
				for x: int in range(board_size):
					var temp_loc = []
					if completed_board[y][x] == CELL_STATE.EMPTY:
						temp_loc.append(x)
						temp_loc.append(y)
						empty_location.append(temp_loc)
			empty_location.shuffle()
			var empty_loc = empty_location.pop_front()
			var near_empty_loc = []
			if empty_loc[0] != 0:
				if completed_board[empty_loc[1]][empty_loc[0]-1] == opponent_color:
					near_empty_loc.append([empty_loc[0]-1,empty_loc[1]])
			if empty_loc[0] != 3:
				if completed_board[empty_loc[1]][empty_loc[0]+1] == opponent_color:
					near_empty_loc.append([empty_loc[0]+1,empty_loc[1]])
			if empty_loc[1] != 0:
				if completed_board[empty_loc[1]-1][empty_loc[0]] == opponent_color:
					near_empty_loc.append([empty_loc[0],empty_loc[1]-1])
			if empty_loc[1] != 3:
				if completed_board[empty_loc[1]+1][empty_loc[0]] == opponent_color:
					near_empty_loc.append([empty_loc[0],empty_loc[1]+1])
			if near_empty_loc != []:
				near_empty_loc.shuffle()
				var locate_to_move = near_empty_loc.pop_front()
				completed_board[locate_to_move[1]][locate_to_move[0]] = CELL_STATE.EMPTY
				completed_board[empty_loc[1]][empty_loc[0]] = opponent_color
				
		# 혹시 아무거도 안 건드려도 되는지 체크
		var board_too_easy_check = completed_board.duplicate(true)
		var rotated_board: Array[Array] = board_too_easy_check.duplicate(true)
		for y: int in range(board_size/2):
			for x: int in range(board_size):
				if (x < y):
					rotated_board[y][x] = board_too_easy_check[y-1][x]
				elif (x >= board_size - 1 - y):
					rotated_board[y][x] = board_too_easy_check[y+1][x]
				else:
					rotated_board[y][x] = board_too_easy_check[y][x+1]
		for y: int in range(board_size/2,board_size):
			for x: int in range(board_size):
				if (x > y):
					rotated_board[y][x] = board_too_easy_check[y+1][x]
				elif (x <= board_size - 1 - y):
					rotated_board[y][x] = board_too_easy_check[y-1][x]
				else:
					rotated_board[y][x] = board_too_easy_check[y][x-1]
		board_too_easy_check = rotated_board
		if not four_in_a_row(board_too_easy_check, my_color):
			break
	#end while
	
	const duration = 12.0
	start_timer.emit(duration)
	return completed_board
		
func reset_ftg_board() -> void:
	$orbito_ui.is_setting = true
	my_color = my_color_backup
	opponent_color = opponent_color_backup
	board = board_backup.duplicate(true)
	replace_all_stones()
	turn_state = TURN_STATE.BLACK_MOVE
	$orbito_ui.set_ui_state(OrbitoUI.UI_STATE.MOVE_STONE)
	$orbito_ui.hide_orbit_button()
	$orbito_ui.set_turn_color(OrbitoUI.TURN_COLOR.BLACK)
	if my_color == CELL_STATE.WHITE:
		turn_state = TURN_STATE.WHITE_MOVE
		$orbito_ui.set_turn_color(OrbitoUI.TURN_COLOR.WHITE)
		opponent_color = CELL_STATE.BLACK
	$orbito_ui.is_setting = false
	
func four_in_a_row(board_to_check: Array[Array], state: CELL_STATE) -> bool:
	for y: int in range(board_size):
		if ((board_to_check[y][0] == board_to_check[y][1]) \
		and (board_to_check[y][1] == board_to_check[y][2]) \
		and (board_to_check[y][2] == board_to_check[y][3]) \
		and (board_to_check[y][0] == state)):
			return true
	for x: int in range(board_size):
		if ((board_to_check[0][x] == board_to_check[1][x]) \
		and (board_to_check[1][x] == board_to_check[2][x]) \
		and (board_to_check[2][x] == board_to_check[3][x]) \
		and (board_to_check[0][x] == state)):
			return true
	if ((board_to_check[0][0] == board_to_check[1][1]) \
	and (board_to_check[1][1] == board_to_check[2][2]) \
	and (board_to_check[2][2] == board_to_check[3][3]) \
	and (board_to_check[0][0] == state)):
		return true
	elif ((board_to_check[0][3] == board_to_check[1][2]) \
	and (board_to_check[1][2] == board_to_check[2][1]) \
	and (board_to_check[2][1] == board_to_check[3][0]) \
	and (board_to_check[0][3] == state)):
		return true
	return false
	
func check_game_cleared():
	pause_timer.emit()
	await get_tree().create_timer(0.4).timeout
	var cleared: bool = false
	if four_in_a_row(orbited_board, my_color):
		if four_in_a_row(orbited_board, opponent_color):
			cleared = false
		else:
			cleared = true
	if cleared == true:
		request_disable_input.emit(true)
		end_ftg.emit(true)
	else:
		resume_timer.emit()
		open_retry_button()
	return
	
func _on_game_utils_game_timer_timeout() -> void:
	request_disable_input.emit(true)
	end_ftg.emit(false)
	return
	
func open_retry_button() -> void:
	retry_button.set_disabled(false)
	
	var target_position: Vector2 = retry_button.position
	const duration = 0.2
	
	var tween_position: Tween = get_tree().create_tween()
	tween_position.tween_property\
	(retry_button, "position", Vector2(200,retry_button.position[1]), duration)\
	.from(Vector2(800,target_position[1]))\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

func close_retry_button() -> void:
	retry_button.set_disabled(true)
	
	var closed_position: Vector2 = Vector2(800, retry_button.position[1])
	const duration = 0.2
	
	var tween_position: Tween = get_tree().create_tween()
	tween_position.tween_property\
	(retry_button, "position", closed_position, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
