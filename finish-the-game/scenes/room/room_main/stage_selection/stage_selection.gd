extends Control
class_name StageSelection

enum StageSelectionState {
	NO,
	STAGE_SCROLLING,
	STAGE_INFO_POPPED_UP,
	OPTIONS_POPPED_UP
}
var stage_selection_state: StageSelectionState = StageSelectionState.NO

@export var stage_mix_datas: Array[StageData] = []
@export var stage_solo_datas: Array[StageData] = []


var stage_datas: Array[StageData]
var current_stage_index: int = 0

@onready var stage_name: Label = %StageName as Label
@onready var stage_description: Label = %StageDescription as Label
@onready var stage_best_score: Label = %BestScoreData as Label

signal request_set_stage_datas(stage_datas_to_set: Array[StageData])
signal request_set_stage_index(stage_index: int)
signal request_set_button_to_solo()
func _ready() -> void:
	if RoomManager.get_scene_type() == 1:
		receive_request_display_solo_stages()
		request_set_button_to_solo.emit()
	else:
		
		receive_request_display_mix_stages()
	request_set_stage_index.emit(RoomManager.get_scene_index())
	current_stage_index = RoomManager.get_scene_index()
	update_stage_name()
	
	pass

func set_scene_state(stage_type: int, stage_index: int) -> void:
	set_state(StageSelectionState.STAGE_SCROLLING)
	position = Vector2(0, 0)
	pass

signal stage_selection_state_has_been_changed(changed_state: StageSelectionState)
func set_state(state_to_set: StageSelectionState) -> void:
	stage_selection_state = state_to_set
	control_buttons_disabled(state_to_set)
	stage_selection_state_has_been_changed.emit(stage_selection_state)

func receive_player_started_game() -> void:
	set_state(StageSelectionState.STAGE_SCROLLING)
	slide_in()
	%SFXActivated.play()

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
	stage_best_score.text = str(SaveManager.get_score(stage_datas[current_stage_index].stage_code))
	stage_name.text = stage_datas[current_stage_index].stage_name
	stage_description.text = stage_datas[current_stage_index].stage_description

func receive_stage_info_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.STAGE_SCROLLING:
		set_state(StageSelectionState.STAGE_INFO_POPPED_UP)

func receive_stage_info_exit_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.STAGE_INFO_POPPED_UP:
		set_state(StageSelectionState.STAGE_SCROLLING)
		
func receive_options_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.STAGE_SCROLLING:
		set_state(StageSelectionState.OPTIONS_POPPED_UP)
		$OptionsButton.visible = false
		
func receive_exit_options_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.OPTIONS_POPPED_UP:
		set_state(StageSelectionState.STAGE_SCROLLING)
		$OptionsButton.visible = true

func receive_stage_selection_button_pressed() -> void:
	if stage_selection_state == StageSelectionState.STAGE_SCROLLING:
		RoomManager.transition_to_room(stage_datas[current_stage_index].stage_room)
		set_state(StageSelectionState.NO)
		AudioManager.stop_bgm(1.0)

func receive_request_display_mix_stages() -> void:
	print("PING!")
	current_stage_index = 0
	stage_datas = stage_mix_datas.duplicate(true)
	update_stage_name()
	RoomManager.set_scene_state(0, RoomManager.get_scene_index())
	request_set_stage_datas.emit(stage_datas)

func receive_request_display_solo_stages() -> void:
	print("PONG!")
	current_stage_index = 0
	stage_datas = stage_solo_datas.duplicate(true)
	update_stage_name()
	RoomManager.set_scene_state(1, RoomManager.get_scene_index())
	request_set_stage_datas.emit(stage_datas)
	
func control_buttons_disabled(state_to_set: StageSelectionState) -> void:
	#return
	if state_to_set == StageSelectionState.STAGE_SCROLLING:
		set_disabled_with_filter($StageInfoButton, false)
		set_disabled_with_filter($StageInfoPopup/StageInfoExitButton, true)
		set_disabled_with_filter($OptionsButton, false)
		set_disabled_with_filter($OptionsPopup/ExitOptionsButton, true)
	elif state_to_set == StageSelectionState.STAGE_INFO_POPPED_UP:
		set_disabled_with_filter($StageInfoButton, true)
		set_disabled_with_filter($StageInfoPopup/StageInfoExitButton, false)
		set_disabled_with_filter($OptionsButton, true)
		set_disabled_with_filter($OptionsPopup/ExitOptionsButton, true)
	elif state_to_set == StageSelectionState.OPTIONS_POPPED_UP:
		set_disabled_with_filter($StageInfoButton, true)
		set_disabled_with_filter($StageInfoPopup/StageInfoExitButton, true)
		set_disabled_with_filter($OptionsButton, true)
		set_disabled_with_filter($OptionsPopup/ExitOptionsButton, false)
	
func set_disabled_with_filter(button: TextureButton, disabled: bool) -> void:
	button.disabled = disabled
	if disabled == true:
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elif disabled == false:
		button.mouse_filter = Control.MOUSE_FILTER_STOP
	return
