extends Node2D
class_name PentagoUI

const subboard_width = 3
const subboard_count_x = 2

signal request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int])
signal request_rotate_subboard(requested_subboard_index: Array[int], requested_rotation_direction: Pentago.ROTATION_DIRECTION)

signal request_set_subboard_disabled(disabled_to_set: bool)
signal request_set_cell_disabled(disabled_to_set: bool)
signal request_set_rotation_buttons_disabled(disabled_to_set: bool)

@export var subboards_to_export: Array[PentagoSubboard] = []
var subboards: Array[Array] = []

enum UI_STATE
{
	PLACE_STONE,
	SELECT_SUBBOARD,
	SELECT_ROTATION,
}
var ui_state: UI_STATE = UI_STATE.PLACE_STONE

var input_disabled: bool = false

func _ready() -> void:
	# set subboards array
	for y in range(subboard_count_x):
		var temp: Array[PentagoSubboard] = []
		for x in range(subboard_count_x):
			temp.append(subboards_to_export[x+y*subboard_count_x])
		subboards.append(temp)

func receive_request_place_stone(requested_subboard_index: Array[int], requested_cell_index: Array[int]) -> void:
	if ui_state == UI_STATE.PLACE_STONE and input_disabled == false:
		request_place_stone.emit(requested_subboard_index, requested_cell_index)

func receive_approve_and_reply_place_stone(approved_subboard_index: Array[int], approved_cell_index: Array[int], approved_color: Pentago.CELL_STATE) -> void:
	var _x: int = approved_subboard_index[0]
	var _y: int = approved_subboard_index[1]
	subboards[_y][_x].place_stone(approved_cell_index, approved_color)
	set_ui_state(UI_STATE.SELECT_SUBBOARD)
	%SFXPlaceStone.play()

var stored_subboard_index_to_rotation: Array[int]
func receive_request_select_subboard(subboard_index_to_rotate: Array[int]) -> void:
	if ui_state == UI_STATE.SELECT_SUBBOARD and input_disabled == false:
		stored_subboard_index_to_rotation = subboard_index_to_rotate
		set_ui_state(UI_STATE.SELECT_ROTATION)

func receive_request_rotate_subboard(requested_rotation_direction: Pentago.ROTATION_DIRECTION) -> void:
	if ui_state == UI_STATE.SELECT_ROTATION and input_disabled == false:
		request_rotate_subboard.emit(stored_subboard_index_to_rotation, requested_rotation_direction)

func receive_approve_and_reply_rotate_subboard(approved_subboard_index: Array[int], approved_rotation_direction: Pentago.ROTATION_DIRECTION) -> void:
	var _x: int = approved_subboard_index[0]
	var _y: int = approved_subboard_index[1]
	subboards[_y][_x].rotate_subboard(approved_rotation_direction)
	set_ui_state(UI_STATE.PLACE_STONE)
	%SFXRotateSubboard.play()

func set_ui_state(state_to_set: UI_STATE) -> void:
	ui_state = state_to_set
	if ui_state == UI_STATE.PLACE_STONE:
		request_set_subboard_disabled.emit(true)
		request_set_cell_disabled.emit(false)
		request_set_rotation_buttons_disabled.emit(true)
	elif ui_state == UI_STATE.SELECT_SUBBOARD:
		request_set_subboard_disabled.emit(false)
		request_set_cell_disabled.emit(true)
	elif ui_state == UI_STATE.SELECT_ROTATION:
		request_set_subboard_disabled.emit(true)
		request_set_rotation_buttons_disabled.emit(false)

func receive_request_disable_input(disable_to_set: bool = true):
	input_disabled = disable_to_set
	if disable_to_set == true:
		request_set_subboard_disabled.emit(true)
		request_set_cell_disabled.emit(true)
		request_set_rotation_buttons_disabled.emit(true)
	elif disable_to_set == false:
		set_ui_state(ui_state)
	
func receive_request_immediately_place_stone(target_subboard_index: Array[int], target_cell_index: Array[int], color_to_place: Pentago.CELL_STATE) -> void:
	var _x: int = target_subboard_index[0]
	var _y: int = target_subboard_index[1]
	subboards[_y][_x].place_stone(target_cell_index, color_to_place)
