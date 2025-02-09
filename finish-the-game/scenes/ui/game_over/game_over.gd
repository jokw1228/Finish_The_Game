extends Control
class_name GameOver

# GPZOFFICIAL: Change this to transition somewhere proper.
var room_main: String = "res://scenes/room/room_main/room_main.tscn"

signal request_set_all_label_text(label_text_to_set: String)
func _initialize() -> void:
	$Control/ClearedStageText.visible = false
	$Control/GameOverText.visible = false
	$Control/Score.visible = false
	$Control/NewBestText.visible = false
	$Control/ReturnButton.visible = false
	$Control/ReturnButton.disabled = true
	$Control/RetryButton.visible = false
	$Control/RetryButton.disabled = true
	_new_best_blink()
	request_set_all_label_text.emit("GG WP")

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
	$Control/RetryButton.visible = true
	$Control/RetryButton.disabled = false

func _new_best_blink() -> void:
	while true:
		await get_tree().create_timer(1.0).timeout
		$Control/NewBestText.add_theme_color_override("font_color", Color("#ffc252"))
		await get_tree().create_timer(1.0).timeout
		$Control/NewBestText.add_theme_color_override("font_color", Color("#ffad1f"))

func _ready() -> void:
	_initialize()
	#show_game_over(23, 40)
	"""
	@GPZOFFICIAL: Use show_room(score, highscore) to show score and other UIs
	
	"""

func show_game_over(score: int, highscore: int) -> void:
	_initialize()
	show_room(score, highscore)

func _on_return_button_pressed() -> void:
	$Control/ReturnButton.disabled = true
	$Control/RetryButton.disabled = true
	$Control/ClickSFX.play()
	RoomManager.transition_to_room(room_main)

signal request_retry_stage()
func _on_retry_button_pressed() -> void:
	$Control/ReturnButton.disabled = true
	$Control/RetryButton.disabled = true
	$Control/ClickSFX.play()
	
	"""
	@GPZOFFICIAL: Here goes the code to restart the stage
	
	"""
	request_retry_stage.emit()
