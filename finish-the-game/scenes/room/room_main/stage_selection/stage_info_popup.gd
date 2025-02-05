extends ColorRect
class_name StageInfoPopup

@export var stage_info_texture: TextureRect
var stage_infos: Array[Texture2D] = []

signal stage_info_exit_button_pressed()
func _on_stage_info_exit_button_pressed() -> void:
	stage_info_exit_button_pressed.emit()

signal stage_info_button_pressed()
func _on_stage_info_button_pressed() -> void:
	stage_info_button_pressed.emit()

func receive_request_set_stage_datas(stage_datas_to_set: Array[StageData]) -> void:
	initialize(stage_datas_to_set)

func initialize(stage_datas: Array[StageData]) -> void:
	if stage_datas != null:
		stage_info_texture.texture = stage_datas[0].stage_info
	
	for stage_data: StageData in stage_datas:
		stage_infos.append(stage_data.stage_info)

func receive_current_stage_has_been_changed(changed_current_stage: int) -> void:
	update_stage_info(changed_current_stage)

func update_stage_info(changed_current_stage: int) -> void:
	stage_info_texture.texture = stage_infos[changed_current_stage]
