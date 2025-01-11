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
) -> BombLinkBomb:
	var inst: BombLinkBomb = BombLinkBomb.new()
	inst.bomb_type = bomb_type_to_set
	inst.fuse_direction = fuse_direction_to_set
	return inst
