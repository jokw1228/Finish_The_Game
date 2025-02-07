extends TextureButton
class_name OneCardButton

@export var one_card_ui: OneCardUI
var is_field: bool
var pos_index: int


func initialize_button(is_in_field: bool, button_pos_index: int):
	is_field = is_in_field
	pos_index = button_pos_index
	one_card_ui.place_card(self, is_in_field, button_pos_index)


func _on_pressed() -> void:
	print("one_card : ", is_field, pos_index, " pressed")
	one_card_ui.card_pressed(is_field, pos_index)
