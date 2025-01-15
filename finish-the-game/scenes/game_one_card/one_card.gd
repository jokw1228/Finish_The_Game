extends Node2D
class_name OneCard

signal allow_place_card
signal deny_place_card
signal request_shape_choose
signal allow_displace_card
signal deny_displace_card

signal init_UI

var hand_card_set: Array[Array] = []  # [[shape, rank]]
var field_stack_1: Array[Array] = []
var field_stack_2: Array[Array] = []

var card_memory: Array[int] = [0]  # store chosen stack index
var can_one_more: bool = true
var shape_change: Array = []  # [[turn, changed_shape]]
var moves: int = 0


func set_delete(set: Array, element) -> void:
	if element in set:
		set.remove_at(set.find(element))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_card()

func initialize_card() -> void:
	field_stack_1 = []
	field_stack_2 = []
	hand_card_set = []
	card_memory = [0]
	can_one_more = true
	shape_change = []
	moves = 0


func _requested_place_card(card: Array, stack_index: int) -> void:
	if can_place_card(card if shape_change == [] or shape_change[-1][0] != moves - 1
						   else [shape_change[-1][1], card[1]],
					  stack_index, [field_stack_1[-1], field_stack_2[-1]],
					  card_memory[-1], can_one_more):
						
		allow_place_card.emit()
		
		if stack_index == 0:
			field_stack_1.append(card)
		else:
			field_stack_2.append(card)
			
		card_memory.append(stack_index)
		moves += 1
		
		if card[1] == 10 or card[1] == 12:
			can_one_more = true
		else:
			can_one_more = false
			if card[1] == 6:
				request_shape_choose.emit()
	else:
		deny_place_card.emit()


func can_place_card(card: Array, stack_index: int, stack_fronts: Array, previous_card_index: int, can_one_more: bool) -> bool:
	var base_card = stack_fronts[stack_index]
	
	if can_one_more:
		if card[0] == base_card[0] or card[1] == base_card[1]:
			return true
			
	elif previous_card_index == stack_index:
		if card[0] == base_card[0]:
			return true
			
	return false


func _recieved_shape_choose(shape: int) -> void:
	shape_change.append([moves, shape])


func _requested_displace_card(stack_index: int) -> void:
	if card_memory[-1] == stack_index:
		allow_displace_card.emit()
		
		if stack_index == 0:
			field_stack_1.remove_at(-1)
		else:
			field_stack_1.remove_at(-1)
		
		card_memory.remove_at(-1)
		
		if shape_change[-1][0] == moves - 1:
			shape_change.remove_at(-1)
		
		moves -= 1
		
	else:
		deny_displace_card.emit()
