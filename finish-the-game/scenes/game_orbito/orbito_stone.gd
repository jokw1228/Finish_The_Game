extends Sprite2D
class_name OrbitoStone

@export var sprite_black: Texture
@export var sprite_white: Texture

func set_color(color_to_place: Orbito.CELL_STATE) -> void:
	if color_to_place == Orbito.CELL_STATE.BLACK:
		texture = sprite_black
	elif color_to_place == Orbito.CELL_STATE.WHITE:
		texture = sprite_white

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_rotation = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_rotation = 0
