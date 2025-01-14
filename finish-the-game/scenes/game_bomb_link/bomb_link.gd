extends Node2D
class_name BombLink

const width = 4
const height = 10 # 게임오버되지 않는 선에서 폭탄이 존재 가능한 높이 + 1인 값임.

var board: Array[Array] = []

signal request_insert_bomb_row_bottom(bomb_row_to_insert: Array[BombLinkBomb])
signal request_append_bomb_row_top(bomb_row_to_append: Array[BombLinkBomb])
signal request_apply_gravity(move_commands_to_execute: Array[BombLinkMoveCommand])
signal request_chain_reaction(chain_reaction_to_execute: BombLinkChainReaction)

signal approve_and_reply_bomb_rotation(approved_index: Array[int])
signal deny_and_reply_bomb_rotation(denied_index: Array[int])

func _ready() -> void:
	initialize_board()

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
	var move_commands: Array[BombLinkMoveCommand] = []
	for x: int in range(width):
		for y: int in range(height-2, -1, -1):
			if board[y][x] != null:
				var y_offset: int = 1
				while board[y+y_offset][x] != null:
					y_offset += 1
					if y+y_offset >= height:
						break
				y_offset -= 1
				if y_offset > 0:
					board[y+y_offset][x] = board[y][x]
					board[y][x] = null
					move_commands.append(BombLinkMoveCommand.create([x, y] as Array[int], y_offset))
	
	request_apply_gravity.emit(move_commands)

enum LEFT_OR_RIGHT {LEFT, RIGHT}
func drop_fire(side: LEFT_OR_RIGHT) -> void:
	var _x: int
	var _fuse_direction: BombLinkBomb.FUSE_DIRECTION
	if side == LEFT_OR_RIGHT.LEFT:
		_x = 0
		_fuse_direction = BombLinkBomb.FUSE_DIRECTION.LEFT
	elif side == LEFT_OR_RIGHT.RIGHT:
		_x = width - 1
		_fuse_direction = BombLinkBomb.FUSE_DIRECTION.RIGHT
	
	for y: int in range(height):
		if board[y][_x] != null:
			if board[y][_x].fuse_direction == _fuse_direction:
				ignite_chain_reaction([_x, y] as Array[int])
				#apply_gravity()

func ignite_chain_reaction(index_to_ignite: Array[int]) -> void:
	var exploded: Array[Array] = []
	for y: int in range(height):
		var temp: Array[bool] = []
		for x: int in range(width):
			if board[y][x] == null:
				temp.append(true)
			else:
				temp.append(false)
		exploded.append(temp)
	
	var chain_reaction: BombLinkChainReaction = BombLinkChainReaction.new()
	
	var ignite_targets: Array[Array] = []
	ignite_targets.append(index_to_ignite)
	
	while !ignite_targets.is_empty():
		chain_reaction.append_step(ignite_targets)
		var next_ignite_targets: Array[Array] = []
		
		for ignite_target: Array[int] in ignite_targets:
			var _x: int = ignite_target[0] as int
			var _y: int = ignite_target[1] as int
			
			exploded[_y][_x] = true
			
			# check right bomb
			if _x+1 < width:
				if exploded[_y][_x+1] == false:
					if board[_y][_x+1].fuse_direction == BombLinkBomb.FUSE_DIRECTION.LEFT:
						next_ignite_targets.append([_x+1, _y] as Array[int])
			
			# check uppper bomb
			if _y-1 >= 0:
				if exploded[_y-1][_x] == false:
					if board[_y-1][_x].fuse_direction == BombLinkBomb.FUSE_DIRECTION.DOWN:
						next_ignite_targets.append([_x, _y-1] as Array[int])
			
			# check left bomb
			if _x-1 >= 0:
				if exploded[_y][_x-1] == false:
					if board[_y][_x-1].fuse_direction == BombLinkBomb.FUSE_DIRECTION.RIGHT:
						next_ignite_targets.append([_x-1, _y] as Array[int])
			
			# check lower bomb
			if _y+1 < height:
				if exploded[_y+1][_x] == false:
					if board[_y+1][_x].fuse_direction == BombLinkBomb.FUSE_DIRECTION.UP:
						next_ignite_targets.append([_x, _y+1] as Array[int])
		
		ignite_targets = next_ignite_targets
		
	request_chain_reaction.emit(chain_reaction)

func receive_request_bomb_rotation(index_to_request: Array[int]) -> void:
	var _x: int = index_to_request[0]
	var _y: int = index_to_request[1]
	if board[_y][_x] == null:
		deny_and_reply_bomb_rotation.emit(index_to_request)
		print("있지도 않은 셀 클릭 신호가 들어옴. 뭔가 심각한 버그가 있는 상황임.")
	elif board[_y][_x].bomb_type == BombLinkBomb.BOMB_TYPE.NORMAL:
		board[_y][_x].rotate_cw()
		approve_and_reply_bomb_rotation.emit(index_to_request)
	else:
		deny_and_reply_bomb_rotation.emit(index_to_request)
