extends Node2D
class_name GamePentago

@export var PentagoBoard_node: PentagoBoard

signal player_action_start(color_to_put: int)

func _ready() -> void:
	while true:
		player_action_start.emit(1)
		await PentagoBoard_node.player_action_finished
		player_action_start.emit(2)
		await PentagoBoard_node.player_action_finished
