extends Control
class_name RoomLogo

var room_main: String = "res://scenes/room/room_main/room_main.tscn"

func _ready() -> void:
	room_logo_animation()

func room_logo_animation() -> void:
	await get_tree().create_timer(1.0).timeout
	RoomManager.transition_to_room(room_main)
