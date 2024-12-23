extends Node2D
class_name PentagoSubBoard

const cell_image_size = 128.0 # pixel size
const rotation_animation_time = 0.2

signal rotation_finished

var size: int = 3 # default: 3 x 3 matrix
var cells: Array = [] # cells[y][x], right: x+, down: y+
# 0: empty, 1: black, 2: white
# cells <- absolute coordinate systems

func _ready() -> void:
	# Cells initialization
	_cells_initializaiton(cells)

func _cells_initializaiton(array_to_init: Array): # Cells initialization (filling it with zero)
	for i in range(size):
		var temp: Array[int] = []
		for j in range(size):
			temp.append(0)
		array_to_init.append(temp)

func put_stone(absolute_position_to_put: Vector2, color_to_put: int) -> bool: # Put the stones to reflect the current rotation coordinate system.
	# absolute_position_to_put: player's perspective
	
	# Check if there is already a stone
	if cells[absolute_position_to_put.y][absolute_position_to_put.x] != 0:
		return false
	else:
		# Update the cells
		cells[absolute_position_to_put.y][absolute_position_to_put.x] = color_to_put
		
		# just put the stone by absolute position(player's perspective)
		var stone_position: Vector2 \
		= Vector2((absolute_position_to_put.x - (float(size) - 1) / 2.0) * cell_image_size, \
		(absolute_position_to_put.y - (float(size) - 1) / 2.0) * cell_image_size)
		stone_position = stone_position.rotated(-self.rotation) # Absolutely!!
		var stone: PentagoStone = PentagoStoneCreator.create(stone_position, color_to_put)
		add_child(stone)
		
		return true
	

func rotate_ccw() -> void: # Rotate the subboard 90 degrees counterclockwise
	# New cells initializaiton
	var new_cells: Array = []
	_cells_initializaiton(new_cells)
	
	# Fill in the new cells
	for i in range(size):
		for j in range(size):
			#new_cells[j][size - 1 - i] = cells[i][j] # right-hand rule
			new_cells[size - 1 - j][i] = cells[i][j] # left-hand rule
	
	# Update the cells
	cells = new_cells
	
	# Node rotation
	var tween_rotation: Tween = get_tree().create_tween()
	tween_rotation.tween_property(self, "rotation", rotation-PI/2, rotation_animation_time)
	#rotate(-PI/2) # left-hand rule
	await tween_rotation.finished
	rotation_finished.emit()

func rotate_cw() -> void: # Rotate the subboard 90 degrees clockwise
	# New cells initializaiton
	var new_cells: Array = []
	_cells_initializaiton(new_cells)
	
	# Fill in the new cells
	for i in range(size):
		for j in range(size):
			#new_cells[size - 1 - j][i] = cells[i][j]
			new_cells[j][size - 1 - i] = cells[i][j]
	
	# Update the cells
	cells = new_cells
	
	# Node rotation
	var tween_rotation: Tween = get_tree().create_tween()
	tween_rotation.tween_property(self, "rotation", rotation+PI/2, rotation_animation_time)
	#rotate(PI/2) # right-hand rule
	await tween_rotation.finished
	rotation_finished.emit()
