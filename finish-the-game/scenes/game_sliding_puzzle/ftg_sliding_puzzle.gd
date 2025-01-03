extends Node2D
class_name FTGSlidingPuzzle

@export var SlidingPuzzle_node: SlidingPuzzle

signal start_ftg_sliding_puzzle()

func _ready() -> void:
	start_ftg_sliding_puzzle.emit()
