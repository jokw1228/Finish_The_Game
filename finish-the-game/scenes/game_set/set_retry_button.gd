extends TextureButton
class_name SetRetryButton

@export var set_ui: SetUI

func initialize_small_button():
	set_ui.place_card(self, 0, true, true)

func _on_pressed() -> void:
	print("game_set: retry pressed")
	set_ui.ui_retry()
