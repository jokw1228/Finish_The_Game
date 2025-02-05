extends Control
class_name StageSelection

enum StageSelectionState {
	NO,
	STAGE_SCROLLING,
	STAGE_INFO_POPPED_UP
}
var stage_selection_state: StageSelectionState = StageSelectionState.NO

var current_stage_index: int = 0
@export var stage_datas: Array[StageData] = []

@export var stage_name: Label
@export var stage_description: Label

signal request_set_stage_datas(stage_datas_to_set: Array[StageData])
func _ready() -> void:
	update_stage_name()
	request_set_stage_datas.emit(stage_datas)

signal stage_selection_state_has_been_changed(changed_state: StageSelectionState)
func set_state(state_to_set: StageSelectionState) -> void:
	stage_selection_state = state_to_set
	stage_selection_state_has_been_changed.emit(stage_selection_state)

func receive_player_started_game() -> void:
	set_state(StageSelectionState.STAGE_SCROLLING)
	slide_in()

func slide_in() -> void:
	var target_position = Vector2(0, 0)
	create_tween().tween_property(self, "position", target_position, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

signal current_stage_has_been_changed(changed_current_stage: int)
func receive_current_stage_has_been_changed(changed_current_stage: int) -> void:
	current_stage_index = changed_current_stage
	update_stage_name()
	current_stage_has_been_changed.emit(changed_current_stage)

func update_stage_name() -> void:
	stage_name.text = stage_datas[current_stage_index].stage_name
	stage_description.text = stage_datas[current_stage_index].stage_description

func receive_stage_info_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.STAGE_SCROLLING:
		set_state(StageSelectionState.STAGE_INFO_POPPED_UP)

func receive_stage_info_exit_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.STAGE_INFO_POPPED_UP:
		set_state(StageSelectionState.STAGE_SCROLLING)
