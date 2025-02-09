extends Node2D
class_name RushHourBoard

@export var tile_texture = preload("res://resources/images/game_rush_hour/rh_tile_new.png")
@export var target_texture = preload("res://resources/images/game_rush_hour/sprite_rush_hour_target.png")
var tile_size = 128  
var grid_size = 6       # 6x6 grid
var exit_pos = Vector2(0,0)
var target_pos_offset = 64+32
var x_offset = -30


# Called when the node enters the scene tree for the first time.
func _on_rush_hour_start(target_position: Vector2, player_direction: int):
	var grid_width = grid_size * tile_size
	var grid_height = grid_size * tile_size
	var viewport_size = get_viewport_rect().size
	#var start_position = Vector2(
	#	(viewport_size.x - grid_width/2) / 2,
	#	(viewport_size.y - grid_height-grid_height/2) / 2
	#)
	#var start_position =  Vector2(-320+30,-320+64)
	var start_position =  Vector2(-320+30+x_offset,-320+64)
	for row in range(grid_size):
		for col in range(grid_size):
			var tile = Sprite2D.new()
			tile.texture = tile_texture
			tile.position = start_position + Vector2(col * tile_size, row * tile_size)
			add_child(tile)
			if row == target_position.y and col == target_position.x:
				var target = Sprite2D.new()
				target.texture = target_texture
				#exit is always at top or left side of board
				# top: row == 0 right: col == 5
				if target_position.y == 0 and target_position.x !=0:
					target.position = start_position + Vector2(col * tile_size, row * tile_size-target_pos_offset)
				elif target_position.x == 5:
					target.rotation_degrees = 90
					target.position = start_position + Vector2(col * tile_size+target_pos_offset, row * tile_size)
				add_child(target)
