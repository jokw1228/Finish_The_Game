extends FlipTiles
class_name FTGFlipTiles

signal end_ftg(is_game_cleared: bool)
signal request_disable_input()

signal do_randomize(times: int)

signal disable_click()

signal start_timer(duration: float)
signal pause_timer()

func start_ftg(difficulty: float) -> void:
	
	print("apapapapapapp")
	var ui = get_node("FlipTilesUi")
	
	var flip_tile_count: int = 4
	var board_size: int = 4
	var time_limit: float = 6.0
	
	if difficulty < 0.2:
		flip_tile_count = 2
		board_size = 3
		time_limit = 9.0
	
	elif difficulty < 0.4:
		flip_tile_count = 2
		board_size = 4
		time_limit = 9.0
	
	elif difficulty < 0.6:
		flip_tile_count = 3
		board_size = 4
		time_limit = 9.0
	
	elif difficulty < 0.8:
		flip_tile_count = 3
		board_size = 5
		time_limit = 9.0
	
	elif difficulty >= 0.8:
		flip_tile_count = 3
		board_size = 5
		time_limit = 9.0 - (difficulty - 0.8) * 10
	
	
	ui.set_board_size(board_size, board_size)
	ui.init_board()
	ui.randomize_board(flip_tile_count)
	
	start_timer.emit(time_limit)

	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_end_game() -> void:
	print("_?")
	request_disable_input.emit()
	pause_timer.emit()
	disable_click.emit()
	end_ftg.emit(true)
	
func _on_game_utils_game_timer_timeout() -> void:
	request_disable_input.emit()
	disable_click.emit()
	end_ftg.emit(false)
