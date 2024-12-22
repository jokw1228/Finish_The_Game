extends Node
class_name PentagoStoneCreator

const PentagoStone_scene = "res://scenes/game_pentago/pentago_stone.tscn"

static func create(position_to_set: Vector2, color_to_set) -> PentagoStone:
	var inst: PentagoStone = preload(PentagoStone_scene).instantiate() as PentagoStone
	inst.position = position_to_set
	inst.set_color(color_to_set)
	return inst
