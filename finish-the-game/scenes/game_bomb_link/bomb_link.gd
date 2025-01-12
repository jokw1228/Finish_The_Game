extends Node2D
class_name BombLink

const width = 4
const height = 10 # 게임오버되지 않는 선에서 폭탄이 존재 가능한 높이 + 1인 값임.

var board: Array[Array] = []

signal request_insert_bomb_row_bottom(bomb_row_to_insert: Array)
signal request_append_bomb_row_top(bomb_row_to_append: Array)

func _ready() -> void:
	initialize_board()
	
	## dummy codes for test
	for y: int in range(height):
		var temp: Array[BombLinkBomb] = []
		for x: int in range(width):
			var fuse: BombLinkBomb.FUSE_DIRECTION = \
			[BombLinkBomb.FUSE_DIRECTION.RIGHT, BombLinkBomb.FUSE_DIRECTION.UP, \
			BombLinkBomb.FUSE_DIRECTION.LEFT, BombLinkBomb.FUSE_DIRECTION.DOWN]\
			.pick_random() as BombLinkBomb.FUSE_DIRECTION
			temp.append(BombLinkBomb.create(\
			BombLinkBomb.BOMB_TYPE.NORMAL, \
			fuse\
			))
		insert_bomb_row_bottom(temp)

func initialize_board() -> void:
	for y: int in range(height):
		var temp: Array[BombLinkBomb] = []
		for x: int in range(width):
			temp.append(null)
		board.append(temp)

func insert_bomb_row_bottom(bomb_row_to_insert: Array[BombLinkBomb]) -> void:
	var inserted_board: Array[Array] = []
	for y: int in range(1, height):
		var temp: Array[BombLinkBomb] = []
		for x: int in range(width):
			temp.append(board[y][x])
		inserted_board.append(temp)
	inserted_board.append(bomb_row_to_insert)
	
	board = inserted_board
	request_insert_bomb_row_bottom.emit(bomb_row_to_insert)

func append_bomb_row_top(bomb_row_to_append: Array[BombLinkBomb]) -> void:
	var appended_board: Array[Array] = []
	appended_board.append(bomb_row_to_append)
	for y: int in range(1, height):
		var temp: Array[BombLinkBomb] = []
		for x: int in range(width):
			temp.append(board[y][x])
		appended_board.append(temp)
	
	board = appended_board
	request_append_bomb_row_top.emit(bomb_row_to_append)
	
	apply_gravity()

func apply_gravity() -> void:
	var flag: bool = true
	while(flag == true):
		var last_board: Array[Array] = board.duplicate(true)
		
		for y: int in range(height-2, -1, -1):
			for x: int in range(width):
				if board[y][x] != null:
					# switch(BOMB_TYPE)
					if board[y][x].bomb_type == BombLinkBomb.BOMB_TYPE.NORMAL \
					or board[y][x].bomb_type == BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE:
						if board[y+1][x] != null:
							board[y+1][x] = board[y][x]
							board[y][x] = null
		
		flag = false
		for y: int in range(height):
			for x: int in range(width):
				if board[y][x] != last_board[y][x]:
					flag = true
					break
			if flag == true:
				break
