extends Sprite2D
class_name FlipTilesSourceTile

@export var sprite_off: Texture
@export var sprite_on: Texture

var current_tile_state: FlipTiles.TILE_STATE = FlipTiles.TILE_STATE.ON



func set_flip_state() -> void:
	if current_tile_state == FlipTiles.TILE_STATE.ON:
		print("do")
		texture = sprite_off
		#$"FlipTilesSourcetile".texture = sprite_off
		
		current_tile_state = FlipTiles.TILE_STATE.OFF
	else:
		texture = sprite_on
		#$"FlipTilesSourcetile".texture = sprite_on
		current_tile_state = FlipTiles.TILE_STATE.ON
		
	
	
func get_flip_state() -> FlipTiles.TILE_STATE:
	return current_tile_state
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = sprite_on# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
