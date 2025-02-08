extends Control
class_name RoomGameOver

@export var background_scrolling_controller: BackgroundScrollingController

# GPZOFFICIAL: Change this to transition somewhere proper.
var room_main: String = "res://scenes/room/room_main/room_main.tscn"

func _initialize() -> void:
	$Control/ClearedStageText.visible = false
	$Control/GameOverText.visible = false
	$Control/Score.visible = false
	$Control/NewBestText.visible = false
	$Control/ReturnButton.visible = false
	$Control/ReturnButton.disabled = true
	_new_best_blink()
	background_scrolling_controller.set_all_label_text("GG WP")
	
	pass

func show_room(score: int, current_high_score: int) -> void:
	await get_tree().create_timer(1.0).timeout
	$Control/AudioStreamPlayer.play()
	$Control/GameOverText.visible = true
	await get_tree().create_timer(1.5).timeout
	$Control/ClearedStageTextSFX.play()
	$Control/ClearedStageText.visible = true
	await get_tree().create_timer(0.7).timeout
	$Control/ClearedStageTextSFX.play()
	$Control/Score.text = str(score)
	$Control/Score.visible = true
	if current_high_score < score:
		$Control/HighScoreSFX.play()
		$Control/NewBestText.visible = true
	
	await get_tree().create_timer(0.7).timeout
	$Control/ClearedStageTextSFX.play()
	$Control/ReturnButton.visible = true
	$Control/ReturnButton.disabled = false
	
	pass

func _new_best_blink() -> void:
	while true:
		await get_tree().create_timer(1.0).timeout
		$Control/NewBestText.add_theme_color_override("font_color", Color("#ffc252"))
		await get_tree().create_timer(1.0).timeout
		$Control/NewBestText.add_theme_color_override("font_color", Color("#ffad1f"))
	pass



func _ready() -> void:
	_initialize()
	
	show_room(23, 40)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_button_pressed() -> void:
	$Control/ReturnButton.disabled = true
	$Control/ClickSFX.play()
	RoomManager.transition_to_room(room_main)
	pass # Replace with function body.
