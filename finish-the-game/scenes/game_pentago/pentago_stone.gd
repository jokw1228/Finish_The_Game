extends Sprite2D
class_name PentagoStone

@export var sprite_black: Texture
@export var sprite_white: Texture

func set_color(color_to_place: Pentago.CELL_STATE) -> void:
	if color_to_place == Pentago.CELL_STATE.BLACK:
		texture = sprite_black
	elif color_to_place == Pentago.CELL_STATE.WHITE:
		texture = sprite_white

func _ready() -> void:
	global_rotation = 0

func _process(_delta: float) -> void:
	global_rotation = 0
