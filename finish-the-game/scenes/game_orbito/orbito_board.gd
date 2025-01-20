extends Sprite2D
class_name OrbitoBoard

const board_size = 4
const cell_size = 128

@export var cells_to_export: Array[OrbitoCell] = []
var cells: Array[Array] = []
var cells_direction: Array[Array] = []

signal request_select_cell(cell_index: Array[int])

func _ready() -> void:
	# set cells array
	for y in range(board_size):
		var temp: Array[OrbitoCell] = []
		for x in range(board_size):
			temp.append(cells_to_export[x+y*board_size])
		cells.append(temp)
	set_cells_direction()
	#print(cells_direction)
	return
	
func set_cells_direction() -> void:
	var temp = []
	for y: int in range(board_size/2):
		temp = []
		for x: int in range(board_size):
			if (x <= y):
				temp.append(Vector2(0,1))
			elif (x > board_size - 1 - y):
				temp.append(Vector2(0,-1))
			else:
				temp.append(Vector2(-1,0))
		cells_direction.append(temp)
	for y: int in range(board_size/2,board_size):
		temp = []
		for x: int in range(board_size):
			if (x >= y):
				temp.append(Vector2(0,-1))
			elif (x < board_size - 1 - y):
				temp.append(Vector2(0,1))
			else:
				temp.append(Vector2(1,0))
		cells_direction.append(temp)
		
func orbit_cells() -> void:
	var orbited_cells: Array[Array] = cells.duplicate(true)
	for y: int in range(board_size/2):
		for x: int in range(board_size):
			if (x < y):
				orbited_cells[x][y] = cells[x][y-1]
			elif (x >= board_size - 1 - y):
				orbited_cells[x][y] = cells[x][y+1]
			else:
				orbited_cells[x][y] = cells[x+1][y]
			var temp: Array[int] = [x,y]
			orbited_cells[x][y].set_cell_index(temp)
	for y: int in range(board_size/2,board_size):
		for x: int in range(board_size):
			if (x > y):
				orbited_cells[x][y] = cells[x][y+1]
			elif (x <= board_size - 1 - y):
				orbited_cells[x][y] = cells[x][y-1]
			else:
				orbited_cells[x][y] = cells[x-1][y]
			var temp: Array[int] = [x,y]
			orbited_cells[x][y].set_cell_index(temp)
	cells = orbited_cells.duplicate(true)

func receive_select_cell(cell_index: Array[int]):
	request_select_cell.emit(cell_index)
	return
	
func receive_request_place_stone(cell_index: Array[int], color_to_place: Orbito.CELL_STATE):
	var _x = cell_index[0]
	var _y = cell_index[1]
	cells[_x][_y].place_stone(color_to_place)
	return
	
func receive_request_move_stone(start_cell_index: Array[int], end_cell_index: Array[int], color_to_move: Orbito.CELL_STATE):
	_on_orbito_ui_request_set_cells_disabled(true)
	var tween = get_tree().create_tween().set_parallel(true)
	var start_x = start_cell_index[0]
	var start_y = start_cell_index[1]
	var end_x = end_cell_index[0]
	var end_y = end_cell_index[1]
	var start_cell = cells[start_x][start_y]
	var start_cell_position = start_cell.position
	var end_cell = cells[end_x][end_y]
	var end_cell_position = end_cell.position
	tween.tween_property(start_cell,"position",end_cell_position,0.25)
	tween.tween_property(end_cell,"position",start_cell_position,0.25)
	var temp: Array[int] = [end_x, end_y]
	start_cell.set_cell_index(temp)
	temp = [start_x, start_y]
	end_cell.set_cell_index(temp)
	cells[start_x][start_y] = end_cell
	cells[end_x][end_y] = start_cell
	await tween.finished
	_on_orbito_ui_request_set_cells_disabled(false)
	return
	'''
	var start_x = start_cell_index[0]
	var start_y = start_cell_index[1]
	var end_x = end_cell_index[0]
	var end_y = end_cell_index[1]
	cells[start_x][start_y].remove_stone()
	cells[end_x][end_y].place_stone(color_to_move)
	return
	'''
	'''
func move_stone_ui(start_cell_index: Array[int], end_cell_index: Array[int]) -> void:
	var tween = get_tree().create_tween().set_parallel(true)
	var start_x = start_cell_index[0]
	var start_y = start_cell_index[1]
	var end_x = end_cell_index[0]
	var end_y = end_cell_index[1]
	var start_cell = cells[start_x][start_y]
	var start_cell_position = start_cell.position
	var end_cell = cells[end_x][end_y]
	var end_cell_position = end_cell.position
	tween.tween_property(start_cell,"position",end_cell_position,0.5)
	tween.tween_property(end_cell,"position",start_cell_position,0.5)
	var temp: Array[int] = [end_x, end_y]
	start_cell.set_cell_index(temp)
	temp = [start_x, start_y]
	end_cell.set_cell_index(temp)
	return
	'''
	
func receive_request_orbit_ui() -> void:
	_on_orbito_ui_request_set_cells_disabled(true)
	var tween = get_tree().create_tween().set_parallel(true)
	for x in range(board_size):
		for y in range(board_size):
			var to_move = cells_direction[y][x] * cell_size
			tween.tween_property(cells[x][y],"position",cells[x][y].position + to_move, 0.25)
	orbit_cells()
	await tween.finished
	_on_orbito_ui_request_set_cells_disabled(false)
	return

func receive_request_remove_stone(cell_index: Array[int]):
	var _x = cell_index[0]
	var _y = cell_index[1]
	cells[_x][_y].remove_stone()
	return

func _on_orbito_ui_request_set_cells_disabled(disable) -> void:
	for x in range(board_size):
		for y in range(board_size):
			cells[x][y].set_cell_disabled(disable)
