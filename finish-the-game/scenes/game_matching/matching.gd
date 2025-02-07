extends Node2D
class_name Matching

signal allow_place_card
signal deny_place_card
signal displace_card(card_index: int)

signal init_UI

signal stop_UI

var hand_card_set: Array = []  # [[_, _, _(head)]]
var field_card_set: Array = []

var moves: int = 0

var time_limit: float
var card_amount: int
var easy_reroll_chance: int


func initialize_game_matching() -> void:
	hand_card_set = []
	field_card_set = []
	moves = 0


func _requested_place_card(card_index: int, head: int) -> void:
	print(hand_card_set[card_index])
	if hand_card_set[card_index][0] != -1 and \
	   can_place_card(field_card_set[len(field_card_set) - 1], hand_card_set[card_index], head):
		
		hand_card_set[card_index][2] = head
		field_card_set.append(hand_card_set[card_index])
		hand_card_set[card_index] = [-1]
		
		allow_place_card.emit()
		
		moves += 1
		if moves == card_amount:
			finish_game()
	else:
		deny_place_card.emit()


func can_place_card(field_card: Array, target_card: Array, head: int) -> bool:
	if field_card[1 - field_card[2]] == target_card[head]:
		return true
	return false


func _requested_displace_card(card_index: int) -> void:
	for i in range(card_amount):
		if hand_card_set[i][0] == -1:
			moves -= 1
			
			field_card_set[len(field_card_set) - 1][2] = 0
			hand_card_set[i] = field_card_set[len(field_card_set) - 1]
			
			field_card_set.remove_at(len(field_card_set) - 1)
			displace_card.emit(i)
			return


func finish_game() -> void:
	pass
