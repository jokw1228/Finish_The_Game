extends Control
class_name RoomLogo

var room_main: String = "res://scenes/room/room_main/room_main.tscn"

func _ready() -> void:
	room_logo_animation()

func room_logo_animation() -> void:
	%SFXLogoFadeIn.play()
	
	var tween_1: Tween = get_tree().create_tween()
	tween_1.tween_property(%TextureKoreaUniv, "modulate", Color.BLACK, 1.0)
	
	var tween_2: Tween = get_tree().create_tween()
	tween_2.tween_property(%TextureCatAndDog, "modulate", Color.BLACK, 1.0)
	
	await get_tree().create_timer(2.6).timeout
	RoomManager.transition_to_room(room_main)
