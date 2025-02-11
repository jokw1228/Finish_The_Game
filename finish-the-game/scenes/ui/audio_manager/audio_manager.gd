extends Node
#class_name AudioManager

@onready var bgm_player: AudioStreamPlayer = %BGMPlayer

func play_bgm(bgm_to_play, fade_in_duration: float = 0.0) -> void:
	bgm_player.stream = bgm_to_play
	bgm_player.play()
	
	if fade_in_duration > 0.0:
		create_tween().tween_property(bgm_player, "volume_db", 0, fade_in_duration)
	else:
		bgm_player.volume_db = 0

func stop_bgm(fade_out_duration: float = 0.0) -> void:
	if fade_out_duration > 0.0:
		await create_tween().tween_property(bgm_player, "volume_db", -80, fade_out_duration).finished
	
	bgm_player.stop()
