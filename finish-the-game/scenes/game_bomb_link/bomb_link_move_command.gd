extends RefCounted
class_name BombLinkMoveCommand

var target_index: Array[int] = []
var y_offset: int = 0

static func create(target_index_to_set: Array[int], y_offset_to_set: int) -> BombLinkMoveCommand:
	var inst: BombLinkMoveCommand = BombLinkMoveCommand.new()
	inst.set_target_index(target_index_to_set)
	inst.set_y_offset(y_offset_to_set)
	return inst

func set_target_index(target_index_to_set: Array[int]) -> void:
	target_index = target_index_to_set

func get_target_index() -> Array[int]:
	return target_index

func set_y_offset(y_offset_to_set: int) -> void:
	y_offset = y_offset_to_set

func get_y_offset() -> int:
	return y_offset
