extends Sudoku
class_name FtgSudoku

var arr = []

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

const duration = 15.0

var timeout = false

signal disable_input

func start_ftg():
	var ans_num = randi() %16 + 5
	var rand_row
	var rand_col
	var i = 0
	while i < ans_num :
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

func check_inc_ans():
	if num_inc >=5:
		pause_timer.emit()
		if not timeout:
			end_ftg.emit(false)
	
			
func check_game_cleared():
	print("hi")
	for i in range(len(arr)):
		if not board[arr[i].x][arr[i].y] == ans_board[arr[i].x][arr[i].y]:
			return
	pause_timer.emit()
	if not timeout:
		end_ftg.emit(true)
	
func _on_game_utils_game_timer_timeout() -> void:
	end_ftg.emit(false)
	disable_input.emit()
	timeout = true
