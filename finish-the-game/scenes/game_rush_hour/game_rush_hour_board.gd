extends Node2D
class_name RushHourBoard

@export var tile_texture_path = preload("res://sprites/sprite_rush_hour_tile.png")
@export var tile_size = 128  
@export var grid_size = 6       # 6x6 grid

# Called when the node enters the scene tree for the first time.
func _ready():
	var tile_texture = tile_texture_path
	for row in range(grid_size):
		for col in range(grid_size):
			var tile = Sprite2D.new()
			tile.texture = tile_texture
			tile.position = Vector2(col * tile_size, row * tile_size)
			add_child(tile)
