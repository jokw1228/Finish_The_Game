extends Node2D
class_name FlipTiles

signal end_game()

var rng = RandomNumberGenerator.new()
var board : Array[TILE_STATE] = []
var board_size : int = 5
var board_size_h : int
var board_size_v : int
var board_ui : FlipTilesBoard

enum TILE_STATE
{
	OFF,
	ON
}

func change_tile_state(pos: int) -> void:
	if board[pos] == TILE_STATE.OFF:
		board[pos] = TILE_STATE.ON
	else:
		board[pos] = TILE_STATE.OFF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
	# Replace with function body.
	

func init_board(h: int, v: int) -> void:
	board_size_h = h
	board_size_v = v
	for i in range(0, board_size_h * board_size_v):
		print("d")
		board.append(TILE_STATE.ON)
		

	
func randomize_board(flip_count: int) -> void:
	for i in range(0, flip_count):
		flip_board(rng.randi_range(0, board_size_h * board_size_v - 1))

	
func tile_pressed(index: int) -> void:
	flip_board(index)
	check_board()

func flip_board(index: int) -> void:
	if int(index / board_size_h) != 0:
		change_tile_state(index - board_size_h)
	if int(index / board_size_h) != board_size_v - 1:
		change_tile_state(index + board_size_h)
	
	if index % board_size_h != 0:
		change_tile_state(index - 1)
	if index % board_size_h != board_size_h - 1:
		change_tile_state(index + 1)
	
	# Self-change
	change_tile_state(index)
	
	print(board)
	
	check_board()
		
		
	


func check_board() -> void:
	for i in range(board_size_h * board_size_v):
		if(board[i] == TILE_STATE.OFF):
			print("BRUH")
			return
	
	end_game.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
