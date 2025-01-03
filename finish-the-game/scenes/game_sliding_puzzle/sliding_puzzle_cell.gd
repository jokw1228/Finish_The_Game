extends TextureButton
class_name SlidingPuzzleCell

var index: Array[int]

signal request_slide(index_to_request: Array[int])

@export var Number_node: Label

func set_number(number_to_set: int) -> void:
	Number_node.text = str(number_to_set)

func set_index(index_to_set: Array[int]) -> void:
	index = index_to_set

func connect_signal(function_to_connect: Callable) -> void:
	request_slide.connect(function_to_connect)

func _on_pressed() -> void:
	request_slide.emit(index)

func move_to_position(position_to_move: Vector2) -> void:
	position = position_to_move
