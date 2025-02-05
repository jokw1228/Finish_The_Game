extends Control
class_name StageSelection

var is_ready_to_get_input: bool = false

var current_stage_index: int = 0
@export var stage_datas: Array[StageData] = []

@export var stage_name: Label
@export var stage_description: Label

signal request_set_stage_datas(stage_datas_to_set: Array[StageData])
func _ready() -> void:
	update_stage_info()
	request_set_stage_datas.emit(stage_datas)

func receive_player_started_game() -> void:
	is_ready_to_get_input = true
	slide_in()

func slide_in() -> void:
	var target_position = Vector2(0, 0)

	create_tween().tween_property(self, "position", target_position, 0.5)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func receive_current_stage_has_been_changed(changed_current_stage: int) -> void:
	current_stage_index = changed_current_stage
	update_stage_info()

func update_stage_info() -> void:
	stage_name.text = stage_datas[current_stage_index].stage_name
	stage_description.text = stage_datas[current_stage_index].stage_description
