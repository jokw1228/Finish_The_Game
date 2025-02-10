extends Node2D
class_name Set

signal allow_delete_cards
signal deny_delete_cards

signal init_UI
signal stop_UI

var field_card_set: Array  # isAvailable, shape, number, color, (filling)
var deleted_card_num: int = 0

# About Difficulty
var time_limit: float
var card_amount: int
var attribute_amount: int

func initialize_game_set() -> void:
	field_card_set = []
	deleted_card_num = 0


func can_delete_card_set(card_set: Array) -> bool:
	var is_appropriate = true
	
	for i in range(3):
		if !card_set[i][0]:
			print("game_set: deleted card selected")
			return false
	
	for i in range(1, attribute_amount + 1):
		if card_set[0][i] == card_set[1][i] and\
		   card_set[2][i] == card_set[1][i] and\
		   card_set[0][i] == card_set[2][i]:
			continue
		elif card_set[0][i] != card_set[1][i] and\
			 card_set[2][i] != card_set[1][i] and\
			 card_set[0][i] != card_set[2][i]:
			continue
		else:
			is_appropriate = false
			break
			
	return is_appropriate


func _requested_delete_cards(card_index_set: Array[int]) -> void:
	if can_delete_card_set([field_card_set[card_index_set[0]], field_card_set[card_index_set[1]], field_card_set[card_index_set[2]]]):
		for i in card_index_set:
			field_card_set[i][0] = false
		allow_delete_cards.emit()
		
		if deleted_card_num == card_amount:
			finish_game()
		
	else:
		deny_delete_cards.emit()


func retry() -> void:
	deleted_card_num = 0
	for i in range(len(field_card_set)):
		field_card_set[i][0] = true


func finish_game() -> void:
	pass
