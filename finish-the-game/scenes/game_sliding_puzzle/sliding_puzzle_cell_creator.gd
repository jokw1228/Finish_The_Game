extends Node
class_name SlidingPuzzleCellCreator

const SlidingPuzzleCell_scene = "res://scenes/game_sliding_puzzle/sliding_puzzle_cell.tscn"

static func create(position_to_set: Vector2, number_to_set: int) -> SlidingPuzzleCell:
	var inst: SlidingPuzzleCell = preload(SlidingPuzzleCell_scene).instantiate() as SlidingPuzzleCell
	inst.position = position_to_set
	inst.set_number(number_to_set)
	return inst
