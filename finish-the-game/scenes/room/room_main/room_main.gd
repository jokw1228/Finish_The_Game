extends Control
class_name RoomMain

@export var background_scrolling_controller: BackgroundScrollingController

enum RoomMainState {
	TITLE,
	STAGE_SELECTION
}
var room_main_state: RoomMainState = RoomMainState.TITLE

func _ready() -> void:
	background_scrolling_controller.set_all_label_text("F.T.G.")

signal player_started_game()
func receive_player_has_tapped_anywhere() -> void:
	if room_main_state == RoomMainState.TITLE:
		player_started_game.emit()
		
		room_main_state = RoomMainState.STAGE_SELECTION
