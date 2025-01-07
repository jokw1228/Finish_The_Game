extends Node2D
class_name FTGPentagoUI

@export var ColorToPlace_node: Sprite2D

@export var sprite_black: Texture
@export var sprite_white: Texture

func receive_request_set_color(color_to_place: Pentago.CELL_STATE) -> void:
	if color_to_place == Pentago.CELL_STATE.BLACK:
		ColorToPlace_node.texture = sprite_black
	elif color_to_place == Pentago.CELL_STATE.WHITE:
		ColorToPlace_node.texture = sprite_white
