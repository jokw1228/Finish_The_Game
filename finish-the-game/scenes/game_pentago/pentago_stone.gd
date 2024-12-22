extends Sprite2D
class_name PentagoStone

@export var sprite_black: Texture
@export var sprite_white: Texture

func set_color(color_to_set: int) -> void:
	if color_to_set == 1:
		texture = sprite_black
	elif color_to_set == 2:
		texture = sprite_white
