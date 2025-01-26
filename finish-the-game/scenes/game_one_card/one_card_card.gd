extends TextureRect
class_name OneCardCard

@export var one_card_ui: OneCardUI
var card_info: Array
var is_field: bool = false
var card_pos_index: int


func initialize_card(info: Array, is_in_field: bool, card_position: int) -> void:
	card_info = info
	is_field = is_in_field
	card_pos_index = card_position
	one_card_ui.place_card(self, is_in_field, card_position)
	
	get_node("card/shape").texture = one_card_ui.shape_image[info[0]]
	get_node("card/rank").text = one_card_ui.rank_string[info[1]]


func move_card(is_up: bool):
	if is_up:
		position.y += -20
	else:
		position.y += 20
