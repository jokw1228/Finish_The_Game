extends Node
class_name OrbitoStoneGenerator

const OrbitoStone_scene = "res://scenes/game_orbito/orbito_stone.tscn"

static func generate(position_to_set: Vector2, color_to_set: Orbito.CELL_STATE) -> OrbitoStone:
	var inst: OrbitoStone = preload(OrbitoStone_scene).instantiate() as OrbitoStone
	inst.position = position_to_set
	inst.set_color(color_to_set)
	return inst
