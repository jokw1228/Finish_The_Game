extends Control
class_name RoomLogo

var room_main: String = "res://scenes/room/room_main/room_main.tscn"

func _ready() -> void:
	room_logo_animation()

func room_logo_animation() -> void:
	var tween_1: Tween = get_tree().create_tween()
	tween_1.tween_property(%TextureKoreaUniv, "modulate", Color.BLACK, 0.5)
	
	var tween_2: Tween = get_tree().create_tween()
	tween_2.tween_property(%TextureCatAndDog, "modulate", Color.BLACK, 0.5)
	
	await get_tree().create_timer(1.5).timeout
	RoomManager.transition_to_room(room_main)
