extends TextureButton
class_name OneCardShapeButton

@export var one_card_ui: OneCardUI
var pos_index


func initialize_button(button_pos_index: int):
	pos_index = button_pos_index
	one_card_ui.place_card(self, false, button_pos_index, true, true)


func _on_pressed() -> void:
	one_card_ui.shape_choosed(pos_index)
