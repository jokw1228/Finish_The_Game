extends BombLink
class_name FTGBombLink

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)

func start_ftg() -> void:
	var last_row: Array[BombLinkBomb]
	for y: int in range(height):
		var current_row: Array[BombLinkBomb] = []
		for x: int in range(width):
			'''
			var type: BombLinkBomb.BOMB_TYPE = \
			[BombLinkBomb.BOMB_TYPE.NORMAL, BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE]\
			.pick_random() as BombLinkBomb.BOMB_TYPE
			'''
			var type: BombLinkBomb.BOMB_TYPE
			if x != 0 and x != width - 1 and y != 0 and y != height - 1:
				var type_candidates: Array[BombLinkBomb.BOMB_TYPE] = \
				[BombLinkBomb.BOMB_TYPE.NORMAL, BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE]
				var w: float = RandomNumberGenerator.new().randf_range(0, 1)
				type = type_candidates[0] if w < 0.4 \
				else type_candidates[1]
			else:
				type = BombLinkBomb.BOMB_TYPE.NORMAL
			
			'''
			var fuse: BombLinkBomb.FUSE_DIRECTION = \
			[BombLinkBomb.FUSE_DIRECTION.RIGHT, BombLinkBomb.FUSE_DIRECTION.UP, \
			BombLinkBomb.FUSE_DIRECTION.LEFT, BombLinkBomb.FUSE_DIRECTION.DOWN]\
			.pick_random() as BombLinkBomb.FUSE_DIRECTION
			'''
			var fuse: BombLinkBomb.FUSE_DIRECTION
			if type == BombLinkBomb.BOMB_TYPE.NORMAL:
				fuse = \
				[BombLinkBomb.FUSE_DIRECTION.RIGHT, BombLinkBomb.FUSE_DIRECTION.UP, \
				BombLinkBomb.FUSE_DIRECTION.LEFT, BombLinkBomb.FUSE_DIRECTION.DOWN]\
				.pick_random() as BombLinkBomb.FUSE_DIRECTION
			elif type == BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE:
				var fuse_candidates: Array[BombLinkBomb.BOMB_TYPE] = []
				
				fuse_candidates.append(BombLinkBomb.FUSE_DIRECTION.RIGHT)
				
				fuse_candidates.append(BombLinkBomb.FUSE_DIRECTION.UP)
				
				if current_row[x-1].bomb_type == BombLinkBomb.BOMB_TYPE.NORMAL \
				or (current_row[x-1].bomb_type == BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE \
				and current_row[x-1].fuse_direction != BombLinkBomb.FUSE_DIRECTION.RIGHT):
					fuse_candidates.append(BombLinkBomb.FUSE_DIRECTION.LEFT)
				
				if last_row[x].bomb_type == BombLinkBomb.BOMB_TYPE.NORMAL \
				or (last_row[x].bomb_type == BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE \
				and last_row[x].fuse_direction != BombLinkBomb.FUSE_DIRECTION.UP):
					fuse_candidates.append(BombLinkBomb.FUSE_DIRECTION.DOWN)
				
				fuse = fuse_candidates.pick_random()
			
			current_row.append(BombLinkBomb.create(type, fuse))
		insert_bomb_row_bottom(current_row)
		last_row = current_row.duplicate(true)
	
	var left_or_right: LEFT_OR_RIGHT = [LEFT_OR_RIGHT.LEFT, LEFT_OR_RIGHT.RIGHT].pick_random()
	const duration: float = 15.0
	drop_fire(left_or_right, duration)
	start_timer.emit(duration)


func _on_bomb_link_ui_all_action_is_ended() -> void:
	# check board is empty
	var flag: bool = true
	for y: int in range(height):
		for x: int in range(width):
			if board[y][x] != null:
				flag = false
				break
		if flag == false:
			break
	end_ftg.emit(flag)
