extends BombLink
class_name FTGBombLink

signal request_disable_input()
signal end_ftg(is_game_cleared: bool)

func start_ftg() -> void:
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
	
	await get_tree().create_timer(5.0).timeout
	drop_fire(LEFT_OR_RIGHT.LEFT)
	
	await get_tree().create_timer(1.0).timeout
	end_ftg.emit(true)
