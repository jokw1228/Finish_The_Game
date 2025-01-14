extends Node2D
class_name OrbitoUI

const board_size = 4

enum UI_STATE
{
	MOVE_STONE,
	PLACE_STONE,
	ORBIT
}

enum TURN_COLOR
{
	BLACK,
	WHITE
}
var ui_state = UI_STATE.PLACE_STONE
var turn_color = TURN_COLOR.BLACK

signal select_stone(cell_index: Array[int])
signal orbit_board()
signal request_place_stone(cell_index: Array[int], color_to_place)
signal request_move_stone(start_cell_index: Array[int], end_cell_index:Array[int], color_to_place: Orbito.CELL_STATE)
signal request_remove_stone(cell_index: Array[int])
signal do_not_move()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_orbit_button()
	hide_do_not_move_button()
	$orbito_turn_order.set_color(TURN_COLOR.BLACK)
	pass # Replace with function body.

func receive_request_select_stone(cell_index: Array[int]):
	if ui_state == UI_STATE.PLACE_STONE or ui_state == UI_STATE.MOVE_STONE:
		select_stone.emit(cell_index)
		
func receive_approve_and_reply_move_stone(approved_start_cell_index: Array[int], approved_end_cell_index: Array[int], approved_color: Orbito.CELL_STATE):
	ui_state = UI_STATE.PLACE_STONE
	hide_do_not_move_button()
	request_move_stone.emit(approved_start_cell_index, approved_end_cell_index, approved_color)
	
func receive_approve_and_reply_place_stone(approved_cell_index: Array[int], approved_color: Orbito.CELL_STATE):
	ui_state = UI_STATE.ORBIT
	request_place_stone.emit(approved_cell_index, approved_color)
	show_orbit_button()

func receive_approve_and_reply_orbit_board():
	hide_orbit_button()
	ui_state = UI_STATE.MOVE_STONE
	if (turn_color == TURN_COLOR.BLACK):
		turn_color = TURN_COLOR.WHITE
	elif (turn_color == TURN_COLOR.WHITE):
		turn_color = TURN_COLOR.BLACK
	$orbito_turn_order.set_color(turn_color)
	show_do_not_move_button()
	
func receive_approve_and_reply_do_not_move():
	hide_do_not_move_button()
	ui_state = UI_STATE.PLACE_STONE
	
func receive_approve_and_reply_remove_stone(approved_cell_index: Array[int]):
	request_remove_stone.emit(approved_cell_index)
	
func show_orbit_button():
	$orbit_button.show()
	
func hide_orbit_button():
	$orbit_button.hide()
	
func show_do_not_move_button():
	$do_not_move_button.show()
	
func hide_do_not_move_button():
	$do_not_move_button.hide()

func _on_orbit_button_pressed() -> void:
	orbit_board.emit()

func _on_do_not_move_button_pressed() -> void:
	do_not_move.emit()

func set_turn_color(color_to_set):
	turn_color = color_to_set
	$orbito_turn_order.set_color(turn_color)

func set_ui_state(state_to_set):
	ui_state = state_to_set
	if ui_state == UI_STATE.MOVE_STONE:
		show_do_not_move_button()
		hide_orbit_button()
	elif ui_state == UI_STATE.PLACE_STONE:
		hide_do_not_move_button()
		hide_orbit_button()
	elif ui_state == UI_STATE.ORBIT:
		hide_do_not_move_button()
		show_orbit_button()
