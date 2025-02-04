extends Node2D
class_name FlipTilesUI

var board_ui: FlipTilesBoard
var board_size: int

const tile_size: int = 128

var board_size_h: int
var board_size_v: int

var flip_tiles_array: Array[FlipTilesCell]

var init_tile: = load("res://scenes/game_flip_tiles/flip_tiles_cell.tscn")

signal flip_board_data(pos: int)
signal init_board_data(h: int, v: int)

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



	
func set_board_size(size_h: int, size_v: int) -> void:
	board_size_h = size_h
	board_size_v = size_v
	
	
	
func randomize_board(flip_count: int) -> void:
	var random_list: Array[int]
	for i in range(board_size_v * board_size_h):
		random_list.append(i)
		
	for i in range(0, flip_count):
		var ran: int = rng.randi_range(0, len(random_list) - 1)
		var random_position: int = random_list[ran]
		
		print(random_position)
		flip_board(random_position)
		flip_board_data.emit(random_position)
		
		random_list.remove_at(ran)


func init_board() -> void:
	rng.randomize()
	init_board_data.emit(board_size_h, board_size_v)
	var board_ui_grid = get_node("Board/GridContainer")
	board_ui_grid.columns = board_size_h
	var board_size_vector: Vector2 = Vector2(board_size_h * tile_size, board_size_v * tile_size)
	var board_pos_vector: Vector2 = Vector2(board_size_h * tile_size * -1 * 0.5, board_size_v * tile_size * -1 * 0.5)
	board_ui_grid.size = board_size_vector
	board_ui_grid.position = board_pos_vector
	for i in range(0, board_size_h * board_size_v):
		var tile
		tile = init_tile.instantiate()
		
		print(tile.name)
		flip_tiles_array.append(tile)
		board_ui_grid.add_child(flip_tiles_array[i])
		tile.connect("press_tile", Callable(self, "tile_pressed"))
		tile.set_internal_pos(i)
		
		
func flip_board(index: int) -> void:
	if int(index / board_size_h) != 0:
		flip_tiles_array[index - board_size_h].change_tile_state()
	if int(index / board_size_h) != board_size_v - 1:
		flip_tiles_array[index + board_size_h].change_tile_state()
	
	if index % board_size_h != 0:
		flip_tiles_array[index - 1].change_tile_state()
	if index % board_size_h != board_size_h - 1:
		flip_tiles_array[index + 1].change_tile_state()
	
	# Self-change
	flip_tiles_array[index].change_tile_state()
	
func game_ended() -> void:
	for tile in flip_tiles_array:
		tile.disconnect("press_tile", Callable(self, "tile_pressed"))
	pass
	
	
func tile_pressed(index: int) -> void:
	flip_board(index)
	flip_board_data.emit(index)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ftg_flip_tiles_request_disable_input() -> void:
	for tile in flip_tiles_array:
		tile.disabled = true
		tile.disconnect("press_tile", Callable(self, "tile_pressed"))
	pass # Replace with function body.
