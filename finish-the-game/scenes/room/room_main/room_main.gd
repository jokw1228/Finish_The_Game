extends Control
class_name RoomMain

@export var background_scrolling_controller: BackgroundScrollingController

@export var room_main_bgm: AudioStream

enum RoomMainState {
	TITLE,
	STAGE_SELECTION
}
var room_main_state: RoomMainState = RoomMainState.TITLE

signal returned_from_game(stage_type: int, stage_index: int)
signal title_remove()
signal room_state_is_solo()

func _ready() -> void:
	background_scrolling_controller.set_all_label_text("F.T.G.")
	AudioManager.play_bgm(room_main_bgm)
	if not RoomManager.is_returned_from_game_over:
		RoomManager.is_returned_from_game_over = true
	else:
		returned_from_game.emit(RoomManager.stage_type, RoomManager.stage_index)
		title_remove.emit()
		room_main_state = RoomMainState.STAGE_SELECTION
		
		pass
		

signal player_started_game()
func receive_player_has_tapped_anywhere() -> void:
	if room_main_state == RoomMainState.TITLE:
		player_started_game.emit()
		
		room_main_state = RoomMainState.STAGE_SELECTION
