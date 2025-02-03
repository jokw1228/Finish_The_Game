extends Node2D
class_name RoomMain

@export var background_scrolling_controller: BackgroundScrollingController

func _ready() -> void:
	background_scrolling_controller.set_all_label_text("F.T.G.")
