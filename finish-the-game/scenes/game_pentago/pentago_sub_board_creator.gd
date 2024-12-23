extends Node
class_name PentagoSubBoardCreator

const PentagoSubBoard_scene = "res://scenes/game_pentago/pentago_sub_board.tscn"

static func create(position_to_set: Vector2, size_to_set: int = 3) -> PentagoSubBoard:
	var inst: PentagoSubBoard = preload(PentagoSubBoard_scene).instantiate() as PentagoSubBoard
	inst.position = position_to_set
	inst.subboard_size = size_to_set
	return inst
