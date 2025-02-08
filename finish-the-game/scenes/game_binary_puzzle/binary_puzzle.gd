extends Node2D
class_name BinaryPuzzle

var GRID_SIZE = 6

var board = []

var ans_board = []

var puzzle_board = []

var nums = []

var vals = [0,1]

var game_grid = []

var curr_ans

var grid_blank = false

var subboard 

var curr_button

var curr_button_index = -1

var ans_selected = false

var game_ended = false

var ans_index = 0

var num_mistakes = 10

var is_grid_selected = false
@onready var grid:GridContainer = $BinaryPuzzleGrid
#@onready var sprite:Sprite2D = $SudokuBoard
@onready var label:Label = $Label
@onready var emitter = $"."

signal grid_selected
signal inc_answer
signal restart
signal num_changed

const BOARD_COLOR = Color(0.8, 0.8, 0.8, 0.8)
const BOARD_COLOR0 = Color("#91C0D4", 0.8)
const BOARD_COLOR1 =  Color("#E6B88C", 0.8) 

var num_inc =0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in range(GRID_SIZE):
	#	nums = [1,2,3,4,5,6,7,8,9]
	#	nums.shuffle()
	#	board.append(nums)
	#_create_sudoku()
	#size = 1080x1920
	#label.text = "Mistakes: 0/" + str(num_mistakes)
	label.position = Vector2(-348,-526)
	#sprite.position = Vector2(0.5,-256+32)
	await emitter.difficulty_set
	if GRID_SIZE == 4: grid.position = Vector2(-428+32+4,-428+32)
	else: grid.position = Vector2(-428+32,-428+32)
	solve_binary_puzzle()
	ans_board = board.duplicate(true)
	grid.columns = GRID_SIZE
	print_board()
	add_to_grid()
	#print(game_grid)


func print_board():
	for i in range(len(board)):
		print(board[i])
		print("")
	print("")

func add_to_grid():
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var button = Button.new()
			button.custom_minimum_size = Vector2(128,128)
			if GRID_SIZE == 4:
				button.custom_minimum_size = Vector2(128+64,128+64)
			button.add_theme_color_override("font_color", Color(0, 0, 0))
			button.connect("pressed", Callable(self, "_on_button_pressed").bind(button, i, j))
			var style = StyleBoxFlat.new()
			if board[i][j] == -1:
				button.text = ""
				style.bg_color =  BOARD_COLOR
			else:
				button.text = str(board[i][j])
				if board[i][j] == 0:
					style.bg_color =  BOARD_COLOR0
				else:
					style.bg_color =  BOARD_COLOR1
			
			
			button.add_theme_stylebox_override("normal", style)
			
			grid.add_child(button)
			game_grid[i][j] = button
			

func is_valid(row, col, val):
	var count0 = 0
	var count1 = 0
	#check row
	var cell_value
	for p in range(GRID_SIZE):
		if p == col:
			cell_value = val
		else:
			cell_value = board[row][p]
		if cell_value== 0:
			count0+=1
		elif cell_value == 1:
			count1+=1
		if count0 > GRID_SIZE/2 or count1 > GRID_SIZE/2 :
			return false
		#numbers should not be same three in a row	
		if p-2>=0 and cell_value!=-1:
			if board[row][p-1] ==  cell_value and  board[row][p-2] ==  board[row][p-1]:
				return false
				
	count0 = 0
	count1 = 0
	#check col
	for i in range(GRID_SIZE):
		if i == row:
			cell_value = val
		else:
			cell_value = board[i][col]
		if cell_value == 0:
			count0+=1
		elif cell_value== 1:
			count1+=1
		if count0 > GRID_SIZE/2  or count1 > GRID_SIZE/2 :
			return false
		#numbers should not be same three in a row	
		if i -2 >= 0  and cell_value!=-1:
			if cell_value ==  board[i-1][col] and  board[i-2][col] == board[i-1][col]:
				return false
			
	#check row for duplicates
	#print("check1")
	var is_duplicate
	for m in range(GRID_SIZE):
		is_duplicate = true
		for n in range(GRID_SIZE):
			cell_value = board[row][n]
			if n == col: cell_value = val
			if board[m][n] != cell_value or board[m][n] == -1:
				is_duplicate = false
				break
		if is_duplicate: return false
	#check col for duplicates
	#print("check2")
	for m in range(GRID_SIZE):
		is_duplicate = true
		for n in range(GRID_SIZE):
			cell_value = board[n][col]
			if n == row: cell_value = val
			if board[n][m] != cell_value or board[n][m] == -1:
				is_duplicate = false
				break
		if is_duplicate: return false


	
	return true

#backtracking	
func gen_binary_puzzle(row,col):
	if col == GRID_SIZE:
		col = 0
		row+=1
	if row==GRID_SIZE:
		return true
	
	if board[row][col] !=-1:
		return gen_binary_puzzle(row,col+1)
		
	vals.shuffle()
	#print("nums: ", nums)
	for val in vals:
		if is_valid(row, col,val):
			board[row][col] = val
			if gen_binary_puzzle(row, col+1):
				return true
			board[row][col] = -1

	return false
	
