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
	
	if(difficulty <= 0.3):
		flip_tile_count = 3
	elif(difficulty <= 0.7):
		flip_tile_count = 4
	else:
		flip_tile_count = 5
	
	if(difficulty <= 0.2):
		board_size = 3
	elif(difficulty <= 0.6):
		board_size = 4
	else:
		board_size = 5
	
	
	ui.set_board_size(board_size, board_size)
	ui.init_board()
	ui.randomize_board(flip_tile_count)
	
	start_timer.emit(6)

	

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
