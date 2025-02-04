extends FlipTiles
class_name FTGFlipTiles

signal end_ftg(is_game_cleared: bool)
signal request_disable_input()

signal do_randomize(times: int)

signal disable_click()

signal start_timer(duration: float)
signal pause_timer()

func start_ftg() -> void:
	
	print("apapapapapapp")
	var ui = get_node("FlipTilesUi")
	ui.set_board_size(5, 5)
	ui.init_board()
	
	ui.randomize_board(5)
	
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
