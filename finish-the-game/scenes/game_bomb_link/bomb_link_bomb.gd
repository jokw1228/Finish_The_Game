extends Node
class_name BombLinkBomb

enum BOMB_TYPE
{
	NORMAL,
	NOT_ROTATABLE,
	GROUP_LEADER,
	GROUP_FOLLOWER
}
var bomb_type: BOMB_TYPE

static var available_bomb_id: int = 1
var bomb_group_id: int = -1

enum FUSE_DIRECTION
{
	RIGHT,
	UP,
	LEFT,
	DOWN
}
var fuse_direction: FUSE_DIRECTION

static func create(\
bomb_type_to_set, \
fuse_direction_to_set: FUSE_DIRECTION\
) -> BombLinkBomb: # for NORMAL, NOT_ROTATABLE
	var inst: BombLinkBomb = BombLinkBomb.new()
	inst.bomb_type = bomb_type_to_set
	inst.fuse_direction = fuse_direction_to_set
	return inst

static func generate_bomb_group_id() -> int:
	var value: int = available_bomb_id
	available_bomb_id += 1
	return value

static func create_group(\
bomb_type_to_set, \
bomb_group_id_to_set, \
fuse_direction_to_set: FUSE_DIRECTION\
) -> BombLinkBomb: # for GROUP_LEADER, GROUP_FOLLOWER
	var inst: BombLinkBomb = BombLinkBomb.new()
	inst.bomb_type = bomb_type_to_set
	inst.bomb_group_id = bomb_group_id_to_set
	inst.fuse_direction = fuse_direction_to_set
	return inst

func rotate_cw() -> void:
	if fuse_direction == FUSE_DIRECTION.RIGHT:
		fuse_direction = FUSE_DIRECTION.DOWN
	elif fuse_direction == FUSE_DIRECTION.DOWN:
		fuse_direction = FUSE_DIRECTION.LEFT
	elif fuse_direction == FUSE_DIRECTION.LEFT:
		fuse_direction = FUSE_DIRECTION.UP
	elif fuse_direction == FUSE_DIRECTION.UP:
		fuse_direction = FUSE_DIRECTION.RIGHT
