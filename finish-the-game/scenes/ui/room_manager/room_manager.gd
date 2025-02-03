extends Node
#class_name RoomManager

@export var transition_overlay: TransitionOverlay

var transition_mutex: bool = true
func transition_to_room(room_to_go: PackedScene) -> void:
	if transition_mutex == false:
		return
	transition_mutex = false
	
	# fade out
	await transition_overlay.fade_out()
	
	get_tree().change_scene_to_packed(room_to_go)
	
	# fade in
	await transition_overlay.fade_in()
	
	transition_mutex = true
