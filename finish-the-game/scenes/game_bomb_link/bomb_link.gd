extends Node2D
class_name BombLink

const width = 4
const height = 10 # 게임오버되지 않는 선에서 폭탄이 존재 가능한 높이 + 1인 값임.

var board: Array[Array] = []

signal request_insert_bomb_row_bottom(bomb_row_to_insert: Array[BombLinkBomb])
signal request_append_bomb_row_top(bomb_row_to_append: Array[BombLinkBomb])
signal request_chain_reaction(chain_reaction_to_execute: Array)

signal approve_and_reply_bomb_rotation(approved_index: Array[int])
signal deny_and_reply_bomb_rotation(denied_index: Array[int])

func _ready() -> void:
	initialize_board()
	
	## dummy codes for test
	for y: int in range(height):
		var temp: Array[BombLinkBomb] = []
		for x: int in range(width):
			var type: BombLinkBomb.BOMB_TYPE = \
			[BombLinkBomb.BOMB_TYPE.NORMAL, BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE]\
			.pick_random() as BombLinkBomb.BOMB_TYPE
			var fuse: BombLinkBomb.FUSE_DIRECTION = \
			[BombLinkBomb.FUSE_DIRECTION.RIGHT, BombLinkBomb.FUSE_DIRECTION.UP, \
			BombLinkBomb.FUSE_DIRECTION.LEFT, BombLinkBomb.FUSE_DIRECTION.DOWN]\
			.pick_random() as BombLinkBomb.FUSE_DIRECTION
			temp.append(BombLinkBomb.create(\
			type, \
			fuse\
			))
		insert_bomb_row_bottom(temp)
	
	await get_tree().create_timer(1.0).timeout
	drop_fire(LEFT_OR_RIGHT.LEFT)

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
				apply_gravity()

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
	
	var chain_reaction: Array = []
	
	var ignite_candidates: Array[Array] = []
	ignite_candidates.append(index_to_ignite)
	
	while ignite_candidates.size() != 0: # 좀 불확실한 코드임
		var chain_targets: Array[Array] = []
		var new_ignite_candidates: Array[Array] = []
		
		for ignite_target: Array[int] in ignite_candidates:
			var _x: int = ignite_target[0] as int
			var _y: int = ignite_target[1] as int
			
			exploded[_y][_x] = true
			
			# check right bomb
			if _x+1 < width:
				if exploded[_y][_x+1] == false:
					if board[_y][_x+1].fuse_direction == BombLinkBomb.FUSE_DIRECTION.LEFT:
						var chain_target: Array[int] = [_x+1, _y] as Array[int]
						chain_targets.append(chain_target)
						new_ignite_candidates.append(chain_target)
			
			# check uppper bomb
			if _y-1 >= 0:
				if exploded[_y-1][_x] == false:
					if board[_y-1][_x].fuse_direction == BombLinkBomb.FUSE_DIRECTION.DOWN:
						var chain_target: Array[int] = [_x, _y-1] as Array[int]
						chain_targets.append(chain_target)
						new_ignite_candidates.append(chain_target)
			
			# check left bomb
			if _x-1 >= 0:
				if exploded[_y][_x-1] == false:
					if board[_y][_x-1].fuse_direction == BombLinkBomb.FUSE_DIRECTION.RIGHT:
						var chain_target: Array[int] = [_x-1, _y] as Array[int]
						chain_targets.append(chain_target)
						new_ignite_candidates.append(chain_target)
			
			# check lower bomb
			if _y+1 < height:
				if exploded[_y+1][_x] == false:
					if board[_y+1][_x].fuse_direction == BombLinkBomb.FUSE_DIRECTION.UP:
						var chain_target: Array[int] = [_x, _y+1] as Array[int]
						chain_targets.append(chain_target)
						new_ignite_candidates.append(chain_target)
		
		chain_reaction.append(chain_targets)
		request_chain_reaction.emit(chain_reaction)

func receive_request_bomb_rotation(index_to_request: Array[int]) -> void:
	var _x: int = index_to_request[0]
	var _y: int = index_to_request[1]
	if board[_y][_x] == null:
		deny_and_reply_bomb_rotation.emit(index_to_request)
		print("있지도 않은 셀 클릭 신호가 들어옴. 뭔가 심각한 버그가 있는 상황임.")
	elif board[_y][_x].bomb_type == BombLinkBomb.BOMB_TYPE.NORMAL:
		approve_and_reply_bomb_rotation.emit(index_to_request)
	else:
		deny_and_reply_bomb_rotation.emit(index_to_request)
