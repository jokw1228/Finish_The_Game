extends Node2D
class_name RoomLogo

@export var room_main: PackedScene

func _ready() -> void:
	room_logo_animation()

func room_logo_animation() -> void:
	await get_tree().create_timer(1.0).timeout
	RoomManager.transition_to_room(room_main)
