extends BinaryPuzzle
class_name FtgBinaryPuzzle

var arr = []

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)
signal pause_timer()

const duration = 20

var timeout = false

signal disable_input


func start_ftg():
	print("start")
	var ans_num = randi() %5 + 7
	var rand_row
	var rand_col
	var i = 0
	while i < ans_num :
		rand_row = randi() % GRID_SIZE
		rand_col =  randi() % GRID_SIZE
		if Vector2(rand_row, rand_col) not in arr:
			board[rand_row][rand_col] = -1
			game_grid[rand_row][rand_col].text = ""
			var style = StyleBoxFlat.new()
			style.bg_color =  BOARD_COLOR
			game_grid[rand_row][rand_col].add_theme_color_override("font_color", Color(1, 1, 1))
			game_grid[rand_row][rand_col].add_theme_stylebox_override("normal", style)
			arr.append(Vector2(rand_row, rand_col))
			i+=1
	start_timer.emit(duration)
	puzzle_board = board.duplicate(true)
	#print(" ")
	#print_board()
	#print(arr)

func check_inc_ans():
	if num_inc >=num_mistakes:
		if not game_ended:
			#disable_input.emit()
			pause_timer.emit()
			end_ftg.emit(false)
			#print("ended becasue of incorrect answers")
			game_ended = true
			num_inc = 0
	
			
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
