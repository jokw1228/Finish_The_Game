extends Node
#class_name RoomManager

@export var transition_overlay: TransitionOverlay

var transition_mutex: bool = true
var is_returned_from_game_over: bool = false
var stage_type: int = 0
var stage_index: int = 0

func set_scene_state(stage_type: int, stage_index: int) -> void:
	self.stage_type = stage_type
	self.stage_index = stage_index
	print("SCENE STATE SET TO ", self.stage_type, ", ", self.stage_index)
	pass
	
func get_scene_type() -> int:
	return self.stage_type
	
func get_scene_index() -> int:
	return self.stage_index

func transition_to_room(room_to_go: String) -> void:
	if transition_mutex == false:
		return
	transition_mutex = false
	
	# fade out
	await transition_overlay.fade_out()
	
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file(room_to_go)
	await get_tree().create_timer(0.2).timeout
	
	# fade in
	await transition_overlay.fade_in()
	
	transition_mutex = true
