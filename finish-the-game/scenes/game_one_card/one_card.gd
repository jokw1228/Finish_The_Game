extends Node2D
class_name OneCard

signal allow_place_card
signal deny_place_card
signal request_shape_choose
signal allow_displace_card(to_index: int)
signal deny_displace_card

signal init_UI

signal stop_UI

var hand_card_set: Array[Array] = []  # [[shape, rank]]
var field_stack_1: Array[Array] = []
var field_stack_2: Array[Array] = []

var card_memory: Array[int] = [0]  # store chosen stack index
var can_one_more: bool = true
var shape_change: Array = []  # [[turn, changed_shape]]
var moves: int = 0

# About Difficulty
var time_limit: float
var card_amount: int
var hard_card_multiplyer: int


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
	


func can_place_card(card: Array, stack_index: int, stack_fronts: Array,\
					previous_card_index: int, can_one_more: bool) -> bool:
	var base_card = stack_fronts[stack_index]
	
	if can_one_more:
		if card[0] == base_card[0] or card[1] == base_card[1]:
			return true
			
	elif previous_card_index == stack_index:
		if card[0] == base_card[0] or card[1] == base_card[1]:
			return true
			
	return false


func _requested_place_card(card_index: int, stack_index: int) -> void:
	#print(shape_change, moves)
	
	var stack_fronts: Array = [[field_stack_1[-1][0], field_stack_1[-1][1]], [field_stack_2[-1][0], field_stack_2[-1][1]]]
	if shape_change != [] and shape_change[-1][0] == moves:
		stack_fronts[stack_index][0] = shape_change[-1][1]
	
	if can_place_card(hand_card_set[card_index], stack_index, stack_fronts, card_memory[-1], can_one_more):
		if stack_index == 0:
			field_stack_1.append(hand_card_set[card_index])
		else:
			field_stack_2.append(hand_card_set[card_index])
		
		card_memory.append(stack_index)
		moves += 1
		
		if hand_card_set[card_index][1] in [10, 11, 12]:
			can_one_more = true
			
		else:
			can_one_more = false
		
		allow_place_card.emit()
		
		if moves == card_amount:
			finish_game()
		elif hand_card_set[card_index][1] == 6:
			request_shape_choose.emit()
			
		hand_card_set[card_index] = [-1]
	else:
		deny_place_card.emit()


func _recieved_shape_choose(shape: int) -> void:
	shape_change.append([moves, shape])


func _requested_displace_card(stack_index: int) -> void:
	if card_memory[-1] == stack_index:
		print("allow_displace_card")
		
		var temp_index: int = -1
		for i in range(card_amount):
			if hand_card_set[i][0] == -1:
				temp_index = i
				break
		
		if temp_index == -1:
			deny_displace_card.emit()
			return
		
		if stack_index == 0:
			hand_card_set[temp_index] = field_stack_1[len(field_stack_1) - 1]
			field_stack_1.remove_at(len(field_stack_1) - 1)
		else:
			hand_card_set[temp_index] = field_stack_2[len(field_stack_2) - 1]
			field_stack_2.remove_at(len(field_stack_2) - 1)
		
		card_memory.remove_at(len(card_memory) - 1)
		
		if len(shape_change) != 0 and shape_change[-1][0] == moves:
			shape_change.remove_at(len(shape_change) - 1)
		
		moves -= 1
		
		if moves == 0:
			can_one_more = true
		elif stack_index == 0 and field_stack_1[-1][1] in [10, 11, 12]:
			can_one_more = true
		elif stack_index == 1 and field_stack_2[-1][1] in [10, 11, 12]:
			can_one_more = true
		
		allow_displace_card.emit(temp_index)
		
	else:
		deny_displace_card.emit()


func finish_game() -> void:
	pass
