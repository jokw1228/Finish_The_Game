extends Node2D
class_name OneCardUI

signal request_place_card(card_index: int, stack_index: int)
signal recieve_shape_choose(shape: int)
signal request_displace_card(stack_index: int)

@export var one_card_main: OneCard

const size_unit = 128
const interval_unit = 32
const max_x = 1080
const max_y = 1920

const shape_string: Array = ["spade", "heart", "diamond", "clover"]
const rank_string: Array = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var shape_image: Array[CompressedTexture2D] = [\
	preload("res://resources/images/game_one_card/sprite_one_card_spade.png"),\
	preload("res://resources/images/game_one_card/sprite_one_card_heart.png"),\
	preload("res://resources/images/game_one_card/sprite_one_card_diamond.png"),\
	preload("res://resources/images/game_one_card/sprite_one_card_clover.png")]

var is_any_choosed: bool = false
var requested_index: Array  # [int_is_field, index]
var to_index: int
var stop_one_card_UI: bool = false

var field_cards: Array = [[], []]
var hand_cards: Array = []

var small_buttons: Array = []

var card_amount: int;

@export var single_card: PackedScene
@export var card_button: PackedScene
@export var small_card_button: PackedScene

func initialize_ui() -> void:
	field_cards = [[], []]
	hand_cards = []
	is_any_choosed = false
	requested_index = []
	stop_one_card_UI = false
	small_buttons = []
	card_amount = one_card_main.card_amount
	
	$Outline1.visible = true
	$Outline2.visible = true
	$GuideShape1.visible = false
	$GuideShape2.visible = false
	
	for i in range(2):
		var card: OneCardCard = single_card.instantiate()
		card.one_card_ui = self
		
		if i == 0:
			card.initialize_card(one_card_main.field_stack_1[0], true, i)
		else:
			card.initialize_card(one_card_main.field_stack_2[0], true, i)
		
		field_cards[i].append(card)
		add_child(card)
		
	for i in range(card_amount):
		var card: OneCardCard = single_card.instantiate()
		card.one_card_ui = self
		
		card.initialize_card(one_card_main.hand_card_set[i], false, i)
		hand_cards.append(card)
		add_child(card)
		
	for i in range(2):
		var button: OneCardButton = card_button.instantiate()
		button.one_card_ui = self
		button.initialize_button(true, i)
		add_child(button)
		
	for i in range(card_amount):
		var button: OneCardButton = card_button.instantiate()
		button.one_card_ui = self
		button.initialize_button(false, i)
		add_child(button)


func place_card(object, is_in_field: bool, card_position: int,\
				is_teleport: bool = true, is_small: bool = false) -> void:
	var card_pixel_position: Vector2 = Vector2.ZERO
	
	if is_in_field:
		card_pixel_position.x = size_unit * (1 + card_position) +\
								interval_unit * (1 + card_position) +\
								-(size_unit * 2 + interval_unit * 1.5)
		card_pixel_position.y = -(size_unit * 3 + interval_unit * 3)
		
		if is_teleport == false:
			object.z_index = field_cards[card_position][-2].z_index + 1
		
	elif is_small:
		card_pixel_position.x = size_unit * card_position +\
								interval_unit * card_position +\
								-(size_unit * 2 + interval_unit * 1.5)
		card_pixel_position.y = size_unit * 6 + interval_unit * 5 +\
								-(size_unit * 3 + interval_unit * 3)
	
	else:
		card_pixel_position.x = size_unit * (card_position % 4) +\
								interval_unit * (card_position % 4) +\
								-(size_unit * 2 + interval_unit * 1.5)
		card_pixel_position.y = size_unit * 2 * (1 + int(card_position / 4)) +\
								interval_unit * (3 + int(card_position / 4)) +\
								-(size_unit * 3 + interval_unit * 3)
	
	if is_teleport:
		object.position = card_pixel_position
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(object, "position", card_pixel_position, 0.05)


func card_pressed(is_on_field: bool, card_index: int) -> void:
	if not stop_one_card_UI:
		if is_on_field:
			if is_any_choosed:
				to_index = card_index
				
				print("request_place_card")
				request_place_card.emit(requested_index[1], card_index)
			else:
				if len(field_cards[card_index]) != 1:
					requested_index = [0, card_index]
					
					print("request_displace_card")
					request_displace_card.emit(card_index)
				else:
					return
					
		else:
			if is_any_choosed:
				#chosen_card = hand_cards[card_index]
				
				if card_index == requested_index[1]:
					hand_cards[requested_index[1]].move_card(false)
					print("un_choose_card")
					is_any_choosed = false
					
				else:
					hand_cards[requested_index[1]].move_card(false)
					
					requested_index = [1, card_index]
					
					print("choose_card")
					is_any_choosed = true
					hand_cards[requested_index[1]].move_card(true)
					
			else:
				#chosen_card = hand_cards[card_index]
				requested_index = [1, card_index]
				
				print("choose_card")
				is_any_choosed = true
				hand_cards[requested_index[1]].move_card(true)


func _allowed_displace_card(to_index: int) -> void:
	
	print("_allowed_displace_card")
	hand_cards[to_index] = field_cards[requested_index[1]][-1]
	place_card(field_cards[requested_index[1]][-1], false, to_index, false)
	field_cards[requested_index[1]][-1].is_field = false
	field_cards[requested_index[1]][-1].card_pos_index = to_index
	
	field_cards[requested_index[1]].remove_at(len(field_cards[requested_index[1]]) - 1)
	
	is_any_choosed = false


func _allowed_place_card() -> void:
	
	print("_allowed_place_card")
	
	field_cards[to_index].append(hand_cards[requested_index[1]])
	
	hand_cards[requested_index[1]].move_card(false)
	place_card(hand_cards[requested_index[1]], true, to_index, false)
	
	hand_cards[requested_index[1]].is_field = true
	hand_cards[requested_index[1]].card_pos_index = to_index
	
	hand_cards[requested_index[1]] = null
	
	is_any_choosed = false


func _denied_place_card() -> void:
	print("_denied_place_card")
	pass # Replace with function body.


func _denied_displace_card() -> void:
	print("_denied_displace_card")
	pass # Replace with function body.


func _requested_shape_choose() -> void:
	print("_requested_shape_choose")
	for i in range(4):
		var shape_button: OneCardShapeButton = small_card_button.instantiate()
		shape_button.one_card_ui = self
		shape_button.initialize_button(i)
		shape_button.get_node("card/shape").texture = shape_image[i]
		add_child(shape_button)
		small_buttons.append(shape_button)
	
	stop_one_card_UI = true


func shape_choosed(shape: int) -> void:
	recieve_shape_choose.emit(shape)
	for i in small_buttons:
		i.queue_free()
	small_buttons = []
	
	stop_one_card_UI = false


func _init_ui() -> void:
	initialize_ui()


func _stop_ui() -> void:
	stop_one_card_UI = true
