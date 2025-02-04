extends Node2D
class_name Memory

signal allow_delete_cards
signal deny_delete_cards

signal init_UI()
signal stop_UI

var field_card_set: Array  # isAvailable, shape
var deleted_card_num: int = 0


func initialize_game_memory() -> void:
	field_card_set = []
	deleted_card_num = 0


func can_delete_card_set(card_set: Array) -> bool:
	for i in range(2):
		if !card_set[i][0]:
			print("game_set: deleted card selected")
			return false
	
	if card_set[0][1] == card_set[1][1]:
		return true
		
	return false


func _requested_delete_cards(card_index_set: Array[int]) -> void:
	if can_delete_card_set([field_card_set[card_index_set[0]], field_card_set[card_index_set[1]]]):
		for i in card_index_set:
			field_card_set[i][0] = false
		allow_delete_cards.emit()
		deleted_card_num += 2
		
		if deleted_card_num == 8:
			finish_game()
		
	else:
		deny_delete_cards.emit()


func finish_game() -> void:
	pass
