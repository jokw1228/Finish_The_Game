extends BinaryPuzzle
class_name FtgBinaryPuzzle

var arr = []

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

signal difficulty_set

var time_limit: float = 15

var timeout = false

var num_blank = 0

signal disable_input

"""
형식: 난이도 -> 빈칸 개수 & grid 길
difficulty == 1 -> 7 & 6x6 grid
0.75 <= difficulty < 1  -> 5~6 & 6x6 grid
0.5 <= difficulty < 0.75 ->  4~3 & 6x6 grid
0.25 <= difficulty < 0.5->  4 & 4x4 grid
0 < difficulty < 0.25 -> 3 & 4x4 grid
difficulty == 0-> 2 & 4x4 grid

"""

func start_ftg(difficulty):
	set_difficulty(difficulty)
	difficulty_set.emit()
	var rand_row
	var rand_col
	var i = 0
	while i < num_blank :
		rand_row = randi() % GRID_SIZE
		rand_col =  randi() % GRID_SIZE
		if Vector2(rand_row, rand_col) not in arr:
			board[rand_row][rand_col] = -1
			game_grid[rand_row][rand_col].text = ""
			var style = StyleBoxFlat.new()
			style.bg_color =  BOARD_COLOR
			#game_grid[rand_row][rand_col].add_theme_color_override("font_color", Color(1, 1, 1))
			#00FF00
			game_grid[rand_row][rand_col].add_theme_color_override("font_color", Color("#99ff99"))
			game_grid[rand_row][rand_col].add_theme_stylebox_override("normal", style)
			arr.append(Vector2(rand_row, rand_col))
			i+=1
	start_timer.emit(time_limit)
	puzzle_board = board.duplicate(true)
	#print(" ")
	#print_board()
	#print(arr)
	
func set_difficulty(difficulty):
	if difficulty < 0.2:
		GRID_SIZE = 4
		num_blank = 2
		time_limit = 10
	
	elif difficulty < 0.4:
		GRID_SIZE = 4
		num_blank = 3
		time_limit = 10
	
	elif difficulty < 0.6:
		GRID_SIZE = 4
		num_blank = 4
		time_limit = 10
	
	elif difficulty < 0.8:
		GRID_SIZE = 6
		num_blank = 6
		time_limit = 12
	
	elif difficulty >= 0.8:
		GRID_SIZE = 6
		num_blank = 6
		time_limit = 12 - (difficulty - 0.8) * 10
			
func check_game_cleared(row,col):
	#print("hi")
	for i in range(len(arr)):
		if not board[arr[i].x][arr[i].y] == ans_board[arr[i].x][arr[i].y]:
			return
	pause_timer.emit()
	if not game_ended:
		#disable_input.emit()
		end_ftg.emit(true)
		game_ended =true
		#print("ended becasue of correct answers")
	
func _on_game_utils_game_timer_timeout() -> void:
	#print("ended becasue of time")
	if not game_ended:
		#disable_input.emit()
		end_ftg.emit(false)
		game_ended = true
