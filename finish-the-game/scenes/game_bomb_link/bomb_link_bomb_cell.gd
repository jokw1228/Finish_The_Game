extends TextureButton
class_name BombLinkBombCell

const BombLinkBombCellNormal_scene = "res://scenes/game_bomb_link/bomb_link_bomb_cell_normal.tscn"

var index: Array[int]

signal request_bomb_rotation(index_to_request: Array[int])

static func create(\
bomb_type_to_create: BombLinkBomb.BOMB_TYPE, \
fuse_direction_to_set: BombLinkBomb.FUSE_DIRECTION, \
position_to_set: Vector2, \
index_to_set: Array[int], \
function_to_connect: Callable\
) -> BombLinkBombCell: # for NORMAL, NOT_ROTATABLE
	var inst: BombLinkBombCell
	if bomb_type_to_create == BombLinkBomb.BOMB_TYPE.NORMAL:
		inst = preload(BombLinkBombCellNormal_scene).instantiate() as BombLinkBombCell
	elif bomb_type_to_create == BombLinkBomb.BOMB_TYPE.NOT_ROTATABLE:
		pass
	
	inst.position = position_to_set
	inst.set_fuse_direction(fuse_direction_to_set)
	inst.set_index(index_to_set)
	inst.connect_signal(function_to_connect)
	
	return inst

func set_fuse_direction(fuse_direction_to_set: BombLinkBomb.FUSE_DIRECTION) -> void:
	if fuse_direction_to_set == BombLinkBomb.FUSE_DIRECTION.RIGHT:
		rotation = 0
	elif fuse_direction_to_set == BombLinkBomb.FUSE_DIRECTION.UP:
		rotation = -PI/2
	elif fuse_direction_to_set == BombLinkBomb.FUSE_DIRECTION.LEFT:
		rotation = PI
	elif fuse_direction_to_set == BombLinkBomb.FUSE_DIRECTION.DOWN:
		rotation = PI/2

func set_index(index_to_set: Array[int]) -> void:
	index = index_to_set

func connect_signal(function_to_connect: Callable) -> void:
	request_bomb_rotation.connect(function_to_connect)

func _on_pressed() -> void:
	request_bomb_rotation.emit(index)

func move_to_position(position_to_move: Vector2) -> void:
	position = position_to_move

func rotate_cw() -> void:
	rotation += PI/2
