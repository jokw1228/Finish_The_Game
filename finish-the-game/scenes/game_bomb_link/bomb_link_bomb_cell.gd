extends Node2D
class_name BombLinkBombCell

const BombLinkBombCellNormal_scene = "res://scenes/game_bomb_link/bomb_link_bomb_cell_normal.tscn"

var index: Array[int]

static func create(\
bomb_type_to_create: BombLinkBomb.BOMB_TYPE, \
fuse_direction_to_set, \
position_to_set: Vector2, \
index_to_set: Array[int], \
function_to_connect: Callable\
) -> BombLinkBombCell: # for NORMAL, NOT_ROTATABLE
	var inst: BombLinkBombCell
	if bomb_type_to_create == BombLinkBomb.BOMB_TYPE.NORMAL:
		inst = preload(BombLinkBombCellNormal_scene).instantiate() as BombLinkBombCell
	
	inst.position = position_to_set
	inst.set_index(index_to_set)
	inst.connect_signal(function_to_connect)
	
	return inst

func set_index(index_to_set: Array[int]) -> void:
	index = index_to_set

func connect_signal(function_to_connect: Callable) -> void:
	pass
