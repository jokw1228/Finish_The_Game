extends BombLink
class_name FTGBombLink

signal end_ftg(is_game_cleared: bool)

signal start_timer(duration: float)

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
			
			temp.append(BombLinkBomb.create(type, fuse))
		insert_bomb_row_bottom(temp)
	
	var left_or_right: LEFT_OR_RIGHT = [LEFT_OR_RIGHT.LEFT, LEFT_OR_RIGHT.RIGHT].pick_random()
	const duration: float = 3.0
	drop_fire(left_or_right, duration)
	start_timer.emit(duration)


func _on_bomb_link_ui_all_action_is_ended() -> void:
	await get_tree().create_timer(0.2).timeout
	end_ftg.emit(true)
