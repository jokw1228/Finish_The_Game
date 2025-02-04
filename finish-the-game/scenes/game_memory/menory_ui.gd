extends Node2D
class_name MemoryUI

signal request_delete_cards(card_index_set: Array[int])

@export var memory_main: Memory
@export var single_card: PackedScene
@export var card_button: PackedScene

var shape_image: Array[Texture] = [\
	 preload("res://resources/images/game_memory/sprite_memory_spade_black.png")  ,\
	 preload("res://resources/images/game_memory/sprite_memory_spade_red.png")    ,\
	 preload("res://resources/images/game_memory/sprite_memory_spade_green.png")  ,\
	 preload("res://resources/images/game_memory/sprite_memory_heart_black.png")  ,\
	 preload("res://resources/images/game_memory/sprite_memory_heart_red.png")    ,\
	 preload("res://resources/images/game_memory/sprite_memory_heart_green.png")  ,\
	 preload("res://resources/images/game_memory/sprite_memory_diamond_black.png"),\
	 preload("res://resources/images/game_memory/sprite_memory_diamond_red.png")  ,\
	 preload("res://resources/images/game_memory/sprite_memory_diamond_green.png"),\
	 preload("res://resources/images/game_memory/sprite_memory_clover_black.png") ,\
	 preload("res://resources/images/game_memory/sprite_memory_clover_red.png")   ,\
	 preload("res://resources/images/game_memory/sprite_memory_clover_green.png")
	]

var card_image: Array[Texture] = [\
	 preload("res://resources/images/game_memory/sprite_memory_empty_card.png"),\
	 preload("res://resources/images/game_memory/sprite_memory_unknown_card.png")
	]

var field_cards: Array[MemoryCard] = []
var chosen_cards_index: Array[int] = []
var stop_memory_UI: bool = false

const size_unit = 128
const interval_unit = 32
const max_x = 1080
const max_y = 1920


func initialize_ui() -> void:
	field_cards = []
	chosen_cards_index = []
	stop_memory_UI = false
	
	for i in range(8):
		var card: MemoryCard = single_card.instantiate()
		card.memory_ui = self
		
		card.initialize_card(memory_main.field_card_set[i][1], i)
		place_card(card, i)
		field_cards.append(card)
		add_child(card)
		
		var button: MemoryButton = card_button.instantiate()
		button.memory_ui = self
		place_card(button, i)
		button.initialize_button(i)
		add_child(button)


func place_card(object, card_position: int) -> void:
	var card_pixel_position: Vector2 = Vector2.ZERO
	
	card_pixel_position.x = size_unit * (card_position % 4) +\
							interval_unit * (card_position % 4) +\
							-(size_unit * 2 + interval_unit * 1.5)
	card_pixel_position.y = size_unit * 2 * int(card_position / 4) +\
							interval_unit * int(card_position / 4) +\
							-(size_unit * 2 + interval_unit * 0.5)
	
	object.position = card_pixel_position


func card_pressed(pressed_index: int) -> void:
	if not stop_memory_UI and len(chosen_cards_index) < 2 and\
						   memory_main.field_card_set[pressed_index][0]:
		if not (pressed_index in chosen_cards_index):
			chosen_cards_index.append(pressed_index)
			field_cards[pressed_index].filp_card(true)
			if len(chosen_cards_index) == 2:
				request_delete_cards.emit(chosen_cards_index)
		
		else:
			chosen_cards_index.remove_at(chosen_cards_index.find(pressed_index))
			field_cards[pressed_index].filp_card(false)


func _allowed_delete_cards() -> void:
	chosen_cards_index.clear()


func _denied_delete_cards() -> void:
	await get_tree().create_timer(0.5).timeout
	for i in chosen_cards_index:
		field_cards[i].filp_card(false)
	
	chosen_cards_index.clear()


func _init_ui() -> void:
	initialize_ui()


func _stop_ui() -> void:
	stop_memory_UI = true
