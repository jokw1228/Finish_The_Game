extends Node2D
class_name OneCardUI

signal request_place_card(card: Array, stack_index: int)
signal recieve_shape_choose(shape: int)
signal request_displace_card(stack_index: int)

@export var one_card_main: OneCard

const size_unit = 128
const interval_unit = 32
const max_x = 1080
const max_y = 1920

const shape_string: Array = ["spade", "heart", "diamond", "clover"]
const rank_string: Array = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

var is_any_choosed: bool = false
#var chosen_card: OneCardCard
var requested_index: Array = []
var to_index: int
var stop_one_card_UI: bool = false

var field_cards: Array = [[], []]
var hand_cards: Array = []
@export var single_card: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func initialize_ui() -> void:
	field_cards = [[], []]
	hand_cards = []
	is_any_choosed = false
	requested_index = []
	stop_one_card_UI = false
	
	for i in range(2):
		var card: OneCardCard = single_card.instantiate()
		
		if i == 0:
			card.initialize_card(one_card_main.field_stack_1, true, i)
		else:
			card.initialize_card(one_card_main.field_stack_2, true, i)
		
		field_cards[i].append(card)
		
	for i in range(8):
		var card: OneCardCard = single_card.instantiate()
		card.initialize_card(one_card_main.hand_card_set[i], false, i)
		hand_cards.append(card)


func card_pressed(is_on_field: bool, card_index: int) -> void:
	if not stop_one_card_UI:
		if is_on_field:
			if is_any_choosed:
				to_index = card_index
				request_place_card.emit(hand_cards[requested_index[1]].card_info, card_index)
			else:
				if len(field_cards[card_index]) != 1:
					requested_index = [0, card_index]
					request_displace_card.emit(card_index)
				else:
					return
		else:
			if is_any_choosed:
				#chosen_card = hand_cards[card_index]
				requested_index = [1, card_index]
			else:
				#chosen_card = hand_cards[card_index]
				requested_index = [1, card_index]


func _allowed_displace_card() -> void:
	for i in range(8):
		if hand_cards[i] == 0:
			hand_cards[i] = field_cards[requested_index[1]][-1]
			field_cards[requested_index[1]][-1].place_card(false, i, false)
			break
	
	field_cards[requested_index[1]].remove_at(-1)
	field_cards[requested_index[1]][-1].can_press = true


func _allowed_place_card() -> void:
	field_cards[to_index][-1].can_press = false
	field_cards[to_index].append(hand_cards[requested_index[1]])
	hand_cards[requested_index[1]].place_card(true, to_index, false)
	hand_cards[requested_index[1]] = 0


func _denied_place_card() -> void:
	pass # Replace with function body.


func _denied_displace_card() -> void:
	pass # Replace with function body.


func _requested_shape_choose() -> void:
	pass # Replace with function body.


func _init_ui() -> void:
	initialize_ui()
