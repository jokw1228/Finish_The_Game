extends Node2D
class_name Sudoku

const GRID_SIZE = 9

var board = []

var ans_board = []

var puzzle_board = []

var nums = [1,2,3,4,5,6,7,8,9]

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
@onready var grid:GridContainer = $SudokuGrid
#@onready var sprite:Sprite2D = $SudokuBoard
@onready var label:Label = $Label

signal grid_selected
signal inc_answer
signal restart

const BOARD_COLOR1 = Color(0.8, 0.8, 0.8, 0.8)
const BOARD_COLOR2 =  Color(0.5, 0.5, 0.5, 0.8) 

var num_inc =0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#for i in range(GRID_SIZE):
	#	nums = [1,2,3,4,5,6,7,8,9]
	#	nums.shuffle()
	#	board.append(nums)
	#_create_sudoku()
	#size = 1080x1920
	label.text = "Mistakes: 0/" + str(num_mistakes)
	label.position = Vector2(-320+8,-526)
	grid.position = Vector2(-428-32,-428)
	#sprite.position = Vector2(0.5,-256+32)
	solve_sudoku()
	ans_board = board.duplicate(true)
	#print_board()
	add_to_grid()


func print_board():
	for i in range(len(board)):
		print(board[i])
		print("")

func add_to_grid():
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var button = Button.new()
			if board[i][j] == 0:
				button.text = ""
			else:
				button.text = str(board[i][j])
			button.custom_minimum_size = Vector2(96,96)
			button.add_theme_color_override("font_color", Color(0, 0, 0))
			button.connect("pressed", Callable(self, "_on_button_pressed").bind(button, i, j))
			var style = StyleBoxFlat.new()
			var block_x = j / 3
			var block_y = i / 3
			var is_alternate = int(block_x + block_y) % 2 == 0
			if is_alternate: style.bg_color =  BOARD_COLOR1
			else: style.bg_color = BOARD_COLOR2
			
			
			
			button.add_theme_stylebox_override("normal", style)
			
			grid.add_child(button)
			game_grid[i][j] =button
			

func is_valid(row, col, val):
	for p in range(col):
		if board[row][p] == val:
			return false

	for i in range(row):
		if board[i][col] == val:
			return false
			
	var start_row = int(row/3)*3
	var start_col = int(col/3)*3
	
	for j in range(3):
		for k in range(3):
			if board[start_row+j][start_col+k] == val:
				return false
	return true
				
func gen_sudoku(row,col):
	if col == GRID_SIZE:
		col = 0
		row+=1
	
	if row==GRID_SIZE:
		return true
	
	if board[row][col] !=0:
		return gen_sudoku(row,col+1)
		
	nums.shuffle()
	for val in range(0,9):
		if is_valid(row, col, nums[val]):
			board[row][col] = nums[val]
			if gen_sudoku(row, col+1):
				return true
			board[row][col] = 0

	return false

func solve_sudoku():
	nums.shuffle()
	board.append(nums)
	nums = [1,2,3,4,5,6,7,8,9]
	game_grid.append([0,0,0,0,0,0,0,0,0])
	for i in range(GRID_SIZE-1):
		board.append([0,0,0,0,0,0,0,0,0])
		game_grid.append([0,0,0,0,0,0,0,0,0])
	gen_sudoku(1,0) 
	
func change_button_color(num, color):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if board[i][j] == num:
				#red and green cells are not changed
				var style = StyleBoxFlat.new()
				var curr_color = game_grid[i][j].get_theme_stylebox("normal").bg_color
				if curr_color !=  Color(1, 0, 0) and curr_color !=  Color(0, 1, 0):
					if color == BOARD_COLOR1:
						var block_x = j / 3
						var block_y = i / 3
						var is_alternate = int(block_x + block_y) % 2 == 0
						if is_alternate: style.bg_color =  BOARD_COLOR1
						else: style.bg_color = BOARD_COLOR2
					else:
						style.bg_color = color
					game_grid[i][j].add_theme_stylebox_override("normal", style)
			

func _on_button_pressed(button, i, j):
	emit_signal("grid_selected",button, i, j)
	is_grid_selected = true
	if ans_selected == true:
		change_button_color(ans_index,  BOARD_COLOR1)
	if button !=  curr_button:
		change_button_color(board[i][j],  Color(0.6, 0.8, 1))
		change_button_color(curr_button_index,  BOARD_COLOR1)
	curr_button = button
	curr_button_index = board[i][j]
	ans_selected = false

func _on_select_grid_choose_ans(index, button, i, j):
	if is_grid_selected and puzzle_board[i][j] == 0:
		change_button_color(curr_button_index, BOARD_COLOR1)
		ans_selected = true
		ans_index = index
		button.text = str(index)
		#blue
		button.add_theme_color_override("font_color", Color(0, 0, 1))
		board[i][j] = index
		change_button_color(index, Color(0.6, 0.8, 1))
		
		var style = StyleBoxFlat.new()
		print(board[i][j], " ", ans_board[i][j])
		if(board[i][j]!= ans_board[i][j]):
			#red
			style.bg_color = Color(1, 0, 0) 
			button.add_theme_stylebox_override("normal", style)
			inc_answer.emit()
		else:
			#green
			style.bg_color = Color(0, 1, 0) 
			button.add_theme_stylebox_override("normal", style) 
	
	#change_button_color(index, Color(0,0,0))
	


func _on_inc_answer():
	#prevent more than num_mistake mistakes
	if not game_ended and num_inc < num_mistakes:
		num_inc+=1
		label.text = "Mistakes: " + str(num_inc) + "/" + str(num_mistakes)


func _on_select_grid_ans_unselected(index):
	if not game_ended:
		change_button_color(index, BOARD_COLOR1)
