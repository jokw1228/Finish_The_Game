extends Node
class_name BombLinkBomb

enum BOMB_TYPE
{
	NORMAL,
	NOT_ROTATABLE,
}
var bomb_type: BOMB_TYPE

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

func rotate_cw() -> void:
	if fuse_direction == FUSE_DIRECTION.RIGHT:
		fuse_direction = FUSE_DIRECTION.DOWN
	elif fuse_direction == FUSE_DIRECTION.DOWN:
		fuse_direction = FUSE_DIRECTION.LEFT
	elif fuse_direction == FUSE_DIRECTION.LEFT:
		fuse_direction = FUSE_DIRECTION.UP
	elif fuse_direction == FUSE_DIRECTION.UP:
		fuse_direction = FUSE_DIRECTION.RIGHT
