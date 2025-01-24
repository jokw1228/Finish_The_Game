extends Node2D
class_name SetUI

signal request_delete_cards(card_index_set: Array[int])

@export var set_main: Set
@export var single_card: PackedScene
@export var card_button: PackedScene
@export var small_card_button: PackedScene

var shape_image: Array[Array] = [\
	[\
	 [preload("res://resources/images/game_set/sprite_set_spade_black_full.png")],\
	 [preload("res://resources/images/game_set/sprite_set_spade_red_full.png")  ],\
	 [preload("res://resources/images/game_set/sprite_set_spade_green_full.png")]
	],\
	[\
	 [preload("res://resources/images/game_set/sprite_set_heart_black_full.png")],\
	 [preload("res://resources/images/game_set/sprite_set_heart_red_full.png")  ],\
	 [preload("res://resources/images/game_set/sprite_set_heart_green_full.png")]
	],\
	[\
	 [preload("res://resources/images/game_set/sprite_set_diamond_black_full.png")],\
	 [preload("res://resources/images/game_set/sprite_set_diamond_red_full.png")  ],\
	 [preload("res://resources/images/game_set/sprite_set_diamond_green_full.png")]
	]]  # shape_image[shape][color][fillings( = 0)]
	
	

var field_cards: Array[SetCard] = []
var chosen_cards_index: Array[int] = []
var stop_set_UI: bool = false
var card_num: int = 9

const size_unit = 128
const interval_unit = 32
const max_x = 1080
const max_y = 1920

const standard_shape_scale = [1, 1, 0.75]
const standard_shape_position = [\
								 [ [0, 64] ],\
								 [ [0, 0], [0, 128] ],\
								 [ [16, 0], [16, 80], [16, 160] ]
								]


func initialize_ui(num: int = 9, is_button_exist: bool = false) -> void:
	field_cards = []
	chosen_cards_index = []
	stop_set_UI = false
	
	if num == 9:
		card_num = 9
		for i in range(9):
			var card: SetCard = single_card.instantiate()
			print("game_set: card generated")
			card.set_ui = self
			
			if set_main.attribute_num == 2:
				card.initialize_card(set_main.field_card_set[i] + [0, 0], i)
			elif set_main.attribute_num == 3:
				card.initialize_card(set_main.field_card_set[i] + [0], i)
			else:
				card.initialize_card(set_main.field_card_set[i], i)
			
			
			field_cards.append(card)
			add_child(card)
			
			if not is_button_exist:
				var button: SetCardButton = card_button.instantiate()
				print("game_set: button generated")
				button.set_ui = self
				
				button.initialize_button(i)
				add_child(button)
			
	elif num == 12:
		card_num = 12
		for i in range(12):
			var card: SetCard = single_card.instantiate()
			card.set_ui = self
			
			if set_main.attribute_num == 2:
				card.initialize_card(set_main.field_card_set[i] + [0, 0], i)
			elif set_main.attribute_num == 3:
				card.initialize_card(set_main.field_card_set[i] + [0], i)
			else:
				card.initialize_card(set_main.field_card_set[i], i)
			
			place_card(card, i)
			field_cards[i].append(card)
			add_child(card)
			
			if not is_button_exist:
				var button: SetCardButton = card_button.instantiate()
				button.set_ui = self
				place_card(button, i)
				button.initialize_button(i)
				add_child(button)
			
	if not is_button_exist:
		var retry_button: SetRetryButton = small_card_button.instantiate()
		print("game_set: button generated")
		retry_button.set_ui = self
		
		retry_button.initialize_small_button()
		add_child(retry_button)


func place_card(object, card_position: int, is_teleport: bool = true, is_small_button: bool = false) -> void:
	# -1 position : at deleted card stack
	var card_pixel_position: Vector2 = Vector2.ZERO
	
	if is_small_button:
		card_pixel_position.x = -(size_unit * 0.5)
		card_pixel_position.y = size_unit * 7 + interval_unit * 6 +\
								-(size_unit * 4 + interval_unit * 3)
	
	elif card_position == -1:
		card_pixel_position.x = size_unit * 1
		card_pixel_position.y = -(size_unit * 4 + interval_unit * 3)
		
		if is_teleport:
			#object.z_index = field_cards[card_position][-2].z_index + 1
			pass
	
	else:
		if card_num == 9:
			card_pixel_position.x = size_unit * (card_position % 3) +\
									interval_unit * (card_position % 3) +\
									-(size_unit * 1.5 + interval_unit * 1)
			card_pixel_position.y = size_unit * 2 * (0.5 + int(card_position / 3)) +\
									interval_unit * (2 + int(card_position / 3)) +\
									-(size_unit * 4 + interval_unit * 3)
			
		elif card_num == 12:
			card_pixel_position.x = size_unit * (card_position % 4) +\
									interval_unit * (card_position % 4) +\
									-(size_unit * 2 + interval_unit * 1.5)
			card_pixel_position.y = size_unit * 2 * (0.5 + int(card_position / 4)) +\
									interval_unit * (2 + int(card_position / 4)) +\
									-(size_unit * 4 + interval_unit * 3)
	
	if is_teleport:
		object.position = card_pixel_position
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(object, "position", card_pixel_position, 0.15)
		tween.tween_property(object, "rotation", deg_to_rad(90), 0.15)


func card_pressed(pressed_index: int) -> void:
	if not stop_set_UI and len(chosen_cards_index) < 3 and\
						   set_main.field_card_set[pressed_index][0]:
		if not (pressed_index in chosen_cards_index):
			chosen_cards_index.append(pressed_index)
			field_cards[pressed_index].move_card(true)
			if len(chosen_cards_index) == 3:
				request_delete_cards.emit(chosen_cards_index)
		
		else:
			chosen_cards_index.remove_at(chosen_cards_index.find(pressed_index))
			field_cards[pressed_index].move_card(false)


func _allowed_delete_cards() -> void:
	for i in chosen_cards_index:
		place_card(field_cards[i], -1, false)
		field_cards[i].card_info[0] = false
	
	chosen_cards_index.clear()
	set_main.deleted_card_num += 3


func _denied_delete_cards() -> void:
	for i in chosen_cards_index:
		field_cards[i].move_card(false)
	
	chosen_cards_index.clear()


func ui_retry() -> void:
	if not stop_set_UI:
		for field_card in field_cards:
			remove_child(field_card)
			field_card.queue_free()
		set_main.retry()
		initialize_ui(card_num)


func _init_ui(card_num: int) -> void:
	initialize_ui(card_num)


func _stop_ui() -> void:
	stop_set_UI = true
