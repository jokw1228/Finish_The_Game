extends TextureRect
class_name MatchingCard


@export var matching_ui: MatchingUI
var card_info: Array
var card_pos_index: int
var turn_to: int


func initialize_card(info: Array, card_position: int, _turn_to: int = 0) -> void:
	card_info = info
	card_pos_index = card_position
	turn_to = _turn_to
	pivot_offset = Vector2(64, 128)
	
	get_node("Card/Eye1").texture = matching_ui.eyes_image[info[0]]
	get_node("Card/Eye2").texture = matching_ui.eyes_image[info[1]]
