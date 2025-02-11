extends Sudoku
class_name FtgSudoku

var arr = []

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

var time_limit: float

var timeout: bool = false

var num_blank: int = 0

signal disable_input


"""
형식: 난이도 -> 빈칸 개수
difficulty == 1 -> 9~10
0.75 <= difficulty < 1  -> 8
0.5 <= difficulty < 0.75 -> 7
0.25 <= difficulty < 0.5-> 6
0 < difficulty < 0.25 -> 4~5
difficulty == 0-> 3

"""
	


func start_ftg(difficulty):
	#print("start")
	set_difficulty(difficulty)
	var rand_row
	var rand_col
	var i: int = 0
	while i < num_blank :
		rand_row = randi() % 9 
		rand_col =  randi() % 9 
		if Vector2(rand_row, rand_col) not in arr:
			board[rand_row][rand_col] = 0
			game_grid[rand_row][rand_col].text = ""
			arr.append(Vector2(rand_row, rand_col))
			i += 1
	start_timer.emit(time_limit)
	puzzle_board = board.duplicate(true)
	#print(" ")
	#print_board()
	#print(arr)
	
	
func set_difficulty(difficulty):
	if difficulty < 0.2:
		num_blank = 3
		time_limit = 15
	
	elif difficulty < 0.4:
		num_blank = 4
		time_limit = 20
	
	elif difficulty < 0.6:
		num_blank = 5
		time_limit = 25
	
	elif difficulty < 0.8:
		num_blank = 6
		time_limit = 30
	
	elif difficulty >= 0.8:
		num_blank = 7
		time_limit = 30 - (difficulty - 0.8) * 10

func check_inc_ans():
	if num_inc >=num_mistakes:
		if not game_ended:
			disable_input.emit()
			pause_timer.emit()
			end_ftg.emit(false)
			#print("ended becasue of incorrect answers")
			game_ended = true
			num_inc = 0
	
			
func check_game_cleared():
	#print("hi")
	for i in range(len(arr)):
		if not board[arr[i].x][arr[i].y] == ans_board[arr[i].x][arr[i].y]:
			return
	pause_timer.emit()
	if not game_ended:
		disable_input.emit()
		end_ftg.emit(true)
		game_ended =true
		#print("ended becasue of correct answers")
	
func _on_game_utils_game_timer_timeout() -> void:
	print("ended becasue of time")
	if not game_ended:
		disable_input.emit()
		end_ftg.emit(false)
		game_ended = true
