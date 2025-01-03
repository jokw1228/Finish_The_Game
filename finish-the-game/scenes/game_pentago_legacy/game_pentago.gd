extends Node2D
class_name GamePentago

@export var PentagoBoard_node: PentagoBoard

func _ready() -> void:
	while true:
		PentagoBoard_node.wait_put_stone(1)
		await PentagoBoard_node.player_action_finished
		PentagoBoard_node.wait_put_stone(2)
		await PentagoBoard_node.player_action_finished
