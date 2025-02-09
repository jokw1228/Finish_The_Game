extends ColorRect
class_name StageInfoPopup

@export var stage_info_texture: TextureRect
var stage_infos: Array[Texture2D] = []

var is_popped_up: bool = false

signal stage_info_button_pressed()
func _on_stage_info_button_pressed() -> void:
	if is_popped_up == false:
		stage_info_button_pressed.emit()

signal stage_info_exit_button_pressed()
func _on_stage_info_exit_button_pressed() -> void:
	if is_popped_up == true:
		stage_info_exit_button_pressed.emit()

func receive_request_set_stage_datas(stage_datas_to_set: Array[StageData]) -> void:
	initialize(stage_datas_to_set)

func initialize(stage_datas: Array[StageData]) -> void:
	if stage_datas != null:
		stage_info_texture.texture = stage_datas[0].stage_info
	
	stage_infos = []
	for stage_data: StageData in stage_datas:
		stage_infos.append(stage_data.stage_info)

func receive_current_stage_has_been_changed(changed_current_stage: int) -> void:
	update_stage_info(changed_current_stage)

func update_stage_info(changed_current_stage: int) -> void:
	stage_info_texture.texture = stage_infos[changed_current_stage]

func receive_stage_selection_state_has_been_changed(changed_state: StageSelection.StageSelectionState) -> void:
	if changed_state == StageSelection.StageSelectionState.STAGE_INFO_POPPED_UP \
	and is_popped_up == false:
		is_popped_up = true
		open_popup()
	elif changed_state == StageSelection.StageSelectionState.STAGE_SCROLLING \
	and is_popped_up == true:
		is_popped_up = false
		close_popup()

func open_popup() -> void:
	$ScrollContainer.scroll_vertical = 0
	visible = true

func close_popup() -> void:
	visible = false