func gen_valid_row(gboard):
	var flag = false
	while not flag:
		gboard.shuffle()
		flag = true
		for p in range(GRID_SIZE):
			if p-2 >=0:
				if gboard[p-1] ==  gboard[p] and  gboard[p-2] ==  gboard[p-1]:
					flag = false
			
			
func solve_binary_puzzle():
	nums.clear()
	board.clear()
	game_grid.clear()
	for i in range(int(GRID_SIZE/2)):
		nums.append(0)
		nums.append(1)
	#print(nums)
	gen_valid_row(nums)
	var numsubboard = nums.duplicate(true)
	board.append(numsubboard)
	for j in range(GRID_SIZE):
		var subboard: Array[int] = []
		var subboard2: Array[int] = []
		for k in range(GRID_SIZE):
			subboard.append(-1)
			subboard2.append(-1)
		if not j > GRID_SIZE-2:
			board.append(subboard)
		if GRID_SIZE == 4:
			game_grid.append([0,0,0,0])
		else:
			game_grid.append([0,0,0,0,0,0])
		
	if not gen_binary_puzzle(1,0):
		print("not solved")
		
func _on_button_pressed(button, i, j):
	$BinaryPuzzleGrid/AudioStreamPlayer2D.play()
	var style = StyleBoxFlat.new()
	if puzzle_board[i][j] == -1:
		if board[i][j] == -1:
			button.text = "0"
			style.bg_color =  BOARD_COLOR0
			board[i][j] = 0
		elif board[i][j] == 0:
			button.text = "1"
			style.bg_color =  BOARD_COLOR1
			board[i][j] = 1
		else:
			button.text = ""
			style.bg_color =  BOARD_COLOR
			board[i][j] = -1
		button.add_theme_stylebox_override("normal", style)
		num_changed.emit(i,j)

	
func check_three():
	var red = Color("#FF7F7F",0.8)
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE-2):
			if board[i][j] == board[i][j+1] and board[i][j+2] == board[i][j+1] and board[i][j] != -1:
				label.text = "More than two!"
				change_row_color(i, j, j+2, red)
			if board[j][i] == board[j+1][i] and board[j+2][i] == board[j+1][i] and board[j][i] != -1:
				label.text = "More than two!"
				change_col_color(i, j, j+2, red)
			
	
func check_row_dup(row):
	var red = Color("#FF7F7F",0.8)
	for i in range(GRID_SIZE):
		if not i == row:
			if board[i] == board[row]:
				label.text = "Same row exists!"
				change_row_color(i, 0, GRID_SIZE-1, red)
				change_row_color(row, 0, GRID_SIZE-1, red)
	
func check_col_dup(col):
	var red = Color("#FF7F7F",0.8)
	var is_dup = false
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			is_dup = true
			if board[j][i] != board[j][col] or board[j][i] == -1 or i==col:
				is_dup = false
				break
		if is_dup:
			label.text = "Same column exists!"
			change_col_color(i, 0, GRID_SIZE-1, red)
			change_col_color(col, 0, GRID_SIZE-1, red)
			
func change_col_color(col, start, finish, color):
	for i in range(start, finish+1):
		var style = StyleBoxFlat.new()
		style.bg_color = color
		if color == BOARD_COLOR:
			if board[i][col] == -1:
				style.bg_color =  BOARD_COLOR
			else:
				if board[i][col] == 0:
					style.bg_color =  BOARD_COLOR0
				else:
					style.bg_color =  BOARD_COLOR1
		game_grid[i][col].add_theme_stylebox_override("normal", style)
		
	
func change_row_color(row,start, finish, color):
	for i in range(start, finish+1):
		var style = StyleBoxFlat.new()
		style.bg_color = color
		if color == BOARD_COLOR:
			if board[row][i] == -1:
				style.bg_color =  BOARD_COLOR
			else:
				if board[row][i] == 0:
					style.bg_color =  BOARD_COLOR0
				else:
					style.bg_color =  BOARD_COLOR1
			
		game_grid[row][i].add_theme_stylebox_override("normal", style)

func reset_board_color():
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var style = StyleBoxFlat.new()
			if board[i][j] == -1:
				style.bg_color =  BOARD_COLOR
			else:
				if board[i][j] == 0:
					style.bg_color =  BOARD_COLOR0
				else:
					style.bg_color =  BOARD_COLOR1
			game_grid[i][j].add_theme_stylebox_override("normal", style)
		
func _on_num_changed(row,col):
	#label display
	var red = Color("#FF7F7F",0.8)
	var num
	var count = 0
	var prev_val = -1
	#reset_board_color()
	label.text = ""
	reset_board_color()
	check_three()
	check_row_dup(row)
	check_col_dup(col)
	
	
	
	
