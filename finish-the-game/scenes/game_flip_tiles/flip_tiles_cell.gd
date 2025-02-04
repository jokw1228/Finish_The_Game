extends TextureButton
class_name FlipTilesCell

@export var sprite_off: Texture2D = load("res://resources/images/game_flip_tiles/tile_off_s.png")
@export var sprite_on: Texture2D = load("res://resources/images/game_flip_tiles/tile_on_s.png")

var current_flip_state: bool = false

var _internal_pos: int = 0

signal press_tile(pos: int)

func set_internal_pos(index: int) -> void:
	print(index, current_flip_state)
	_internal_pos = index
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_normal = sprite_on
	pass # Replace with function body.
	
	
func _on_pressed() -> void:
	print("PRESSSSSSS")
	press_tile.emit(_internal_pos)
	pass
	
func change_tile_state() -> void:
	if(!current_flip_state):
		print("no")
		texture_normal = sprite_off
	else:
		print("yes")
		texture_normal = sprite_on
		
	current_flip_state = !current_flip_state
	print("internalPos = " + str(_internal_pos))
	
func change_tile_state_force(turn_on: bool) -> void:
	if(turn_on):
		texture_normal = sprite_on
	else:
		texture_normal = sprite_off
		
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
