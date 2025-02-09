extends Sudoku
class_name FtgSudoku

var arr = []

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

const duration = 25

var timeout = false

var num_blank = 0

signal disable_input


"""
형식: 난이도 -> 빈칸 개수
difficulty == 1 -> 10~11
0.75 <= difficulty < 1  -> 9
0.5 <= difficulty < 0.75 -> 8
0.25 <= difficulty < 0.5-> 7
0 < difficulty < 0.25 -> 4~5
difficulty == 0-> 3

"""
	


func start_ftg(difficulty):
	#print("start")
	set_difficulty(difficulty)
	var rand_row
	var rand_col
	var i = 0
	while i < num_blank :
		rand_row = randi() % 9 
		rand_col =  randi() % 9 
		if Vector2(rand_row, rand_col) not in arr:
			board[rand_row][rand_col] = 0
			game_grid[rand_row][rand_col].text = ""
			arr.append(Vector2(rand_row, rand_col))
			i+=1
	start_timer.emit(duration)
	puzzle_board = board.duplicate(true)
	#print(" ")
	#print_board()
	#print(arr)
	
	
func set_difficulty(difficulty):
	if difficulty == 1:
		num_blank = randi_range(10,11)
	elif difficulty < 1 and difficulty >= 0.75:
		num_blank = 9
	elif difficulty < 0.75 and difficulty >= 0.5:
		num_blank = 8
	elif difficulty < 0.5 and difficulty >= 0.25:
		num_blank = randi_range(6,7)
	elif difficulty < 0.25 and difficulty > 0:
		num_blank = randi_range(4,5)
	else:
		num_blank  = 3

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
