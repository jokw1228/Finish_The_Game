extends Node
#class_name RoomManager

@export var transition_overlay: TransitionOverlay

var transition_mutex: bool = true
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
