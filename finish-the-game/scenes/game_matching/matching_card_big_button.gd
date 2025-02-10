extends MatchingCardButton
class_name MatchingCardBigButton


func initialize_button(button_pos_index: int, button_pos_in_card: int):
	pos_index = button_pos_index
	pos_in_card = button_pos_in_card
	pivot_offset = Vector2(64, 128)


func _on_pressed() -> void:
	print("game_matching: ", pos_index, pos_in_card, " pressed")
	matching_ui.card_pressed(pos_index, pos_in_card)
