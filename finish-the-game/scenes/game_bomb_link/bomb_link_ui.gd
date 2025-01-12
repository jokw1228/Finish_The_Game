extends Node2D
class_name BombLinkUI

const width = 4
const height = 10

const cell_image_size = 128.0

func receive_request_insert_bomb_row_bottom(bomb_row_to_insert: Array) -> void:
	pass

func receive_request_append_bomb_row_top(bomb_row_to_append: Array) -> void:
	pass
