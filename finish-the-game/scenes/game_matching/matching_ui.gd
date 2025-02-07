extends Node2D
class_name MatchingUI

signal request_place_card(card_index: int, head: int)
signal request_displace_card(card_index: int)

@export var matching_main: Matching
@export var single_card: PackedScene
@export var card_button: PackedScene
@export var card_big_button: PackedScene

var eyes_image: Array[Texture] = [\
	 preload("res://resources/images/game_matching/sprite_matching_eye_0.png"),\
	 preload("res://resources/images/game_matching/sprite_matching_eye_1.png"),\
	 preload("res://resources/images/game_matching/sprite_matching_eye_2.png"),\
	 preload("res://resources/images/game_matching/sprite_matching_eye_3.png"),\
	 preload("res://resources/images/game_matching/sprite_matching_eye_4.png"),\
	 preload("res://resources/images/game_matching/sprite_matching_eye_5.png"),\
	 preload("res://resources/images/game_matching/sprite_matching_eye_6.png"),\
	]


var hand_cards: Array = []
var field_cards: Array[MatchingCard] = []
var last_card_indexs: Array[int]  # [pressed_index, pressed_in_card]

var stop_matching_UI: bool = false

const size_unit = 128
const interval_unit = 32
const max_x = 1080
const max_y = 1920


func initialize_ui() -> void:
	hand_cards = []
	field_cards = []
	last_card_indexs = []
	stop_matching_UI = false
	
	var card: MatchingCard = single_card.instantiate()
	card.matching_ui = self
	
	card.initialize_card(matching_main.field_card_set[0], -1, -1)
	place_card(card, -1, -1, -1)
	field_cards.append(card)
	add_child(card)
	
	var button: MatchingCardButton = card_big_button.instantiate()
	button.matching_ui = self
	place_card(button, -1, -1, 1)
	button.initialize_button(-1, 0)
	add_child(button)
	
	for i in range(8):
		card = single_card.instantiate()
		card.matching_ui = self
		
		card.initialize_card(matching_main.hand_card_set[i], i)
		place_card(card, i)
		hand_cards.append(card)
		add_child(card)
		
		for j in range(2):
			button = card_button.instantiate()
			button.matching_ui = self
			place_card(button, i, j)
			button.initialize_button(i, j)
			add_child(button)


func place_card(object, card_position: int, button_pos: int = -1, turn_to: int = 0,
 				is_teleport: bool = true) -> void:
	var card_pixel_position: Vector2 = Vector2.ZERO
	
	if card_position >= 0:
		card_pixel_position.x = size_unit * (card_position % 4) +\
								interval_unit * (card_position % 4) +\
								-(size_unit * 2 + interval_unit * 1.5)
		card_pixel_position.y = size_unit * 2 * (0.5 + int(card_position / 4)) +\
								interval_unit * (2 + int(card_position / 4)) +\
								-(size_unit * 2.5 + interval_unit * 1.5)
		
		if button_pos != -1:
			card_pixel_position.y += size_unit * button_pos
	else:
		card_pixel_position.x = size_unit * 2 * (1 + card_position) +\
								interval_unit * 2 +\
								-(size_unit * 2 + interval_unit * 1.5)
		card_pixel_position.y = -2 * interval_unit +\
								-(size_unit * 2.5 + interval_unit * 1.5)
	
	if is_teleport:
		object.position = card_pixel_position
		object.rotation = deg_to_rad(90) * turn_to
	else:
		var tween: Tween = get_tree().create_tween()
		
		tween.tween_property(object, "position", card_pixel_position, 0.15)
		tween.tween_property(object, "rotation", deg_to_rad(90) * turn_to, 0.15)


func card_pressed(pressed_index: int, pressed_in_card: int) -> void:
	if not stop_matching_UI:
		if pressed_index >= 0 and hand_cards[pressed_index] != null:
			last_card_indexs = [pressed_index, pressed_in_card]
			print("request_place_card")
			request_place_card.emit(pressed_index, pressed_in_card)
		
		elif pressed_index < 0:
			print("request_displace_card")
			request_displace_card.emit(pressed_index)


func _allowed_place_card() -> void:
	for tp_card in field_cards:
		tp_card.card_pos_index -= 1
		place_card(tp_card, tp_card.card_pos_index, -1, tp_card.turn_to, false)
	
	var card = hand_cards[last_card_indexs[0]]
	
	card.card_pos_index = -1
	card.turn_to = last_card_indexs[1] * 2 - 1
	place_card(card, -1, -1, card.turn_to, false)
	field_cards.append(hand_cards[last_card_indexs[0]])
	hand_cards[last_card_indexs[0]] = null


func _denied_place_card() -> void:
	pass # Replace with function body.


func _displaced_card(sent_card_index: int) -> void:
	hand_cards[sent_card_index] = field_cards[len(field_cards) - 1]
	place_card(field_cards[len(field_cards) - 1], sent_card_index, -1, 0, false)
	field_cards.remove_at(len(field_cards) - 1)
	
	for card in field_cards:
		card.card_pos_index += 1
		place_card(card, card.card_pos_index, -1, card.turn_to, false)


func _init_ui() -> void:
	initialize_ui()


func _stop_ui() -> void:
	stop_matching_UI = true
