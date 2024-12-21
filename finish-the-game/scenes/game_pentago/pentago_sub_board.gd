extends Node2D
class_name PentagoSubBoard

var size: int = 3
var cells: Array = [] # cells[y][x], right: x+, down: y+

func _ready() -> void:
	# Cells initialization
	_cells_initializaiton(cells)

func _cells_initializaiton(array_to_init: Array): # Cells initialization (filling it with zero)
	for i in range(size):
		var temp: Array[int] = []
		for j in range(size):
			temp.append(0)
		array_to_init.append(temp)

func rotate_ccw() -> void: # Rotate the subboard 90 degrees counterclockwise
	# New cells initializaiton
	var new_cells: Array = []
	_cells_initializaiton(new_cells)
	
	# Fill in the new cells
	for i in range(size):
		for j in range(size):
			new_cells[j][size - 1 - i] = cells[i][j]
	
	# Update the cells
	cells = new_cells

func rotate_cw() -> void: # Rotate the subboard 90 degrees clockwise
	# New cells initializaiton
	var new_cells: Array = []
	_cells_initializaiton(new_cells)
	
	# Fill in the new cells
	for i in range(size):
		for j in range(size):
			new_cells[size - 1 - j][i] = cells[i][j]
	
	# Update the cells
	cells = new_cells
