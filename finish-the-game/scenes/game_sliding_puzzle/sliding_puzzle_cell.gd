extends Button
class_name SlidingPuzzleCell

const width = 4
const height = 4

@export var Number_node: Label

var number: int
var cell_index: Array[int]

func set_number(number_to_set: int) -> void:
	number = number_to_set
	cell_index = [number/width, number%width]
	Number_node.text = str(number)
