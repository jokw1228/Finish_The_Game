extends GridContainer

const GRID_SIZE = 9
var grid_selected = false
var selected_button: Button
var selected_row
var selected_column
var curr_index = 0
var cur_selected_button
var is_selectable = true
signal choose_ans
signal ans_unselected
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_grid()
	position = Vector2(-428-32, 508)


func create_grid():
	for i in range(GRID_SIZE):
		var button = Button.new()
		button.text = str(i+1)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0-1, 0, 0) 
		button.add_theme_stylebox_override("normal", style)
		
		button.custom_minimum_size = Vector2(96,96)
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(i+1))
		add_child(button)

func _on_button_pressed(index):
	if is_selectable:
		if curr_index != index:
			ans_unselected.emit(curr_index)
		if cur_selected_button != selected_button:
			choose_ans.emit(index, selected_button, selected_row, selected_column)
		grid_selected = false
		curr_index = index
		cur_selected_button == selected_button

	

func _on_sudoku_grid_selected(button, i, j):
	
	grid_selected = true
	selected_button = button
	selected_row = i
	selected_column = j
	


func _on_ftg_sudoku_disable_input():
	is_selectable = false
