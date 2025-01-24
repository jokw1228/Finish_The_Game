extends TextureButton
class_name SetCardButton

@export var set_ui: SetUI
var pos_index: int


func initialize_button(button_pos_index: int):
	pos_index = button_pos_index
	set_ui.place_card(self, button_pos_index)


func _on_pressed() -> void:
	print("game_set: ", pos_index, " pressed")
	set_ui.card_pressed(pos_index)
