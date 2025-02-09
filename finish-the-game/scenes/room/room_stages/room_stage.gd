extends Control
class_name RoomStage

@export var stage_name: String = ""
signal request_set_all_label_text(label_text_to_set: String)

func _ready() -> void:
	request_set_all_label_text.emit(stage_name)
	
	await get_tree().create_timer(0.5).timeout
	start_stage()

@export var ready_set_go: ReadySetGo
func start_stage() -> void:
	await ready_set_go.ready_set_go()
	
