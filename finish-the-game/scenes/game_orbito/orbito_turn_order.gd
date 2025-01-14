extends Sprite2D
class_name OrbitoTurnOrder

@export var sprite_black: Texture
@export var sprite_white: Texture


func _ready() -> void:
	texture = sprite_black

func set_color(color_to_set):
	if (color_to_set == OrbitoUI.TURN_COLOR.BLACK):
		texture = sprite_black
	elif (color_to_set == OrbitoUI.TURN_COLOR.WHITE):
		texture = sprite_white
